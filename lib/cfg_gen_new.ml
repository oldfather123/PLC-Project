(* CFG生成模块 - 用于将三地址码划分为基本块和控制流图 *)

type identifier = string

type tac =
  | TacAssign of string * string
  | TacBinOp of string * string * string * string
  | TacUnOp of string * string * string
  | TacLabel of string
  | TacGoto of string
  | TacIfGoto of string * string
  | TacParam of string
  | TacCall of string * string * int * string list
  | TacReturn of string option
  | TacComment of string * string * identifier list
  | TacPhi of string * string * string

(* 基本块的数据结构 *)
type basic_block = {
  id: int;
  label: string option;
  instructions: tac list;
  predecessors: int list;
  successors: int list;
  original_position: int; (* 新增：原始位置 *)
}

(* 控制流图类型 *)
type cfg = {
  blocks: (int, basic_block) Hashtbl.t;  (* 基本块映射表 *)
  entry_block: int;                      (* 入口基本块ID *)
  exit_blocks: int list;                 (* 出口基本块ID列表 *)
  function_name: string;                 (* 函数名 *)
}

(* 基本块ID计数器 *)
let block_id_counter = ref 0

(* 生成新的基本块ID *)
let new_block_id () =
  let id = !block_id_counter in
  incr block_id_counter;
  id

(* 重置基本块ID计数器 *)
let reset_block_counter () =
  block_id_counter := 0

(* 判断指令是否为跳转指令（基本块结束指令） *)
let is_terminator = function
  | TacGoto _ -> true
  | TacIfGoto _ -> true
  | TacReturn _ -> true
  | _ -> false

(* 判断指令是否为标签指令（基本块开始指令） *)
let is_label = function
  | TacLabel _ -> true
  | _ -> false

(* 获取标签名 *)
let get_label_name = function
  | TacLabel name -> Some name
  | _ -> None

(* 获取跳转目标标签 *)
let get_jump_targets = function
  | TacGoto label -> [label]
  | TacIfGoto (_, label) -> [label]
  | TacReturn _ -> []
  | _ -> []

(* 查找所有leader指令的位置 *)
let find_leaders (instructions: tac list) : int list =
  let leaders = ref [0] in  (* 第一条指令总是leader *)
  let indexed_instrs = List.mapi (fun i instr -> (i, instr)) instructions in
  
  List.iter (fun (i, instr) ->
    match instr with
    | TacLabel _ -> 
        (* 标签指令是leader *)
        if not (List.mem i !leaders) then
          leaders := i :: !leaders
    | _ when is_terminator instr ->
        (* 跳转指令的下一条指令是leader *)
        if i + 1 < List.length instructions && not (List.mem (i + 1) !leaders) then
          leaders := (i + 1) :: !leaders
    | _ -> ()
  ) indexed_instrs;
  
  List.sort compare !leaders

(* 将指令序列划分为基本块 *)
let partition_into_blocks (instructions: tac list) : (int * string option * tac list * int) list =
  let leaders = find_leaders instructions in
  let indexed_instrs = Array.of_list instructions in
  let blocks = ref [] in
  
  let rec build_blocks = function
    | [] -> ()
    | [start] ->
        (* 最后一个基本块 *)
        let block_instrs = Array.to_list (Array.sub indexed_instrs start (Array.length indexed_instrs - start)) in
        let label = get_label_name (List.hd block_instrs) in
        let block_id = new_block_id () in
        blocks := (block_id, label, block_instrs, start) :: !blocks
    | start :: (next :: _ as rest) ->
        (* 中间的基本块 *)
        let length = next - start in
        let block_instrs = Array.to_list (Array.sub indexed_instrs start length) in
        let label = get_label_name (List.hd block_instrs) in
        let block_id = new_block_id () in
        blocks := (block_id, label, block_instrs, start) :: !blocks;
        build_blocks rest
  in
  
  build_blocks leaders;
  List.rev !blocks

(* 构建标签到基本块ID的映射 *)
let build_label_map (blocks: (int * string option * tac list) list) : (string, int) Hashtbl.t =
  let label_map = Hashtbl.create 32 in
  List.iter (fun (block_id, label_opt, _) ->
    match label_opt with
    | Some label -> Hashtbl.add label_map label block_id
    | None -> ()
  ) blocks;
  label_map

(* 计算基本块的后继关系 *)
let compute_successors (blocks: (int * string option * tac list) list) (label_map: (string, int) Hashtbl.t) 
    : (int * int list) list =
  List.map (fun (block_id, _, instrs) ->
    if instrs = [] then
      (block_id, [])
    else
      let last_instr = List.hd (List.rev instrs) in
      let successors = match last_instr with
        | TacGoto label ->
            (try [Hashtbl.find label_map label] with Not_found -> [])
        | TacIfGoto (_, label) ->
            (* 条件跳转有两个后继：跳转目标和下一个基本块 *)
            let jump_target = try [Hashtbl.find label_map label] with Not_found -> [] in
            let next_block = 
              try 
                let next_id = List.find (fun (id, _, _) -> id > block_id) blocks |> fun (id, _, _) -> id in
                [next_id]
              with Not_found -> []
            in
            jump_target @ next_block
        | TacReturn _ -> 
            (* return语句没有后继 *)
            []
        | _ ->
            (* 非跳转指令（包括注释指令），检查是否还有后续基本块 *)
            try 
              let next_id = List.find (fun (id, _, _) -> id > block_id) blocks |> fun (id, _, _) -> id in
              [next_id]
            with Not_found -> []
      in
      (block_id, successors)
  ) blocks

(* 计算基本块的前驱关系 *)
let compute_predecessors (successor_map: (int * int list) list) : (int, int list) Hashtbl.t =
  let pred_map = Hashtbl.create 32 in
  
  (* 初始化所有基本块的前驱列表 *)
  List.iter (fun (block_id, _) ->
    Hashtbl.add pred_map block_id []
  ) successor_map;
  
  (* 根据后继关系计算前驱关系 *)
  List.iter (fun (block_id, successors) ->
    List.iter (fun succ_id ->
      let current_preds = try Hashtbl.find pred_map succ_id with Not_found -> [] in
      Hashtbl.replace pred_map succ_id (block_id :: current_preds)
    ) successors
  ) successor_map;
  
  pred_map

(* 创建基本块 *)
let create_basic_block (block_id: int) (label: string option) (instrs: tac list) 
    (preds: int list) (succs: int list) (original_pos: int) : basic_block =
  {
    id = block_id;
    label = label;
    instructions = instrs;
    predecessors = preds;
    successors = succs;
    original_position = original_pos;
  }

(* 找到出口基本块 *)
let find_exit_blocks (blocks: (int * string option * tac list) list) : int list =
  List.fold_left (fun acc (block_id, _, instrs) ->
    if instrs = [] then acc
    else
      let last_instr = List.hd (List.rev instrs) in
      match last_instr with
      | TacReturn _ -> block_id :: acc
      | _ -> acc
  ) [] blocks

(* 死代码消除和CFG优化 *)

(* 检查基本块是否只包含无条件跳转到空块 *)
let is_useless_jump_block (block: basic_block) (blocks: (int, basic_block) Hashtbl.t) : bool =
  match block.instructions with
  | [TacGoto _] ->
      (* 只有一条无条件跳转指令 *)
      (match block.successors with
      | [succ_id] ->
          (try
            let succ_block = Hashtbl.find blocks succ_id in
            (* 检查目标块是否为空或只包含标签 *)
            (match succ_block.instructions with
            | [] -> true
            | [TacLabel _] -> true
            | _ -> false)
          with Not_found -> false)
      | _ -> false)
  | _ -> false

(* 检查基本块是否为空块（只包含标签或为空） *)
let is_empty_block (block: basic_block) : bool =
  match block.instructions with
  | [] -> true
  | [TacLabel _] -> true
  | _ -> false

(* 移除死代码基本块 - 迭代直到收敛 *)
let remove_dead_blocks (cfg: cfg) : cfg =
  let rec remove_iteration cfg_input =
    let blocks = Hashtbl.copy cfg_input.blocks in
    let to_remove = ref [] in
    let changed = ref false in
    
    (* 1. 找出没有前驱的基本块（除了entry block） *)
    Hashtbl.iter (fun block_id block ->
      if block_id <> cfg_input.entry_block && block.predecessors = [] then (
        to_remove := block_id :: !to_remove;
        changed := true
      )
    ) blocks;
    
    (* 2. 找出只包含无条件跳转到空块的基本块 *)
    Hashtbl.iter (fun block_id block ->
      if not (List.mem block_id !to_remove) && is_useless_jump_block block blocks then (
        to_remove := block_id :: !to_remove;
        changed := true
      )
    ) blocks;
    
    (* 3. 找出空块且没有前驱的基本块 *)
    Hashtbl.iter (fun block_id block ->
      if not (List.mem block_id !to_remove) && 
         block_id <> cfg_input.entry_block && 
         block.predecessors = [] && 
         is_empty_block block then (
        to_remove := block_id :: !to_remove;
        changed := true
      )
    ) blocks;
    
    if not !changed then
      cfg_input  (* 没有变化，返回当前CFG *)
    else (
      (* 移除标记的基本块 *)
      List.iter (fun block_id ->
        Hashtbl.remove blocks block_id
      ) !to_remove;
      
      (* 更新前驱后继关系 *)
      let updated_blocks = Hashtbl.create (Hashtbl.length blocks) in
      Hashtbl.iter (fun block_id block ->
        let new_predecessors = List.filter (fun pred_id -> 
          not (List.mem pred_id !to_remove)
        ) block.predecessors in
        let new_successors = List.filter (fun succ_id -> 
          not (List.mem succ_id !to_remove)
        ) block.successors in
        let updated_block = {
          block with 
          predecessors = new_predecessors;
          successors = new_successors;
        } in
        Hashtbl.add updated_blocks block_id updated_block
      ) blocks;
      
      (* 更新出口基本块列表 *)
      let new_exit_blocks = List.filter (fun exit_id ->
        not (List.mem exit_id !to_remove)
      ) cfg_input.exit_blocks in
      
      let new_cfg = {
        cfg_input with
        blocks = updated_blocks;
        exit_blocks = new_exit_blocks;
      } in
      
      (* 递归调用，继续移除死代码 *)
      remove_iteration new_cfg
    )
  in
  remove_iteration cfg

(* 优化控制流：合并可以合并的基本块 *)
let optimize_control_flow (cfg: cfg) : cfg =
  let blocks = Hashtbl.copy cfg.blocks in
  let merged = ref [] in
  
  Hashtbl.iter (fun block_id block ->
    (* 如果当前块只有一个后继，且后继块只有当前块作为前驱 *)
    match block.successors with
    | [succ_id] when not (List.mem block_id !merged) ->
        (try
          let succ_block = Hashtbl.find blocks succ_id in
          if succ_block.predecessors = [block_id] && 
             not (List.mem succ_id !merged) &&
             not (List.exists is_terminator block.instructions) then
            (* 可以合并 *)
            let merged_instructions = 
              block.instructions @ 
              (List.filter (function TacLabel _ -> false | _ -> true) succ_block.instructions)
            in
            let merged_block = {
              id = block_id;
              label = block.label;
              instructions = merged_instructions;
              predecessors = block.predecessors;
              successors = succ_block.successors;
              original_position = block.original_position;
            } in
            Hashtbl.replace blocks block_id merged_block;
            Hashtbl.remove blocks succ_id;
            merged := succ_id :: !merged;
            
            (* 更新其他块的前驱后继关系 *)
            Hashtbl.iter (fun other_id other_block ->
              if other_id <> block_id then
                let new_predecessors = List.map (fun pred_id ->
                  if pred_id = succ_id then block_id else pred_id
                ) other_block.predecessors in
                let new_successors = List.map (fun s_id ->
                  if s_id = succ_id then block_id else s_id
                ) other_block.successors in
                if new_predecessors <> other_block.predecessors || 
                   new_successors <> other_block.successors then
                  Hashtbl.replace blocks other_id {
                    other_block with
                    predecessors = new_predecessors;
                    successors = new_successors;
                  }
            ) blocks
        with Not_found -> ())
    | _ -> ()
  ) blocks;
  
  (* 更新出口基本块列表 *)
  let new_exit_blocks = List.map (fun exit_id ->
    if List.mem exit_id !merged then
      (* 找到合并到哪个块了，简化处理：如果被合并就移除 *)
      exit_id
    else exit_id
  ) cfg.exit_blocks |> List.filter (fun exit_id ->
    Hashtbl.mem blocks exit_id
  ) |> List.sort_uniq compare in
  
  {
    cfg with
    blocks = blocks;
    exit_blocks = new_exit_blocks;
  }

(* 重新分配基本块ID，使其连续 *)
let renumber_blocks (cfg: cfg) : cfg =
  let old_to_new_id = Hashtbl.create (Hashtbl.length cfg.blocks) in
  let new_blocks = Hashtbl.create (Hashtbl.length cfg.blocks) in
  let new_id_counter = ref 0 in
  
  (* 首先为entry block分配ID 0 *)
  Hashtbl.add old_to_new_id cfg.entry_block 0;
  incr new_id_counter;
  
  (* 为其他块分配连续ID *)
  Hashtbl.iter (fun old_id _block ->
    if old_id <> cfg.entry_block then (
      Hashtbl.add old_to_new_id old_id !new_id_counter;
      incr new_id_counter
    )
  ) cfg.blocks;
  
  (* 创建新的基本块，更新ID和前驱后继关系 *)
  Hashtbl.iter (fun old_id block ->
    let new_id = Hashtbl.find old_to_new_id old_id in
    let new_predecessors = List.map (fun pred_id ->
      Hashtbl.find old_to_new_id pred_id
    ) block.predecessors in
    let new_successors = List.map (fun succ_id ->
      Hashtbl.find old_to_new_id succ_id
    ) block.successors in
    let new_block = {
      id = new_id;
      label = block.label;
      instructions = block.instructions;
      predecessors = new_predecessors;
      successors = new_successors;
      original_position = block.original_position;
    } in
    Hashtbl.add new_blocks new_id new_block
  ) cfg.blocks;
  
  (* 更新出口基本块列表 *)
  let new_exit_blocks = List.map (fun old_exit_id ->
    Hashtbl.find old_to_new_id old_exit_id
  ) cfg.exit_blocks |> List.sort compare in
  
  {
    cfg with
    blocks = new_blocks;
    entry_block = 0;  (* entry block总是0 *)
    exit_blocks = new_exit_blocks;
  }

(* 从三地址码构建控制流图 *)
let build_cfg (function_name: string) (instructions: tac list) : cfg =
  (* 重置基本块计数器 *)
  reset_block_counter ();
  
  (* 保留所有指令，包括注释指令 *)
  let effective_instrs = instructions in
  
  if effective_instrs = [] then
    (* 空函数的情况 *)
    let empty_block_id = new_block_id () in
    let empty_block = create_basic_block empty_block_id None [TacReturn None] [] [] 0 in
    let blocks = Hashtbl.create 1 in
    Hashtbl.add blocks empty_block_id empty_block;
    {
      blocks = blocks;
      entry_block = empty_block_id;
      exit_blocks = [empty_block_id];
      function_name = function_name;
    }
  else
    (* 正常函数的处理 *)
    let block_list = partition_into_blocks effective_instrs in
    let label_map = build_label_map (List.map (fun (id, label, instrs, _) -> (id, label, instrs)) block_list) in
    let successor_pairs = compute_successors (List.map (fun (id, label, instrs, _) -> (id, label, instrs)) block_list) label_map in
    let pred_map = compute_predecessors successor_pairs in
    
    (* 创建基本块映射表 *)
    let blocks = Hashtbl.create (List.length block_list) in
    List.iter (fun (block_id, label, instrs, original_pos) ->
      let preds = try Hashtbl.find pred_map block_id with Not_found -> [] in
      let succs = try List.assoc block_id successor_pairs with Not_found -> [] in
      let block = create_basic_block block_id label instrs preds succs original_pos in
      Hashtbl.add blocks block_id block
    ) block_list;
    
    (* 确定入口和出口基本块 *)
    let entry_block = List.hd block_list |> fun (id, _, _, _) -> id in
    let exit_blocks = find_exit_blocks (List.map (fun (id, label, instrs, _) -> (id, label, instrs)) block_list) in
    
    let initial_cfg = {
      blocks = blocks;
      entry_block = entry_block;
      exit_blocks = exit_blocks;
      function_name = function_name;
    } in
    
    (* 应用死代码消除和控制流优化 *)
    let optimized_cfg = initial_cfg |> remove_dead_blocks |> optimize_control_flow in
    
    (* 重新分配连续的基本块ID *)
    let final_cfg = renumber_blocks optimized_cfg in
    final_cfg

(* 从函数TAC列表构建多个CFG *)
let build_cfgs_from_functions (tac_list: tac list) : cfg list =
  let cfgs = ref [] in
  let current_function = ref None in
  let current_instrs = ref [] in
  
  List.iter (fun instr ->
    match instr with
    | TacComment (_, func_comment, _) when String.length func_comment > 8 && 
                                           String.sub func_comment 0 8 = "function" ->
        (* 遇到新函数，保存前一个函数的CFG *)
        (match !current_function with
        | Some func_name when !current_instrs <> [] ->
            let cfg = build_cfg func_name (List.rev !current_instrs) in
            cfgs := cfg :: !cfgs
        | _ -> ());
        
        (* 开始新函数，将函数标记注释也包含在指令中 *)
        let func_name = String.sub func_comment 9 (String.length func_comment - 9) in
        current_function := Some func_name;
        current_instrs := [instr]  (* 包含函数标记注释 *)
    | _ ->
        (* 收集当前函数的指令 *)
        current_instrs := instr :: !current_instrs
  ) tac_list;
  
  (* 处理最后一个函数 *)
  (match !current_function with
  | Some func_name when !current_instrs <> [] ->
      let cfg = build_cfg func_name (List.rev !current_instrs) in
      cfgs := cfg :: !cfgs
  | _ -> ());
  
  List.rev !cfgs

(* 提供给外部调用的接口函数，处理Transfer.tac类型 *)
let build_cfgs_from_transfer_tac transfer_tac_list =
  (* 这里我们需要一个转换函数，但由于类型相同，实际上可以直接使用 *)
  (* 为了类型安全，我们使用Obj.magic进行转换，因为两个tac类型定义完全相同 *)
  let converted_list = List.map (Obj.magic : 'a -> tac) transfer_tac_list in
  build_cfgs_from_functions converted_list

(* ==================== 重新设计的优化模块 ==================== *)

(* 变量版本管理 *)
module VariableVersioning = struct
  type var_info = {
    base_name: string;      (* 基础变量名，如 "n" *)
    version: int;           (* 版本号 *)
    scope: string;          (* 作用域，如 "control_structures" *)
  }
  
  (* 解析SSA变量名 *)
  let parse_ssa_var var_name =
    try
      let parts = String.split_on_char '-' var_name in
      match parts with
      | [base; "Control"; version_str; scope] ->
          let version = int_of_string version_str in
          Some { base_name = base; version = version; scope = scope }
      | _ -> None
    with _ -> None
  
  (* 获取变量的基础名 *)
  let get_base_name var_name =
    match parse_ssa_var var_name with
    | Some info -> info.base_name
    | None -> var_name
  
  (* 获取变量版本 *)
  let get_version var_name =
    match parse_ssa_var var_name with
    | Some info -> info.version
    | None -> 0
  
  (* 比较两个变量是否是同一个基础变量 *)
  let same_base_var var1 var2 =
    (get_base_name var1) = (get_base_name var2)
  
  (* 选择更新的版本 *)
  let prefer_newer_version var1 var2 =
    if same_base_var var1 var2 then
      if get_version var1 >= get_version var2 then var1 else var2
    else var1
  
  (* 比较两个变量的版本：返回正数表示var1较新，负数表示var2较新，0表示相同 *)
  let compare_versions var1 var2 =
    if same_base_var var1 var2 then
      (get_version var1) - (get_version var2)
    else 0
end

(* 优化环境 - 重新设计 *)
type opt_env = {
  const_map: (string, int) Hashtbl.t;          (* 常量传播映射 *)
  copy_map: (string, string) Hashtbl.t;        (* 复制传播映射 *)
  expr_map: (string, string) Hashtbl.t;        (* 表达式消除映射 *)
  live_vars: (string, bool) Hashtbl.t;         (* 活跃变量集合 *)
}

(* 创建空的优化环境 *)
let create_opt_env () = {
  const_map = Hashtbl.create 32;
  copy_map = Hashtbl.create 32;
  expr_map = Hashtbl.create 32;
  live_vars = Hashtbl.create 32;
}

(* 检查是否是SSA变量（包含Control的变量不进行复制传播） *)
let is_ssa_variable var =
  String.contains var '-' && String.contains var 'C'

(* 智能的变量解析 - 平衡激进性和正确性 *)
let resolve_variable env var =
  let rec resolve_recursive var visited =
    if List.mem var visited then var  (* 避免循环引用 *)
    else
      let visited' = var :: visited in
      (* 对于SSA变量，要更加谨慎 *)
      if is_ssa_variable var then (
        (* 首先检查常量传播 *)
        (try 
          string_of_int (Hashtbl.find env.const_map var)
        with Not_found ->
          (* 对SSA变量的复制传播要谨慎，只在简单情况下进行 *)
          try 
            let next_var = Hashtbl.find env.copy_map var in
            if next_var = var then var  (* 避免自引用 *)
            else if is_ssa_variable next_var then var  (* 避免SSA间的复杂传播 *)
            else resolve_recursive next_var visited'
          with Not_found -> var)
      ) else (
        (* 对非SSA变量可以积极传播 *)
        (try 
          string_of_int (Hashtbl.find env.const_map var)
        with Not_found ->
          try 
            let next_var = Hashtbl.find env.copy_map var in
            if next_var = var then var  (* 避免自引用 *)
            else resolve_recursive next_var visited'
          with Not_found -> var)
      )
  in
  resolve_recursive var []

(* 计算二元操作 *)
let fold_binary_op op left right =
  try
    let l_val = int_of_string left in
    let r_val = int_of_string right in
    match op with
    | "+" -> Some (string_of_int (l_val + r_val))
    | "-" -> Some (string_of_int (l_val - r_val))
    | "*" -> Some (string_of_int (l_val * r_val))
    | "/" when r_val <> 0 -> Some (string_of_int (l_val / r_val))
    | "%" when r_val <> 0 -> Some (string_of_int (l_val mod r_val))
    | ">" -> Some (if l_val > r_val then "1" else "0")
    | "<" -> Some (if l_val < r_val then "1" else "0")
    | ">=" -> Some (if l_val >= r_val then "1" else "0")
    | "<=" -> Some (if l_val <= r_val then "1" else "0")
    | "==" -> Some (if l_val = r_val then "1" else "0")
    | "!=" -> Some (if l_val <> r_val then "1" else "0")
    | _ -> None
  with _ -> None

(* 计算一元操作 *)
let fold_unary_op op operand =
  try
    let val_int = int_of_string operand in
    match op with
    | "!" -> Some (if val_int = 0 then "1" else "0")
    | "-" -> Some (string_of_int (-val_int))
    | "+" -> Some operand
    | _ -> None
  with _ -> None

(* 平衡的优化指令函数 - 在激进优化和正确性之间取得平衡 *)
let optimize_instruction_improved env instr =
  match instr with
  | TacAssign (dest, src) ->
      let resolved_src = resolve_variable env src in
      (* 如果源已经是个常量，进行常量传播 *)
      (try
        let const_val = int_of_string resolved_src in
        (* 对所有变量都进行常量传播 *)
        Hashtbl.replace env.const_map dest const_val;
        TacAssign (dest, resolved_src)
      with _ ->
        (* 复制传播 - 对SSA变量要谨慎 *)
        if resolved_src <> src then (
          if not (is_ssa_variable dest) || not (is_ssa_variable resolved_src) then (
            Hashtbl.replace env.copy_map dest resolved_src
          )
        );
        TacAssign (dest, resolved_src))
  
  | TacBinOp (dest, left, op, right) ->
      let resolved_left = resolve_variable env left in
      let resolved_right = resolve_variable env right in
      
      (* 激进的常量折叠 *)
      (match fold_binary_op op resolved_left resolved_right with
      | Some result ->
          (try
            let const_val = int_of_string result in
            (* 对所有变量都进行常量传播 *)
            Hashtbl.replace env.const_map dest const_val
          with _ -> ());
          TacAssign (dest, result)
      | None ->
          (* 激进的公共子表达式消除 *)
          let expr_key = resolved_left ^ " " ^ op ^ " " ^ resolved_right in
          (try
            let existing_var = Hashtbl.find env.expr_map expr_key in
            (* 直接用已有变量替换，对所有变量类型都适用 *)
            Hashtbl.replace env.copy_map dest existing_var;
            TacAssign (dest, existing_var)
          with Not_found ->
            Hashtbl.replace env.expr_map expr_key dest;
            TacBinOp (dest, resolved_left, op, resolved_right)))
  
  | TacUnOp (dest, op, operand) ->
      let resolved_operand = resolve_variable env operand in
      
      (* 尝试常量折叠 *)
      (match fold_unary_op op resolved_operand with
      | Some result ->
          TacAssign (dest, result)
      | None ->
          TacUnOp (dest, op, resolved_operand))
  
  | TacIfGoto (cond, label) ->
      let resolved_cond = resolve_variable env cond in
      TacIfGoto (resolved_cond, label)
  
  | TacParam operand ->
      let resolved_operand = resolve_variable env operand in
      TacParam resolved_operand
  
  | TacReturn (Some operand) ->
      let resolved_operand = resolve_variable env operand in
      TacReturn (Some resolved_operand)
  
  | TacCall (dest, func, argc, args) ->
      let resolved_args = List.map (resolve_variable env) args in
      TacCall (dest, func, argc, resolved_args)
  
  | _ -> instr  (* 其他指令保持不变 *)

(* 激进的多轮指令优化 - 深度传播和简化 *)
let optimize_instructions_improved instrs =
  let env = create_opt_env () in
  let optimized = ref [] in
  
  List.iter (fun instr ->
    let opt_instr = optimize_instruction_improved env instr in
    optimized := opt_instr :: !optimized
  ) instrs;
  
  let first_pass = List.rev !optimized in
  
  (* 第二轮：表达式内联和链式替换 *)
  let perform_aggressive_inlining instructions =
    let substitutions = Hashtbl.create 32 in
    
    (* 收集所有简单赋值，建立替换表 *)
    List.iter (function
      | TacAssign (dest, src) when not (String.contains src '+' || String.contains src '*' || String.contains src '-') ->
          Hashtbl.replace substitutions dest src
      | _ -> ()
    ) instructions;
    
    (* 递归替换 *)
    let rec substitute var =
      try
        let replacement = Hashtbl.find substitutions var in
        if replacement = var then var
        else substitute replacement
      with Not_found -> var
    in
    
    (* 应用替换并过滤冗余赋值 *)
    let result = ref [] in
    List.iter (function
      | TacAssign (dest, src) ->
          let final_src = substitute src in
          if dest <> final_src then  (* 避免自赋值 *)
            result := TacAssign (dest, final_src) :: !result
      | TacBinOp (dest, left, op, right) ->
          let final_left = substitute left in
          let final_right = substitute right in
          result := TacBinOp (dest, final_left, op, final_right) :: !result
      | TacUnOp (dest, op, operand) ->
          let final_operand = substitute operand in
          result := TacUnOp (dest, op, final_operand) :: !result
      | TacReturn (Some operand) ->
          let final_operand = substitute operand in
          result := TacReturn (Some final_operand) :: !result
      | TacParam operand ->
          let final_operand = substitute operand in
          result := TacParam final_operand :: !result
      | TacIfGoto (cond, label) ->
          let final_cond = substitute cond in
          result := TacIfGoto (final_cond, label) :: !result
      | other -> result := other :: !result
    ) instructions;
    
    List.rev !result
  in
  
  let inlined = perform_aggressive_inlining first_pass in
  
  (* 第三轮：简化表达式合并 - 只做简单的变量替换 *)
  let perform_expression_merging instructions =
    let simple_assigns = Hashtbl.create 32 in
    
    (* 收集简单赋值 *)
    List.iter (function
      | TacAssign (dest, src) when not (String.contains src '+' || String.contains src '*') ->
          Hashtbl.replace simple_assigns dest src
      | _ -> ()
    ) instructions;
    
    (* 生成优化后的指令，替换变量 *)
    let result = ref [] in
    
    List.iter (function
      | TacBinOp (dest, left, op, right) ->
          let final_left = 
            if Hashtbl.mem simple_assigns left then
              Hashtbl.find simple_assigns left
            else left
          in
          let final_right = 
            if Hashtbl.mem simple_assigns right then
              Hashtbl.find simple_assigns right
            else right
          in
          result := TacBinOp (dest, final_left, op, final_right) :: !result
      | TacAssign (_, src) when Hashtbl.mem simple_assigns src ->
          (* 跳过冗余的简单赋值 *)
          ()
      | other -> result := other :: !result
    ) instructions;
    
    List.rev !result
  in
  
  let merged = perform_expression_merging inlined in
  
  (* 第四轮：再次进行常量传播 *)
  let env4 = create_opt_env () in
  let fourth_optimized = ref [] in
  
  List.iter (fun instr ->
    let opt_instr = optimize_instruction_improved env4 instr in
    fourth_optimized := opt_instr :: !fourth_optimized
  ) merged;
  
  List.rev !fourth_optimized

(* 超激进的死代码消除 - 专门针对线性代码优化 *)
let remove_dead_code_improved instructions =
  let used = Hashtbl.create 32 in
  let ssa_vars = Hashtbl.create 32 in
  let assignments = Hashtbl.create 32 in
  let has_control_flow = ref false in
  
  (* 检查是否包含控制流指令 *)
  List.iter (function
    | TacIfGoto _ | TacGoto _ | TacLabel _ -> has_control_flow := true
    | _ -> ()
  ) instructions;
  
  (* 收集所有SSA变量的版本信息 *)
  List.iter (function
    | TacAssign (dest, _) | TacBinOp (dest, _, _, _) | TacUnOp (dest, _, _) -> 
        if is_ssa_variable dest then (
          let base_name = VariableVersioning.get_base_name dest in
          let versions = try Hashtbl.find ssa_vars base_name with Not_found -> [] in
          Hashtbl.replace ssa_vars base_name (dest :: versions);
          Hashtbl.replace assignments dest true
        ) else (
          Hashtbl.replace assignments dest true
        )
    | _ -> ()
  ) instructions;
  
  (* 标记直接使用的变量（return、param、条件等） *)
  List.iter (function
    | TacReturn (Some src) -> Hashtbl.replace used src true
    | TacParam src -> Hashtbl.replace used src true
    | TacIfGoto (cond, _) -> Hashtbl.replace used cond true
    | TacCall (_, _, _, args) -> List.iter (fun arg -> Hashtbl.replace used arg true) args
    | _ -> ()
  ) instructions;
  
  (* 智能SSA变量分析：区分必要和非必要的SSA赋值 *)
  let preserve_ssa_definitions () =
    if !has_control_flow then (
      (* 有控制流时：分析哪些SSA变量真正被后续使用 *)
      
      (* 首先标记return中使用的变量 *)
      List.iter (function
        | TacReturn (Some var) when is_ssa_variable var ->
            Hashtbl.replace used var true
        | TacReturn (Some var) -> Hashtbl.replace used var true
        | _ -> ()
      ) instructions;
      
      (* 然后进行反向依赖分析 *)
      let rec mark_dependencies var =
        if not (Hashtbl.mem used var) then (
          Hashtbl.replace used var true;
          (* 查找定义这个变量的指令 *)
          List.iter (function
            | TacAssign (dest, src) when dest = var ->
                mark_dependencies src
            | TacBinOp (dest, src1, _, src2) when dest = var ->
                mark_dependencies src1; mark_dependencies src2
            | TacUnOp (dest, _, src) when dest = var ->
                mark_dependencies src
            | _ -> ()
          ) instructions
        )
      in
      
      (* 标记所有被使用变量的依赖链 *)
      List.iter (function
        | TacReturn (Some var) -> mark_dependencies var
        | TacParam var -> mark_dependencies var
        | TacIfGoto (cond, _) -> mark_dependencies cond
        | TacCall (_, _, _, args) -> List.iter mark_dependencies args
        | _ -> ()
      ) instructions;
      
      (* 对于SSA变量，我们需要特别保护那些可能在不同控制流路径中被使用的版本 *)
      List.iter (function
        | TacAssign (dest, _) when is_ssa_variable dest ->
            (* 检查这个SSA变量是否在后续被引用 *)
            let is_referenced = List.exists (function
              | TacReturn (Some var) when var = dest -> true
              | TacAssign (_, src) when src = dest -> true
              | TacBinOp (_, src1, _, src2) when src1 = dest || src2 = dest -> true
              | TacUnOp (_, _, src) when src = dest -> true
              | TacParam src when src = dest -> true
              | TacIfGoto (cond, _) when cond = dest -> true
              | TacCall (_, _, _, args) when List.mem dest args -> true
              | _ -> false
            ) instructions in
            if is_referenced || Hashtbl.mem used dest then
              Hashtbl.replace used dest true
        | _ -> ()
      ) instructions
    ) else (
      (* 线性代码时只保留真正被return使用的变量 *)
      List.iter (function
        | TacReturn (Some var) -> Hashtbl.replace used var true
        | _ -> ()
      ) instructions
    )
  in
  
  preserve_ssa_definitions ();
  
  (* 传播依赖关系 *)
  let mark_dependencies () =
    let changed = ref true in
    while !changed do
      changed := false;
      List.iter (function
        | TacAssign (dest, src) -> 
            if Hashtbl.mem used dest && not (Hashtbl.mem used src) then (
              Hashtbl.replace used src true;
              changed := true
            )
        | TacBinOp (dest, src1, _, src2) -> 
            if Hashtbl.mem used dest then (
              if not (Hashtbl.mem used src1) then (
                Hashtbl.replace used src1 true;
                changed := true
              );
              if not (Hashtbl.mem used src2) then (
                Hashtbl.replace used src2 true;
                changed := true
              )
            )
        | TacUnOp (dest, _, src) -> 
            if Hashtbl.mem used dest && not (Hashtbl.mem used src) then (
              Hashtbl.replace used src true;
              changed := true
            )
        | _ -> ()
      ) instructions
    done
  in
  
  mark_dependencies ();
  
  (* 额外步骤：确保所有被使用的临时变量的定义都被标记 *)
  let mark_temp_var_definitions () =
    List.iter (function
      | TacAssign (_, src) when Hashtbl.mem used src ->
          List.iter (function
            | TacBinOp (dest, _, _, _) when dest = src -> Hashtbl.replace used dest true
            | TacUnOp (dest, _, _) when dest = src -> Hashtbl.replace used dest true
            | TacAssign (dest, _) when dest = src -> Hashtbl.replace used dest true
            | _ -> ()
          ) instructions
      | _ -> ()
    ) instructions
  in
  
  mark_temp_var_definitions ();
  mark_dependencies ();
  
  (* 智能过滤：线性代码更激进，复杂控制流保守 *)
  List.filter (function
    | TacAssign (dest, _) -> 
        if !has_control_flow then (
          (* 有控制流时：保留被使用的变量或SSA变量的关键赋值 *)
          Hashtbl.mem used dest || 
          (is_ssa_variable dest && (
            Hashtbl.mem used dest ||
            List.exists (function
              | TacReturn (Some var) when var = dest -> true
              | TacAssign (_, src) when src = dest -> true
              | TacBinOp (_, src1, _, src2) when src1 = dest || src2 = dest -> true
              | TacUnOp (_, _, src) when src = dest -> true
              | TacParam src when src = dest -> true
              | TacIfGoto (cond, _) when cond = dest -> true
              | TacCall (_, _, _, args) when List.mem dest args -> true
              | _ -> false
            ) instructions
          ))
        ) else (
          (* 线性代码时激进 *)
          Hashtbl.mem used dest
        )
    | TacBinOp (dest, _, _, _) -> 
        if !has_control_flow then (
          (* 有控制流时：保留被使用的变量或SSA变量的关键赋值 *)
          Hashtbl.mem used dest ||
          (is_ssa_variable dest && (
            Hashtbl.mem used dest ||
            List.exists (function
              | TacReturn (Some var) when var = dest -> true
              | TacAssign (_, src) when src = dest -> true
              | TacBinOp (_, src1, _, src2) when src1 = dest || src2 = dest -> true
              | TacUnOp (_, _, src) when src = dest -> true
              | TacParam src when src = dest -> true
              | TacIfGoto (cond, _) when cond = dest -> true
              | TacCall (_, _, _, args) when List.mem dest args -> true
              | _ -> false
            ) instructions
          )) ||
          (List.exists (function
            | TacAssign (_, src) when src = dest -> true
            | TacBinOp (_, src1, _, src2) when src1 = dest || src2 = dest -> true
            | TacUnOp (_, _, src) when src = dest -> true
            | TacReturn (Some src) when src = dest -> true
            | TacParam src when src = dest -> true
            | TacIfGoto (cond, _) when cond = dest -> true
            | _ -> false
          ) instructions)
        ) else (
          (* 线性代码时激进 *)
          Hashtbl.mem used dest ||
          (List.exists (function
            | TacAssign (_, src) when src = dest -> true
            | TacBinOp (_, src1, _, src2) when src1 = dest || src2 = dest -> true
            | TacUnOp (_, _, src) when src = dest -> true
            | TacReturn (Some src) when src = dest -> true
            | TacParam src when src = dest -> true
            | _ -> false
          ) instructions)
        )
    | TacUnOp (dest, _, _) -> 
        Hashtbl.mem used dest ||
        (List.exists (function
          | TacAssign (_, src) when src = dest -> true
          | TacBinOp (_, src1, _, src2) when src1 = dest || src2 = dest -> true
          | TacUnOp (_, _, src) when src = dest -> true
          | TacReturn (Some src) when src = dest -> true
          | TacParam src when src = dest -> true
          | TacIfGoto (cond, _) when cond = dest -> true
          | _ -> false
        ) instructions)
    | TacCall (_, _, _, _) -> 
        true  (* 函数调用保留 *)
    | _ -> true (* 保留控制流指令 *)
  ) instructions

(* 应用多轮优化直到收敛 *)
let optimize_instructions_iterative instrs max_iterations =
  let rec optimize_until_convergence current_instrs iteration =
    if iteration >= max_iterations then
      current_instrs
    else
      let optimized_instrs = optimize_instructions_improved current_instrs in
      
      (* 检查是否收敛（指令数量不变） *)
      if List.length current_instrs = List.length optimized_instrs then
        optimized_instrs  (* 收敛 *)
      else
        optimize_until_convergence optimized_instrs (iteration + 1)
  in
  
  optimize_until_convergence instrs 0

(* 在基本块中跟踪SSA变量的最新版本 *)
let track_ssa_versions instructions =
  let version_map = Hashtbl.create 32 in
  
  List.iter (function
    | TacAssign (dest, _) ->
        (match VariableVersioning.parse_ssa_var dest with
         | Some {base_name; scope; version} ->
             let key = base_name ^ "-" ^ scope in
             (try
               let current_version = Hashtbl.find version_map key in
               if version > current_version then
                 Hashtbl.replace version_map key version
             with Not_found ->
               Hashtbl.add version_map key version)
         | None -> ())
    | _ -> ()
  ) instructions;
  
  version_map

(* 找到变量的最新版本 *)
let find_latest_version version_map var_name =
  match VariableVersioning.parse_ssa_var var_name with
  | Some {base_name; scope; _} ->
      let key = base_name ^ "-" ^ scope in
      (try
        let latest_version = Hashtbl.find version_map key in
        base_name ^ "-Control-" ^ (string_of_int latest_version) ^ "-" ^ scope
      with Not_found -> var_name)
  | None -> var_name

(* 优化基本块 - 添加SSA版本跟踪 *)
let optimize_basic_block_with_ssa_tracking block =
  (* 先执行常规优化 *)
  let optimized_instructions = optimize_instructions_iterative block.instructions 6 in
  
  (* 然后跟踪SSA版本并修复return语句 *)
  let version_map = track_ssa_versions optimized_instructions in
  let final_instructions = List.map (function
    | TacReturn (Some operand) ->
        let latest_operand = find_latest_version version_map operand in
        TacReturn (Some latest_operand)
    | instr -> instr
  ) optimized_instructions in
  
  { block with instructions = final_instructions }

(* 重新设计CFG到指令转换 - 按原始位置排序 *)
let cfg_to_tac_instructions_correct cfg =
  (* 收集所有基本块，按原始位置排序 *)
  let blocks_with_pos = ref [] in
  
  Hashtbl.iter (fun _ block ->
    blocks_with_pos := (block.original_position, block) :: !blocks_with_pos
  ) cfg.blocks;
  
  (* 按原始位置排序 *)
  let sorted_blocks = List.sort (fun (pos1, _) (pos2, _) -> compare pos1 pos2) !blocks_with_pos in
  
  (* 提取所有指令 *)
  let result = ref [] in
  List.iter (fun (_, block) ->
    result := !result @ block.instructions
  ) sorted_blocks;
  
  !result

(* 优化整个CFG - 添加全局SSA版本跟踪 *)
let optimize_cfg cfg =
  let optimized_blocks = Hashtbl.create (Hashtbl.length cfg.blocks) in
  
  (* 首先进行常规的基本块优化 *)
  Hashtbl.iter (fun block_id block ->
    let optimized_instructions = optimize_instructions_iterative block.instructions 6 in
    let dead_code_removed = remove_dead_code_improved optimized_instructions in
    let optimized_block = { block with instructions = dead_code_removed } in
    Hashtbl.add optimized_blocks block_id optimized_block
  ) cfg.blocks;
  
  (* 然后进行全局SSA版本跟踪 *)
  let global_version_map = Hashtbl.create 32 in
  
  (* 收集所有SSA变量的最新版本 *)
  Hashtbl.iter (fun _ block ->
    List.iter (function
      | TacAssign (dest, _) ->
          (match VariableVersioning.parse_ssa_var dest with
           | Some {base_name; scope; version} ->
               let key = base_name ^ "-" ^ scope in
               (try
                 let current_version = Hashtbl.find global_version_map key in
                 if version > current_version then
                   Hashtbl.replace global_version_map key version
               with Not_found ->
                 Hashtbl.add global_version_map key version)
           | None -> ())
      | _ -> ()
    ) block.instructions
  ) optimized_blocks;
  
  (* 修复所有return语句 *)
  let final_blocks = Hashtbl.create (Hashtbl.length optimized_blocks) in
  Hashtbl.iter (fun block_id block ->
    let fixed_instructions = List.map (function
      | TacReturn (Some operand) ->
          (match VariableVersioning.parse_ssa_var operand with
           | Some {base_name; scope; _} ->
               let key = base_name ^ "-" ^ scope in
               (try
                 let latest_version = Hashtbl.find global_version_map key in
                 let latest_var = base_name ^ "-Control-" ^ (string_of_int latest_version) ^ "-" ^ scope in
                 TacReturn (Some latest_var)
               with Not_found -> TacReturn (Some operand))
           | None -> TacReturn (Some operand))
      | instr -> instr
    ) block.instructions in
    let final_block = { block with instructions = fixed_instructions } in
    Hashtbl.add final_blocks block_id final_block
  ) optimized_blocks;
  
  { cfg with blocks = final_blocks }

(* 构建并优化CFG *)
let build_cfg_optimized function_name instructions =
  let cfg = build_cfg function_name instructions in
  optimize_cfg cfg

(* 构建多个优化的CFG *)
let build_cfgs_optimized tac_list =
  let cfgs = build_cfgs_from_functions tac_list in
  List.map optimize_cfg cfgs

(* ==================== 对外接口函数 ==================== *)

(* 将优化后的CFG转换回TAC指令序列 *)
let cfg_to_tac_instructions cfg =
  cfg_to_tac_instructions_correct cfg

(* 将多个CFG转换回TAC指令序列 *)
let cfgs_to_tac_instructions cfgs =
  List.fold_left (fun acc cfg ->
    let cfg_instructions = cfg_to_tac_instructions cfg in
    acc @ cfg_instructions
  ) [] cfgs

(* 主要对外接口：从Transfer.tac优化到optimized TAC *)
let optimize_transfer_tac (transfer_tac_list: 'a list) : 'a list =
  (* 转换为内部TAC类型 *)
  let converted_list = List.map (Obj.magic : 'a -> tac) transfer_tac_list in
  
  (* 构建并优化CFG *)
  let optimized_cfgs = build_cfgs_optimized converted_list in
  
  (* 转换回TAC指令序列 *)
  let optimized_instructions = cfgs_to_tac_instructions optimized_cfgs in
  
  (* 转换回Transfer.tac类型 *)
  List.map (Obj.magic : tac -> 'a) optimized_instructions

(* 打印基本块信息（调试用） *)
let print_basic_block (block: basic_block) : unit =
  Printf.printf "Block %d:\n" block.id;
  (match block.label with
  | Some label -> Printf.printf "  Label: %s\n" label
  | None -> ());
  Printf.printf "  Predecessors: [%s]\n" (String.concat "; " (List.map string_of_int block.predecessors));
  Printf.printf "  Successors: [%s]\n" (String.concat "; " (List.map string_of_int block.successors));
  Printf.printf "  Instructions:\n";
  List.iter (fun instr ->
    Printf.printf "    %s\n" (match instr with
    | TacAssign (dest, src) -> Printf.sprintf "%s = %s" dest src
    | TacBinOp (dest, src1, op, src2) -> Printf.sprintf "%s = %s %s %s" dest src1 op src2
    | TacUnOp (dest, op, src) -> Printf.sprintf "%s = %s%s" dest op src
    | TacLabel label -> Printf.sprintf "%s:" label
    | TacGoto label -> Printf.sprintf "goto %s" label
    | TacIfGoto (cond, label) -> Printf.sprintf "if %s goto %s" cond label
    | TacParam param -> Printf.sprintf "param %s" param
    | TacCall (dest, func, argc, _args) -> Printf.sprintf "%s = call %s, %d" dest func argc
    | TacReturn None -> "return"
    | TacReturn (Some value) -> Printf.sprintf "return %s" value
    | TacComment (_temp, comment, _) -> Printf.sprintf "# %s" comment
    | TacPhi (dest, src1, src2) -> Printf.sprintf "%s = phi(%s, %s)" dest src1 src2)
  ) block.instructions;
  Printf.printf "\n"

(* 打印控制流图信息（调试用） *)
let print_cfg (cfg: cfg) : unit =
  Printf.printf "CFG for function %s:\n" cfg.function_name;
  Printf.printf "Entry block: %d\n" cfg.entry_block;
  Printf.printf "Exit blocks: [%s]\n" (String.concat "; " (List.map string_of_int cfg.exit_blocks));
  Printf.printf "\nBasic blocks:\n";
  Hashtbl.iter (fun _ block -> print_basic_block block) cfg.blocks;
  Printf.printf "----------------------------------------\n\n"
