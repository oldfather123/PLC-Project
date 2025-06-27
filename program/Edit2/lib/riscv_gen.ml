open Transfer

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
  | RComment of string

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
          | _ -> RComment ("unop " ^ op)
        in
        aux (inst :: acc) xs
    | TacLabel l :: xs -> aux (RLabel l :: acc) xs
    | TacGoto l :: xs -> aux (RJ l :: acc) xs
    | TacIfGoto (a, l) :: xs -> aux (RBnez (base_var a, l) :: acc) xs
    | TacParam a :: xs ->
        sp := !sp + 1;  
        aux (RPush (base_var a, !sp * 4) :: acc) xs;
    | TacCall (x, f, n) :: xs ->
        (* 约定参数总是a0,a1,...,an-1 *)
        let pop_vars = List.init n (fun i -> ("a" ^ string_of_int i, i)) in
        let pops = List.map (fun (v, ofs) -> RPop (v, ofs * 4)) pop_vars in
        let insts = pops @ [RCall f; RMv (base_var x, "a0")] in
        sp := !sp - n;
        aux (List.rev_append insts acc) xs
    | TacReturn (Some a) :: xs -> aux (RRet (Some (base_var a)) :: acc) xs
    | TacReturn None :: xs -> aux (RRet None :: acc) xs
    | TacComment s :: xs -> aux (RComment s :: acc) xs
    | TacPhi (_, _, _) :: xs -> aux acc xs
  in
  aux [] tac_list