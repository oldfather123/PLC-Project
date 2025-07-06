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
  | RBlt of string * string * string
  | RBle of string * string * string
  | RBgt of string * string * string
  | RBge of string * string * string
  | RXori of string * string * int

let sp = ref (-1)

(* 添加栈管理相关数据结构 *)
type var_location = 
  | InReg of string      (* 在寄存器中 *)
  | InStack of int       (* 在栈中的偏移量 *)

let stack_vars = Hashtbl.create 100  (* 变量到栈位置的映射 *)
let current_stack_offset = ref 0  

(* 寄存器分配相关数据结构 *)
type reg_status = Free | Used
let reg_pool = Array.make 32 Free  (* x0-x31的状态 *)
let var_to_reg = Hashtbl.create 100 (* 变量到寄存器的映射 *)
let reg_to_var = Hashtbl.create 32  (* 寄存器到变量的映射 *)
let reg_use_count = Array.make 32 0

(* 将变量存入栈 *)
let spill_to_stack var reg =
  current_stack_offset := !current_stack_offset - 4;
  Hashtbl.add stack_vars var !current_stack_offset;
  [
    RComment ("spill", ("spill " ^ var), []);
    RPush (reg, -(!current_stack_offset))
  ]

(* 从栈中加载变量 *)
let load_from_stack var reg =
  let offset = Hashtbl.find stack_vars var in
  [
    RComment ("load", ("load " ^ var), []);
    RPop (reg, -(offset))
  ]

(* 寄存器选择策略 *)
let find_victim_register () =
  let victim = ref None in
  let min_count = ref max_int in
  (* 遍历所有正在使用的寄存器，选择使用次数最少的 *)
  for i = 3 to 31 do
    if i <> 10 && reg_pool.(i) = Used && reg_use_count.(i) < !min_count then
      begin
        min_count := reg_use_count.(i);
        victim := Some (Printf.sprintf "x%d" i)
      end
  done;
  match !victim with
  | Some reg -> reg
  | None -> failwith "No registers to spill"

(* 寄存器分配函数 *)
let allocate_register () =
  let rec find_free_reg i =
    if i >= 32 then None  (* 没有可用寄存器 *)
    else if i = 0 then find_free_reg 3  (* x0是零寄存器，跳过 *)
    else if i = 1 then find_free_reg 4
    else if i = 2 then find_free_reg 5
    else if i = 10 then find_free_reg 11
    else if reg_pool.(i) = Free then 
      begin
        reg_use_count.(i) <- reg_use_count.(i) + 1;
        Some i
      end
    else find_free_reg (i + 1)
  in find_free_reg 1

(* 释放寄存器 *)
let free_register reg =
  let reg_num = int_of_string (String.sub reg 1 (String.length reg - 1)) in
  reg_pool.(reg_num) <- Free;
  try
    let var = Hashtbl.find reg_to_var reg in
    Hashtbl.remove var_to_reg var;
    Hashtbl.remove reg_to_var reg
  with Not_found -> ()

let popsig = ref (false, "")
let pushsig = ref (false, "")

(* 为变量分配寄存器 *)
let get_register var =
  try 
    (* 先检查变量是否在寄存器中 *)
    let reg = Hashtbl.find var_to_reg var in
    let reg_num = int_of_string (String.sub reg 1 (String.length reg - 1)) in
    reg_use_count.(reg_num) <- reg_use_count.(reg_num) + 1;
    reg
  with Not_found ->
    try
      (* 检查变量是否在栈中 *)
      let _offset = Hashtbl.find stack_vars var in
      match allocate_register () with
      | Some reg_num ->
          let reg = Printf.sprintf "x%d" reg_num in
          (* 从栈中加载到寄存器 *)
          ignore (load_from_stack var reg);
          popsig := (true, reg);
          reg_pool.(reg_num) <- Used;
          Hashtbl.add var_to_reg var reg;
          Hashtbl.add reg_to_var reg var;
          Hashtbl.remove stack_vars var;
          reg
      | None -> 
          (* 寄存器已满，需要溢出一个寄存器 *)
          let victim_reg = find_victim_register () in
          let victim_var = Hashtbl.find reg_to_var victim_reg in
          (* 将受害者变量保存到栈中 *)
          ignore (spill_to_stack victim_var victim_reg);
          pushsig := (true, victim_reg);
          free_register victim_reg;
          (* 为新变量分配寄存器 *)
          Hashtbl.add var_to_reg var victim_reg;
          Hashtbl.add reg_to_var victim_reg var;
          victim_reg
    with Not_found ->
      (* 变量首次使用 *)
      match allocate_register () with
      | Some reg_num ->
          let reg = Printf.sprintf "x%d" reg_num in
          reg_pool.(reg_num) <- Used;
          Hashtbl.add var_to_reg var reg;
          Hashtbl.add reg_to_var reg var;
          reg
      | None ->
          (* 同上，需要溢出处理 *)
          let victim_reg = find_victim_register () in
          let victim_var = Hashtbl.find reg_to_var victim_reg in
          ignore (spill_to_stack victim_var victim_reg);
          pushsig := (true, victim_reg);
          free_register victim_reg;
          Hashtbl.add var_to_reg var victim_reg;
          Hashtbl.add reg_to_var victim_reg var;
          victim_reg

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
      let second = String.index_from s (first + 1) '_' in
      let var_name = String.sub s 0 second in
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
  current_stack_offset := 0;  (* 初始化栈偏移量 *)
  Hashtbl.clear stack_vars;   (* 清空栈变量表 *)
  Array.fill reg_use_count 0 32 0;
  let rec aux acc = function
    | [] -> List.rev acc
    | TacAssign (x, y) :: xs ->
        let getvar = ref [] in
        let rx = base_var x in
        if !popsig = (true, rx) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, rx) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        let ry = base_var y in
        if !popsig = (true, ry) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (ry, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, ry) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (ry, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if is_number ry then
          aux (!getvar @ [RLi (rx, int_of_string ry)] @ acc) xs  (* 如果右值是数字，使用 li 指令 *)
        else
          aux (!getvar @ [RMv (rx, ry)] @ acc) xs
    | TacBinOp (x1, x, op, a) :: 
      TacUnOp (x3, "!", x2) :: 
      TacIfGoto (x4, label) :: xs when x2 = x1 && x4 = x3 && op <> "&&" && op <> "||"->
        (* 优化模式：直接生成beq/bne指令 *)
        let getvar = ref [] in  
      let rx = base_var x and ra = base_var a in
       if !popsig = (true, rx) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, rx) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !popsig = (true, ra) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, ra) then
          (pushsig := (false, "");
          getvar := [RPush (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        let instr = match op with
          | "==" -> RBne (rx, ra, label)  (* 生成beq指令 *)
          | "!=" -> RBeq (rx, ra, label)  (* 生成bne指令 *)
          | "<" -> RBge (rx, ra, label)
          | "<=" -> RBgt (rx, ra, label)
          | ">" -> RBle (rx, ra, label)
          | ">=" -> RBlt (rx, ra, label)
          | _ -> failwith "Unsupported operation in if-goto"
        in
        aux (!getvar @ [instr] @ acc) xs
    | TacBinOp (x, a, op, b) :: xs ->
        let getvar = ref [] in
        let rx = base_var x and ra = base_var a and rb = base_var b in
        if !popsig = (true, rx) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, rx) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !popsig = (true, ra) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, ra) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !popsig = (true, rb) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (rb, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, rb) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (rb, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        let inst = match op with
          | "+" -> [RAdd (rx, ra, rb)]
          | "-" -> [RSub (rx, ra, rb)]
          | "*" -> [RMul (rx, ra, rb)]
          | "/" -> [RDiv (rx, ra, rb)]
          | "%" -> [RRem (rx, ra, rb)]
          | "==" -> [RSub (rx, ra, rb)]
          | "!=" -> [RSub (rx, ra, rb)]
          | "<" -> [RSlt (rx, ra, rb)]
          | "<=" -> [RSlt (rx, ra, rb); RXori (rx, rx, 1)] 
          | ">" -> [RSgt (rx, ra, rb)]
          | ">=" -> [RSgt (rx, ra, rb); RXori (rx, rx, 1)]
          | "&&" -> [RAnd (rx, ra, rb)]
          | "||" -> [ROr (rx, ra, rb)]
          | _ -> [RAdd (rx, ra, rb)]
        in
        aux (!getvar @ inst @ acc) xs
    | TacUnOp (x, op, a) :: xs ->
      let getvar = ref [] in  
      let rx = base_var x and ra = base_var a in
       if !popsig = (true, rx) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, rx) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !popsig = (true, ra) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, ra) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        let inst = match op with
          | "!" -> RSeqz (rx, ra)
          | "-" -> RNeg (rx, ra)
          | _ -> RComment ("a0", ("unop " ^ op), [])
        in
        aux (!getvar @ [inst] @ acc) xs
    | TacLabel l :: xs when String.starts_with ~prefix:"if_" l || 
                           String.starts_with ~prefix:"then_" l || 
                           String.starts_with ~prefix:"while_" l-> aux (RLabel l :: acc) xs
    | TacGoto l :: xs -> aux (RJ l :: acc) xs
    | TacIfGoto (a, l) :: xs -> 
      let getvar = ref [] in  
        let ra = base_var a in
        if !popsig = (true, ra) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, ra) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
      aux (RBnez (ra, l) :: acc) xs
    | TacParam a :: xs ->
        sp := !sp + 1; 
        let getvar = ref [] in  
        let ra = base_var a in
        if !popsig = (true, ra) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, ra) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        aux (!getvar @ [RPush (ra, !sp * 4)] @ acc) xs;
    | TacCall (x, f, _n) :: xs ->
      let getvar = ref [] in  
      let rx = base_var x in
       if !popsig = (true, rx) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (rx, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, rx) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (rx, !current_stack_offset)])
        else
          getvar := !getvar @ []; 
      aux (!getvar @ [RMv (rx, "a0")] @ RCall f :: acc) xs
    | TacReturn (Some a) :: xs -> 
      let getvar = ref [] in  
        let ra = base_var a in
        if !popsig = (true, ra) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, ra) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
      aux (!getvar @ [RRet (Some (ra)); RPop ("ra", !current_stack_offset); RMv ("a0", ra)] @ acc) xs
    | TacReturn None :: xs -> aux (RRet None :: acc) xs
    | TacComment (t, s, a) :: TacLabel l :: xs -> 
      let identifier_name (id : identifier) : string = id in
        let getvar = ref [] in 
      let an = List.map identifier_name a in
        let pops =
          List.mapi (fun i arg_var ->
            let ra = base_var arg_var in
        if !popsig = (true, ra) then
          (popsig := (false, "");
          getvar := !getvar @ [RPop (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
        if !pushsig = (true, ra) then
          (pushsig := (false, "");
          getvar := !getvar @ [RPush (ra, !current_stack_offset)])
        else
          getvar := !getvar @ [];
            RPop (ra, i * 4)
          ) an
        in
        let insts = [RComment (t, s, an); RLabel l] @ !getvar @ pops @ [RPush ("ra", !current_stack_offset)] in
        sp := !sp - List.length a;
        aux (List.rev_append insts acc) xs
    | TacPhi (_, _, _) :: xs -> aux acc xs
    | _ :: xs -> aux acc xs
  in
  (* aux [] tac_list *)
  let result = aux [] tac_list in
  cleanup_registers ();
  result