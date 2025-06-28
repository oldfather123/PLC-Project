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

let base_var s =
  try String.sub s 0 (String.rindex s '_')
  with _ -> s

let tac_to_riscv tac_list =
  let sp = ref (-1) in
  let rec aux acc = function
    | [] -> List.rev acc
    | TacAssign (x, y) :: xs ->
        aux (RMv (base_var x, base_var y) :: acc) xs
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
    | TacLabel l :: xs -> aux (RLabel l :: acc) xs
    | TacGoto l :: xs -> aux (RJ l :: acc) xs
    | TacIfGoto (a, l) :: xs -> aux (RBnez (base_var a, l) :: acc) xs
    | TacParam a :: xs ->
        sp := !sp + 1;  
        aux (RPush (base_var a, !sp * 4) :: acc) xs;
    | TacCall (x, f, _n) :: xs ->
        aux (RMv (base_var x, "a0") :: RCall f :: acc) xs
    | TacReturn (Some a) :: xs -> aux (RRet (Some (base_var a)) :: RMv ("a0", base_var a) :: acc) xs
    | TacReturn None :: xs -> aux (RRet None :: acc) xs
    | TacComment (t, s, a) :: xs -> 
      let identifier_name (id : identifier) : string = id in
        let an = List.map identifier_name a in
        let pops =
          List.mapi (fun i arg_var ->
            RPop (base_var arg_var, i * 4)
          ) an
        in
        let insts = [RComment (t, s, an)] @ pops in
        sp := !sp - List.length a;
        aux (List.rev_append insts acc) xs
    | TacPhi (_, _, _) :: xs -> aux acc xs
  in
  aux [] tac_list