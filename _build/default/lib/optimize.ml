open Transfer
open Cfg_gen


(* 常量和变量值的类型 *)
type value =
  | Const of int
  | Unknown

(* 常量表：存储已知的常量值 *)
module ConstMap = Map.Make(String)

(* 判断字符串是否为整数 *)
let is_integer s = 
  try ignore (int_of_string s); true 
  with _ -> false

(* 获取变量或常量的值 *)
let get_value const_map var =
  if is_integer var then
    Const (int_of_string var)
  else
    try ConstMap.find var const_map
    with Not_found -> Unknown

(* 二元运算的常量折叠 *)
let fold_binary_op op v1 v2 =
  match v1, v2 with
  | Const i1, Const i2 ->
    begin match op with
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
    | _ -> Unknown
    end
  | _ -> Unknown

(* 一元运算的常量折叠 *)
let fold_unary_op op v =
  match v with
  | Const i ->
    begin match op with
    | "+" -> Const i
    | "-" -> Const (-i)
    | "!" -> Const (if i = 0 then 1 else 0)
    | _ -> Unknown
    end
  | _ -> Unknown

(* 常量传播：在基本块内查找和替换常量 *)
let propagate_constants (block : Cfg_gen.basic_block) =
  let const_map = ref ConstMap.empty in
  
  (* 第一遍：收集常量赋值信息 *)
  let collect_constants instr =
    match instr with
    | TacAssign (dest, src) ->
        if is_integer src then
          const_map := ConstMap.add dest (Const (int_of_string src)) !const_map
        else
          const_map := ConstMap.remove dest !const_map
    | TacBinOp (dest, _, _, _) | TacUnOp (dest, _, _) ->
        const_map := ConstMap.remove dest !const_map
    | _ -> ()
  in
  
  List.iter collect_constants block.instrs;
  
  (* 第二遍：替换使用常量的地方 *)
  let replace_constants instr =
    match instr with
    | TacAssign (dest, src) ->
        begin match get_value !const_map src with
        | Const i -> TacAssign (dest, string_of_int i)
        | Unknown -> instr
        end
    
    | TacBinOp (dest, src1, op, src2) ->
        let v1 = get_value !const_map src1 in
        let v2 = get_value !const_map src2 in
        begin match v1, v2 with
        | Const _i1, Const _i2 -> 
            let result = fold_binary_op op v1 v2 in
            begin match result with
            | Const i -> TacAssign (dest, string_of_int i)
            | Unknown -> instr
            end
        | Const i1, Unknown -> TacBinOp (dest, string_of_int i1, op, src2)
        | Unknown, Const i2 -> TacBinOp (dest, src1, op, string_of_int i2)
        | Unknown, Unknown -> instr
        end

    | TacUnOp (dest, op, src) ->
        begin match get_value !const_map src with
        | Const i ->
            let result = fold_unary_op op (Const i) in
            begin match result with
            | Const res -> TacAssign (dest, string_of_int res)
            | Unknown -> instr
            end
        | Unknown -> instr
        end

    | TacIfGoto (cond, label) ->
        begin match get_value !const_map cond with
        | Const 0 -> TacComment ("a0", "removed conditional jump", [])
        | Const _ -> TacGoto label
        | Unknown -> instr
        end

    | _ -> instr
  in
  
  { block with instrs = List.map replace_constants block.instrs }

(* 优化单个基本块 *)
let optimize_block (block : Cfg_gen.basic_block) =
  let const_map = ref ConstMap.empty in
  
  (* 优化单条指令 *)
  let fold_constants instr =
    match instr with
    | TacAssign (dest, src) ->
        let v = get_value !const_map src in
        begin match v with
        | Const i -> 
            const_map := ConstMap.add dest v !const_map;
            [TacAssign (dest, string_of_int i)]
        | Unknown -> 
            const_map := ConstMap.remove dest !const_map;
            [instr]
        end

    | TacBinOp (dest, src1, op, src2) ->
        let v1 = get_value !const_map src1 in
        let v2 = get_value !const_map src2 in
        let result = fold_binary_op op v1 v2 in
        begin match result with
        | Const i -> 
            const_map := ConstMap.add dest result !const_map;
            [TacAssign (dest, string_of_int i)]
        | Unknown -> 
            const_map := ConstMap.remove dest !const_map;
            [instr]
        end

     | TacUnOp (dest, op, src) ->
        let v = get_value !const_map src in
        let result = fold_unary_op op v in
        begin match result with
        | Const i -> 
            const_map := ConstMap.add dest result !const_map;
            [TacAssign (dest, string_of_int i)]
        | Unknown -> 
            const_map := ConstMap.remove dest !const_map;
            [instr]
        end

    | TacIfGoto (cond, label) ->
        begin match get_value !const_map cond with
        | Const 0 -> []  (* 条件为假，删除跳转 *)
        | Const _ -> [TacGoto label]  (* 条件为真，转换为无条件跳转 *)
        | Unknown -> [instr]
        end

    | _ -> [instr]
  in

  let folded_blocks =
  (* 对基本块中的每条指令进行优化 *)
  let folded_instrs = 
    List.fold_left (fun acc instr ->
      acc @ fold_constants instr
    ) [] block.instrs
  in
  { block with instrs = folded_instrs }
  in
  propagate_constants folded_blocks

(* 主优化函数 *)
let optimize tac_list =
  let (_cfg, blocks) = Cfg_gen.build_cfg tac_list in
  
  (* 对每个基本块进行优化 *)
  let optimized_blocks = List.map optimize_block blocks in
  
  (* 将优化后的基本块按顺序组合成 tac list *)
  List.fold_left (fun acc block ->
    acc @ block.instrs
  ) [] optimized_blocks