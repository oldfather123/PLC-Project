open Transfer
open Cfg_gen

(* 辅助函数：判断字符串是否为整数 *)
let is_int s =
  try ignore (int_of_string s); true with _ -> false

(* 检测循环结构：返回所有在环上的 block label *)
let find_loop_blocks cfg =
  let rec dfs path visited loops l =
    if List.mem l path then
      List.iter (fun x -> Hashtbl.replace loops x ()) path
    else if not (Hashtbl.mem visited l) then (
      Hashtbl.replace visited l ();
      let block = Hashtbl.find cfg l in
      List.iter (dfs (l :: path) visited loops) block.succs
    )
  in
  let loops = Hashtbl.create 16 in
  let visited = Hashtbl.create 32 in
  Hashtbl.iter (fun l _ -> dfs [] visited loops l) cfg;
  loops

(* 常量折叠和常量传播，跳过循环体 *)
let const_fold_and_propagate_skip_loops loop_blocks blocks =
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
  let rec replace_var x =
    if Hashtbl.mem env x then
      let v = Hashtbl.find env x in
      if is_int v then v else if v = x then x else replace_var v
    else x
  in
  List.map (fun block ->
    match block.label with
    | Some l when Hashtbl.mem loop_blocks l -> block
    | _ ->
      let instrs =
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
          | TacIfGoto (a, l) when String.starts_with ~prefix:"if_L" l -> Some (TacIfGoto (replace_var a, l))
          | TacLabel _ | TacGoto _ | TacReturn None | TacComment _ | TacPhi _ | TacIfGoto _-> Some tac
        ) block.instrs
      in { block with instrs }
  ) blocks

let copy_propagate_skip_loops loop_blocks blocks =
  let env = Hashtbl.create 32 in
  let rec replace_var x =
    if Hashtbl.mem env x then
      let v = Hashtbl.find env x in
      if v = x then x else replace_var v
    else x
  in
  List.map (fun block ->
    match block.label with
    | Some l when Hashtbl.mem loop_blocks l -> block
    | _ ->
      let instrs =
        List.filter_map (fun tac ->
          match tac with
          | TacAssign (x, y) when not (is_int y) ->
              let y' = replace_var y in
              Hashtbl.replace env x y';
              Some (TacAssign (x, y'))
          | TacBinOp (x, a, op, b) ->
              Some (TacBinOp (x, replace_var a, op, replace_var b))
          | TacUnOp (x, op, a) ->
              Some (TacUnOp (x, op, replace_var a))
          | TacParam a -> Some (TacParam (replace_var a))
          | TacCall (x, f, n) -> Hashtbl.remove env x; Some (TacCall (x, f, n))
          | TacReturn (Some a) -> Some (TacReturn (Some (replace_var a)))
          | TacIfGoto (a, l) ->
              let a' = replace_var a in
              if is_int a' then
                if int_of_string a' = 0 then None
                else Some (TacGoto l)
              else
                Some (TacIfGoto (a', l))
                | _ -> Some (tac)
        ) block.instrs
      in { block with instrs }
  ) blocks

let dead_code_elimination_skip_loops loop_blocks blocks =
  let used = Hashtbl.create 32 in
  let label_used = Hashtbl.create 32 in
  List.iter (fun block ->
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
        | TacGoto l -> Hashtbl.replace label_used l ()
        | TacPhi (_, a, b) ->
            if not (is_int a) then Hashtbl.replace used a ();
            if not (is_int b) then Hashtbl.replace used b ()
        | _ -> ()
      ) block.instrs
  ) blocks;
    List.flatten (
    List.map (fun block ->
      match block.label with
      | Some l when Hashtbl.mem loop_blocks l ->
          block.instrs
      | _ ->
          List.filter (function
            | TacAssign (x, _) -> Hashtbl.mem used x
            | _ -> true
          ) block.instrs
    ) blocks
  )

(* 基于CFG的不可达代码消除 *)
let unreachable_code_elimination_by_cfg tac_list =
  let (cfg, blk) = build_cfg tac_list in
  let entry_label = "main" in
  let visited = Hashtbl.create 32 in
  let rec visit l =
    if not (Hashtbl.mem visited l) then (
      Hashtbl.replace visited l ();
      let block = Hashtbl.find cfg l in
      List.iter visit block.succs
    )
  in
  visit entry_label;
  let reachable_blocks =
    List.filter (fun block ->
      match block.label with
      | Some l -> Hashtbl.mem visited l
      | None -> true
    ) blk
  in
  List.flatten (List.map (fun block -> block.instrs) reachable_blocks)

(* 综合优化流程：对while循环体不做任何优化 *)
let optimize tac_list =
  let (cfg, blk) = build_cfg tac_list in
  let loop_blocks = find_loop_blocks cfg in
  let blocks =
    blk
    |> (const_fold_and_propagate_skip_loops loop_blocks)
    |> (copy_propagate_skip_loops loop_blocks)
    |> (dead_code_elimination_skip_loops loop_blocks)
  in
  unreachable_code_elimination_by_cfg blocks