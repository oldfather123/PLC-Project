open Transfer
type basic_block = {
  label : string option;
  instrs : tac list;
  mutable succs : string list;  (* 后继块的label *)
}

type cfg = (string, basic_block) Hashtbl.t
let split_basic_blocks tac_list =
  let blocks = ref [] in
  let curr_instrs = ref [] in
  let curr_label = ref None in
  let flush_block () =
    if !curr_instrs <> [] || !curr_label <> None then
      blocks := { label = !curr_label; instrs = List.rev !curr_instrs; succs = [] } :: !blocks;
    curr_instrs := [];
    curr_label := None
  in
  List.iter (fun tac ->
    match tac with
    | TacLabel l ->
        flush_block ();
        curr_label := Some l;
        curr_instrs := tac :: !curr_instrs
    | TacGoto _ | TacIfGoto _ | TacReturn _ | TacCall _ ->
        curr_instrs := tac :: !curr_instrs;
        flush_block ()
    | _ ->
        curr_instrs := tac :: !curr_instrs
  ) tac_list;
  flush_block ();
  List.rev !blocks
let build_cfg tac_list =
  let blocks = split_basic_blocks tac_list in
  let label_map = Hashtbl.create 32 in
  List.iter (fun block ->
    match block.label with
    | Some l -> Hashtbl.add label_map l block
    | None -> ()
  ) blocks;
  (* 连接后继 *)
  let rec get_next_label = function
    | [] -> None
    | {label = Some l; _} :: _ -> Some l
    | _ :: xs -> get_next_label xs
  in
  let rec connect blocks =
    match blocks with
    | [] -> ()
    | block :: rest ->
      (match List.rev block.instrs with
        | TacGoto l :: _ -> block.succs <- [l]
        | TacIfGoto (_, l) :: _ ->
            (match get_next_label rest with
            | Some next_l when next_l <> l -> block.succs <- [l; next_l]
            | _ -> block.succs <- [l])
        | TacCall (_, fname, _, _) :: _ ->
            (* 跳转到被调用函数的入口label和顺序后继 *)
            (match get_next_label rest with
            | Some next_l when next_l <> fname -> block.succs <- [fname; next_l]
            | _ -> block.succs <- [fname])
        | TacReturn _ :: _ -> block.succs <- []
        | _ ->
            (match get_next_label rest with
            | Some next_l -> block.succs <- [next_l]
            | None -> block.succs <- [])
      );
      connect rest
  in
  connect blocks;
  (* 构建CFG哈希表 *)
  let cfg_tbl = Hashtbl.create 32 in
  List.iter (fun block ->
    match block.label with
    | Some l -> Hashtbl.add cfg_tbl l block
    | None -> ()
  ) blocks;
  (cfg_tbl, blocks)
