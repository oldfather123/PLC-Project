open Transfer
open Ast

type riscv_inst =
  | RAdd of string * string * string
  | RSub of string * string * string
  | RMul of string * string * string
  | RDiv of string * string * string
  | RRem of string * string * string
  | RSlt of string * string * string
  | RSle of string * string * string
  | RSgt of string * string * string
  | RSge of string * string * string
  | RAnd of string * string * string
  | ROr of string * string * string
  | RSeqz of string * string
  | RNeg of string * string
  | RMv of string * string
  | RLi of string * int
  | RLabel of string
  | RJ of string
  | RBnez of string * string
  | RPush of string * int
  | RPop of string * int
  | RCall of string
  | RRet of string option
  | RComment of string * string * string list
  | RBeq of string * string * string  (* 添加相等比较跳转指令 *)
  | RBne of string * string * string  (* 添加不等比较跳转指令 *)


(* 寄存器分配相关数据结构 *)
type reg_status = Free | Used
let reg_pool = Array.make 32 Free  (* x0-x31的状态 *)
let var_to_reg = Hashtbl.create 100 (* 变量到寄存器的映射 *)
let reg_to_var = Hashtbl.create 32  (* 寄存器到变量的映射 *)

(* 寄存器分配函数 *)
let allocate_register () =
  let rec find_free_reg i =
    if i >= 32 then None  (* 没有可用寄存器 *)
    else if i = 0 then find_free_reg 3  (* x0是零寄存器，跳过 *)
    else if i = 1 then find_free_reg 4
    else if i = 2 then find_free_reg 5
    else if i = 10 then find_free_reg 11
    else if reg_pool.(i) = Free then Some i
    else find_free_reg (i + 1)
  in find_free_reg 1

(* 为变量分配寄存器 *)
let get_register var =
  try 
    Hashtbl.find var_to_reg var
  with Not_found ->
    match allocate_register () with
    | Some reg_num ->
        let reg = Printf.sprintf "x%d" reg_num in
        reg_pool.(reg_num) <- Used;
        Hashtbl.add var_to_reg var reg;
        Hashtbl.add reg_to_var reg var;
        reg
    | None -> 
        (* 如果没有可用寄存器，需要实现寄存器溢出 *)
        Printf.printf "No available registers\n";
        failwith "No available registers"

(* 释放寄存器 *)
let free_register reg =
  let reg_num = int_of_string (String.sub reg 1 (String.length reg - 1)) in
  reg_pool.(reg_num) <- Free;
  try
    let var = Hashtbl.find reg_to_var reg in
    Hashtbl.remove var_to_reg var;
    Hashtbl.remove reg_to_var reg
  with Not_found -> ()

  (* let base_var s =
  try 
    let first = String.index s '_' in
    String.sub s 0 first
  with _ -> s *)

let is_number s =
  try
    let _ = int_of_string s in
    true
  with Failure _ -> false

let base_var s =
  if is_number s then
    s  (* 如果是数字，直接返回数字字符串 *)
  else
    try 
      let first = String.index s '_' in
      let var_name = String.sub s 0 first in
      get_register var_name
    with _ -> get_register s

let cleanup_registers () =
  Hashtbl.iter (fun _ reg -> free_register reg) var_to_reg;
  for i = 1 to 31 do
    reg_pool.(i) <- Free
  done;
  Hashtbl.clear var_to_reg;
  Hashtbl.clear reg_to_var

let tac_to_riscv tac_list =
  let sp = ref (-1) in
  let rec aux acc = function
    | [] -> List.rev acc
    | TacAssign (x, y) :: xs ->
        let rx = base_var x in
        let ry = base_var y in
        if is_number ry then
          aux (RLi (rx, int_of_string ry) :: acc) xs  (* 如果右值是数字，使用 li 指令 *)
        else
          aux (RMv (rx, ry) :: acc) xs
    | TacBinOp (x1, i, "==", v1) :: 
      TacUnOp (x3, "!", x2) :: 
      TacIfGoto (x4, label) :: xs when x2 = x1 && x4 = x3->
        (* 优化模式：直接生成beq/bne指令 *)
        aux (RBne (base_var i, base_var v1, label) :: acc) xs
    | TacBinOp (x1, i, "!=", v1) :: 
      TacUnOp (x3, "!", x2) :: 
      TacIfGoto (x4, label) :: xs when x2 = x1 && x4 = x3->
        (* 优化模式：直接生成beq/bne指令 *)
        aux (RBeq (base_var i, base_var v1, label) :: acc) xs
    | TacBinOp (x, a, op, b) :: xs ->
        let rx = base_var x and ra = base_var a and rb = base_var b in
        let inst = match op with
          | "+" -> RAdd (rx, ra, rb)
          | "-" -> RSub (rx, ra, rb)
          | "*" -> RMul (rx, ra, rb)
          | "/" -> RDiv (rx, ra, rb)
          | "%" -> RRem (rx, ra, rb)
          | "==" -> RSub (rx, ra, rb)
          | "!=" -> RSub (rx, ra, rb)
          | "<" -> RSlt (rx, ra, rb)
          | "<=" -> RSle (rx, ra, rb)
          | ">" -> RSgt (rx, ra, rb)
          | ">=" -> RSge (rx, ra, rb)
          | "&&" -> RAnd (rx, ra, rb)
          | "||" -> ROr (rx, ra, rb)
          | _ -> RAdd (rx, ra, rb)
        in
        aux (inst :: acc) xs
    | TacUnOp (x, op, a) :: xs ->
        let rx = base_var x and ra = base_var a in
        let inst = match op with
          | "!" -> RSeqz (rx, ra)
          | "-" -> RNeg (rx, ra)
          | _ -> RComment ("a0", ("unop " ^ op), [])
        in
        aux (inst :: acc) xs
    | TacLabel l :: xs when String.starts_with ~prefix:"if_" l || 
                           String.starts_with ~prefix:"then_" l || 
                           String.starts_with ~prefix:"while_" l-> aux (RLabel l :: acc) xs
    | TacGoto l :: xs -> aux (RJ l :: acc) xs
    | TacIfGoto (a, l) :: xs -> aux (RBnez (base_var a, l) :: acc) xs
    | TacParam a :: xs ->
        sp := !sp + 1;  
        aux (RPush (base_var a, !sp * 4) :: acc) xs;
    | TacCall (x, f, _n) :: xs ->
        aux (RMv (base_var x, "a0") :: RCall f :: acc) xs
    | TacReturn (Some a) :: xs -> aux (RRet (Some (base_var a)) :: RMv ("a0", base_var a) :: acc) xs
    | TacReturn None :: xs -> aux (RRet None :: acc) xs
    | TacComment (t, s, a) :: TacLabel l :: xs -> 
      let identifier_name (id : identifier) : string = id in
        let an = List.map identifier_name a in
        let pops =
          List.mapi (fun i arg_var ->
            RPop (base_var arg_var, i * 4)
          ) an
        in
        let insts = [RComment (t, s, an); RLabel l] @ pops in
        sp := !sp - List.length a;
        aux (List.rev_append insts acc) xs
    | TacPhi (_, _, _) :: xs -> aux acc xs
    | _ :: xs -> aux acc xs
  in
  (* aux [] tac_list *)
  let result = aux [] tac_list in
  cleanup_registers ();
  result