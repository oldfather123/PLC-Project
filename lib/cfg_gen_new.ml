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

(* 基本块类型定义 *)
type basic_block = {
  id: int;                    (* 基本块ID *)
  label: string option;       (* 基本块入口标签（如果有） *)
  instructions: tac list;     (* 基本块内的指令序列 *)
  predecessors: int list;     (* 前驱基本块ID列表 *)
  successors: int list;       (* 后继基本块ID列表 *)
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
let partition_into_blocks (instructions: tac list) : (int * string option * tac list) list =
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
        blocks := (block_id, label, block_instrs) :: !blocks
    | start :: (next :: _ as rest) ->
        (* 中间的基本块 *)
        let length = next - start in
        let block_instrs = Array.to_list (Array.sub indexed_instrs start length) in
        let label = get_label_name (List.hd block_instrs) in
        let block_id = new_block_id () in
        blocks := (block_id, label, block_instrs) :: !blocks;
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
            (* 非跳转指令，检查是否还有后续基本块 *)
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
    (preds: int list) (succs: int list) : basic_block =
  {
    id = block_id;
    label = label;
    instructions = instrs;
    predecessors = preds;
    successors = succs;
  }

(* 找到出口基本块 *)
let find_exit_blocks (blocks: (int * string option * tac list) list) : int list =
  List.fold_left (fun acc (block_id, _, instrs) ->
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
  
  (* 过滤掉注释指令，只保留有效指令 *)
  let effective_instrs = List.filter (function TacComment _ -> false | _ -> true) instructions in
  
  if effective_instrs = [] then
    (* 空函数的情况 *)
    let empty_block_id = new_block_id () in
    let empty_block = create_basic_block empty_block_id None [TacReturn None] [] [] in
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
    let label_map = build_label_map block_list in
    let successor_pairs = compute_successors block_list label_map in
    let pred_map = compute_predecessors successor_pairs in
    
    (* 创建基本块映射表 *)
    let blocks = Hashtbl.create (List.length block_list) in
    List.iter (fun (block_id, label, instrs) ->
      let preds = try Hashtbl.find pred_map block_id with Not_found -> [] in
      let succs = try List.assoc block_id successor_pairs with Not_found -> [] in
      let block = create_basic_block block_id label instrs preds succs in
      Hashtbl.add blocks block_id block
    ) block_list;
    
    (* 确定入口和出口基本块 *)
    let entry_block = List.hd block_list |> fun (id, _, _) -> id in
    let exit_blocks = find_exit_blocks block_list in
    
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
        
        (* 开始新函数 *)
        let func_name = String.sub func_comment 9 (String.length func_comment - 9) in
        current_function := Some func_name;
        current_instrs := []
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
