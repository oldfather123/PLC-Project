(* SSA优化模块 - 目前只实现常量折叠和复制传播 *)

(* 值表示 *)
type value =
  | Const of int
  | Var of string
  | Unknown

(* 常量表：变量名 -> 值 *)
module ConstMap = Map.Make(String)

(* 复制表：变量名 -> 源变量名 *)
module CopyMap = Map.Make(String)

(* 辅助函数：判断字符串是否为数字 *)
let is_integer s =
  try 
    ignore (int_of_string s); 
    true 
  with _ -> false

(* 常量折叠：对二元运算进行求值 *)
let fold_binary_op op v1 v2 =
  match v1, v2 with
  | Const i1, Const i2 ->
    (match op with
    | "+" -> Const (i1 + i2)
    | "-" -> Const (i1 - i2)
    | "*" -> Const (i1 * i2)
    | "/" when i2 <> 0 -> Const (i1 / i2)
    | "%" when i2 <> 0 -> Const (i1 mod i2)
    | "==" -> Const (if i1 = i2 then 1 else 0)
    | "!=" -> Const (if i1 <> i2 then 1 else 0)
    | "<" -> Const (if i1 < i2 then 1 else 0)
    | "<=" -> Const (if i1 <= i2 then 1 else 0)
    | ">" -> Const (if i1 > i2 then 1 else 0)
    | ">=" -> Const (if i1 >= i2 then 1 else 0)
    | "&&" -> Const (if i1 <> 0 && i2 <> 0 then 1 else 0)
    | "||" -> Const (if i1 <> 0 || i2 <> 0 then 1 else 0)
    | _ -> Unknown)
  | _ -> Unknown

(* 常量折叠：对一元运算进行求值 *)
let fold_unary_op op v =
  match v with
  | Const i ->
    (match op with
    | "+" -> Const i
    | "-" -> Const (-i)
    | "!" -> Const (if i = 0 then 1 else 0)
    | _ -> Unknown)
  | _ -> Unknown

(* 获取值 - 不进行递归查找，避免跨基本块的错误传播 *)
let get_value const_map _copy_map var =
  if is_integer var then
    Const (int_of_string var)
  else
    (* TODO:只检查直接的常量映射，不进行复制链追踪 *)
    try
      Const (ConstMap.find var const_map)
    with Not_found -> Var var

(* 单条指令的常量折叠和复制传播 *)
let optimize_tac_instruction const_map copy_map instr =
  match instr with
  | Transfer.TacAssign (dest, src) ->
    (* 处理赋值指令 *)
    if is_integer src then
      (* 源是常量，记录到常量表 *)
      let new_const_map = ConstMap.add dest (int_of_string src) const_map in
      let new_copy_map = CopyMap.remove dest copy_map in
      (new_const_map, new_copy_map, [Transfer.TacAssign (dest, src)])
    else
      (* 源是变量，检查是否可以进行常量传播 *)
      let value = get_value const_map copy_map src in
      (match value with
      | Const c ->
        let const_str = string_of_int c in
        let new_const_map = ConstMap.add dest c const_map in
        let new_copy_map = CopyMap.remove dest copy_map in
        (new_const_map, new_copy_map, [Transfer.TacAssign (dest, const_str)])
      | Var _ ->
        (* 绝对安全：不进行复制传播，不记录复制关系但不替换 *)
        (* TODO：更加激进的策略 *)
        let new_const_map = ConstMap.remove dest const_map in
        let new_copy_map = CopyMap.remove dest copy_map in
        (new_const_map, new_copy_map, [instr])
      | _ ->
        let new_const_map = ConstMap.remove dest const_map in
        let new_copy_map = CopyMap.remove dest copy_map in
        (new_const_map, new_copy_map, [instr]))

  | Transfer.TacBinOp (dest, src1, op, src2) ->
    (* 处理二元运算指令 *)
    let v1 = get_value const_map copy_map src1 in
    let v2 = get_value const_map copy_map src2 in
    let folded = fold_binary_op op v1 v2 in
    (match folded with
    | Const c ->
      (* 可以常量折叠 *)
      let const_str = string_of_int c in
      let new_const_map = ConstMap.add dest c const_map in
      let new_copy_map = CopyMap.remove dest copy_map in
      (new_const_map, new_copy_map, [Transfer.TacAssign (dest, const_str)])
    | _ ->
      (* 不能常量折叠，但可以用常量替换操作数 *)
      let new_src1 = (match v1 with
        | Const c -> string_of_int c
        | _ -> src1) in
      let new_src2 = (match v2 with
        | Const c -> string_of_int c
        | _ -> src2) in
      let new_const_map = ConstMap.remove dest const_map in
      let new_copy_map = CopyMap.remove dest copy_map in
      let optimized_instr = 
        if new_src1 <> src1 || new_src2 <> src2 then
          Transfer.TacBinOp (dest, new_src1, op, new_src2)
        else
          instr
      in
      (new_const_map, new_copy_map, [optimized_instr]))

  | Transfer.TacUnOp (dest, op, src) ->
    (* 处理一元运算指令 *)
    let v = get_value const_map copy_map src in
    let folded = fold_unary_op op v in
    (match folded with
    | Const c ->
      (* 可以常量折叠 *)
      let const_str = string_of_int c in
      let new_const_map = ConstMap.add dest c const_map in
      let new_copy_map = CopyMap.remove dest copy_map in
      (new_const_map, new_copy_map, [Transfer.TacAssign (dest, const_str)])
    | _ ->
      (* 不能常量折叠，保持原指令 *)
    let new_const_map = ConstMap.remove dest const_map in
    let new_copy_map = CopyMap.remove dest copy_map in
    (new_const_map, new_copy_map, [instr]))

  | Transfer.TacIfGoto (cond, label) ->
    (* 处理条件跳转指令 - 清空状态，因为控制流分叉 *)
    let v = get_value const_map copy_map cond in
    let new_cond = (match v with
      | Const c -> string_of_int c
      | _ -> cond) in
    let optimized_instr = 
      if new_cond <> cond then
        Transfer.TacIfGoto (new_cond, label)
      else
        instr
    in
    (* 控制流指令后清空常量和复制信息 *)
    (ConstMap.empty, CopyMap.empty, [optimized_instr])

  | Transfer.TacParam src ->
    (* 处理参数指令 *)
    let v = get_value const_map copy_map src in
    let new_src = (match v with
      | Const c -> string_of_int c
      | _ -> src) in
    let optimized_instr = 
      if new_src <> src then
        Transfer.TacParam new_src
      else
        instr
    in
    (const_map, copy_map, [optimized_instr])

  | Transfer.TacReturn (Some src) ->
    (* 处理返回指令 *)
    let v = get_value const_map copy_map src in
    let new_src = (match v with
      | Const c -> string_of_int c
      | _ -> src) in
    let optimized_instr = 
      if new_src <> src then
        Transfer.TacReturn (Some new_src)
      else
        instr
    in
    (const_map, copy_map, [optimized_instr])

  | Transfer.TacLabel _ | Transfer.TacGoto _ ->
    (* 标签和跳转指令清空状态 *)
    (ConstMap.empty, CopyMap.empty, [instr])

  | _ ->
    (* 其他指令不做优化 *)
    (const_map, copy_map, [instr])

(* 对TAC指令列表进行保守的常量折叠优化 *)
let optimize_constant_folding tac_list =
  let rec optimize_loop tac_list const_map copy_map acc =
    match tac_list with
    | [] -> List.rev acc
    | instr :: rest ->
      let (new_const_map, new_copy_map, optimized_instrs) = 
        optimize_tac_instruction const_map copy_map instr in
      optimize_loop rest new_const_map new_copy_map (List.rev_append optimized_instrs acc)
  in
  optimize_loop tac_list ConstMap.empty CopyMap.empty []

(* 检查变量是否被后续指令使用 *)
let is_variable_used var remaining_instrs =
  List.exists (fun instr ->
    match instr with
    | Transfer.TacAssign (_, src) when src = var -> true
    | Transfer.TacBinOp (_, src1, _, src2) when src1 = var || src2 = var -> true
    | Transfer.TacUnOp (_, _, src) when src = var -> true
    | Transfer.TacIfGoto (cond, _) when cond = var -> true
    | Transfer.TacParam src when src = var -> true
    | Transfer.TacReturn (Some src) when src = var -> true
    | Transfer.TacPhi (_, src1, src2) when src1 = var || src2 = var -> true
    | _ -> false
  ) remaining_instrs

(* 死代码消除 - 移除未使用的临时变量赋值 *)
let eliminate_dead_code tac_list =
  let rec eliminate_loop tac_list acc =
    match tac_list with
    | [] -> List.rev acc
    | instr :: rest ->
      (match instr with
      | Transfer.TacAssign (dest, _) when String.contains dest 't' && dest.[0] = 't' ->
        (* 检查临时变量是否被后续使用 *)
        if is_variable_used dest rest then
          eliminate_loop rest (instr :: acc)
        else
          eliminate_loop rest acc  (* 删除未使用的临时变量赋值 *)
      | _ ->
        eliminate_loop rest (instr :: acc))
  in
  eliminate_loop tac_list []

(* 主要的优化函数 *)
let optimize (tac_list : Transfer.tac list) : Transfer.tac list =
  (* 1. 常量折叠 *)
  let folded = optimize_constant_folding tac_list in
  (* 2. 死代码消除 *)
  let optimized = eliminate_dead_code folded in
  optimized