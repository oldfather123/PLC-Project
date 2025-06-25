open Transfer

(* 辅助函数：判断字符串是否为整数 *)
let is_int s =
  try ignore (int_of_string s); true with _ -> false

(* 常量折叠和常量传播 *)
let const_fold_and_propagate tac_list =
  let env = Hashtbl.create 32 in
  let eval_binop op a b =
    let a = int_of_string a in
    let b = int_of_string b in
    match op with
    | "+" -> string_of_int (a + b)
    | "-" -> string_of_int (a - b)
    | "*" -> string_of_int (a * b)
    | "/" -> string_of_int (a / b)
    | "%" -> string_of_int (a mod b)
    | "==" -> if a = b then "1" else "0"
    | "!=" -> if a <> b then "1" else "0"
    | "<" -> if a < b then "1" else "0"
    | "<=" -> if a <= b then "1" else "0"
    | ">" -> if a > b then "1" else "0"
    | ">=" -> if a >= b then "1" else "0"
    | "&&" -> if a <> 0 && b <> 0 then "1" else "0"
    | "||" -> if a <> 0 || b <> 0 then "1" else "0"
    | _ -> failwith "unsupported binop"
  in
  let eval_unop op a =
    let a = int_of_string a in
    match op with
    | "+" -> string_of_int a
    | "-" -> string_of_int (-a)
    | "!" -> if a = 0 then "1" else "0"
    | _ -> failwith "unsupported unop"
  in
  let replace_var x =
    if Hashtbl.mem env x then
      let v = Hashtbl.find env x in
      if is_int v then v else x
    else x
  in
  List.filter_map (fun tac ->
    match tac with
    | TacAssign (x, v) when is_int v ->
        Hashtbl.replace env x v;
        Some (TacAssign (x, v))
    | TacAssign (x, y) ->
        let y' = replace_var y in
        if is_int y' then (
          Hashtbl.replace env x y';
          Some (TacAssign (x, y'))
        ) else (
          Hashtbl.remove env x;
          Some (TacAssign (x, y'))
        )
    | TacBinOp (x, a, op, b) ->
        let a' = replace_var a in
        let b' = replace_var b in
        if is_int a' && is_int b' then (
          let v = eval_binop op a' b' in
          Hashtbl.replace env x v;
          Some (TacAssign (x, v))
        ) else (
          Hashtbl.remove env x;
          Some (TacBinOp (x, a', op, b'))
        )
    | TacUnOp (x, op, a) ->
        let a' = replace_var a in
        if is_int a' then (
          let v = eval_unop op a' in
          Hashtbl.replace env x v;
          Some (TacAssign (x, v))
        ) else (
          Hashtbl.remove env x;
          Some (TacUnOp (x, op, a'))
        )
    | TacParam a -> Some (TacParam (replace_var a))
    | TacCall (x, f, n) -> Hashtbl.remove env x; Some (TacCall (x, f, n))
    | TacReturn (Some a) -> Some (TacReturn (Some (replace_var a)))
    | TacIfGoto (a, l) -> Some (TacIfGoto (replace_var a, l))
    | TacLabel _ | TacGoto _ | TacReturn None | TacComment _ -> Some tac
  ) tac_list

(* 复制传播 *)
let copy_propagate tac_list =
  let env = Hashtbl.create 32 in
  let rec replace_var x =
    if Hashtbl.mem env x then
      let v = Hashtbl.find env x in
      if v = x then x else replace_var v
    else x
  in
  List.map (fun tac ->
    match tac with
    | TacAssign (x, y) when not (is_int y) ->
        let y' = replace_var y in
        Hashtbl.replace env x y';
        TacAssign (x, y')
    | TacBinOp (x, a, op, b) ->
        TacBinOp (x, replace_var a, op, replace_var b)
    | TacUnOp (x, op, a) ->
        TacUnOp (x, op, replace_var a)
    | TacParam a -> TacParam (replace_var a)
    | TacCall (x, f, n) -> Hashtbl.remove env x; TacCall (x, f, n)
    | TacReturn (Some a) -> TacReturn (Some (replace_var a))
    | TacIfGoto (a, l) -> TacIfGoto (replace_var a, l)
    | _ -> tac
  ) tac_list

(* 死代码消除 *)
let dead_code_elimination tac_list =
  let used = Hashtbl.create 32 in
  (* 标记所有被用到的变量 *)
  List.iter (function
    | TacAssign (_, v) -> if not (is_int v) then Hashtbl.replace used v ()
    | TacBinOp (_, a, _, b) ->
        if not (is_int a) then Hashtbl.replace used a ();
        if not (is_int b) then Hashtbl.replace used b ()
    | TacUnOp (_, _, a) -> if not (is_int a) then Hashtbl.replace used a ()
    | TacParam a -> if not (is_int a) then Hashtbl.replace used a ()
    | TacCall (x, _, _) -> Hashtbl.replace used x ()
    | TacReturn (Some a) -> if not (is_int a) then Hashtbl.replace used a ()
    | TacIfGoto (a, _) -> if not (is_int a) then Hashtbl.replace used a ()
    | _ -> ()
  ) tac_list;
  (* 只保留被用到的赋值 *)
  List.filter (function
    | TacAssign (x, _) -> Hashtbl.mem used x
    | _ -> true
  ) tac_list

(* 综合优化流程 *)
let optimize tac_list =
  tac_list
  |> const_fold_and_propagate
  |> copy_propagate
  |> dead_code_elimination