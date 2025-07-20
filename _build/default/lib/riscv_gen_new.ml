open Transfer

(* RISC-V 指令类型 *)
type riscv_inst =
  | RLabel of string
  | RLi of string * int
  | RMv of string * string
  | RAdd of string * string * string
  | RSub of string * string * string
  | RMul of string * string * string
  | RDiv of string * string * string
  | RRem of string * string * string
  | RSlt of string * string * string
  | RSgt of string * string * string
  | RXori of string * string * int
  | RAnd of string * string * string
  | ROr of string * string * string
  | RSeqz of string * string
  | RNeg of string * string
  | RBnez of string * string
  | RAddi of string * string * int
  | RSw of string * int * string
  | RLw of string * int * string
  | RCall of string
  | RJ of string
  | RBne of string * string * string
  | RBeq of string * string * string
  | RBge of string * string * string
  | RBgt of string * string * string
  | RBle of string * string * string
  | RBlt of string * string * string
  | RRet

(* 函数信息记录 *)
type func_info = {
  mutable param_count: int;          (* 参数个数 *)
  mutable var_count: int;           (* 局部变量个数 *)
  mutable stack_size: int;          (* 栈空间大小 *)
  var_offsets: (string, int) Hashtbl.t;  (* 变量在栈中的偏移 *)
  stored_vars: (string, bool) Hashtbl.t; (* 记录变量是否已存储到栈 *)
}

(* 计算对齐到16字节的栈大小 *)
let align_stack size =
  (size + 15) land (lnot 15)

(* 扫描函数信息 *)
let scan_functions tac_list =
  let func_table = Hashtbl.create 32 in
  let current_func = ref "" in
  let current_info = ref None in
  
  let init_func_info name param_names =
    let info = {
      param_count = List.length param_names;
      var_count = 0;
      stack_size = 8;  (* ra 和 s0 需要 8 字节 *)
      var_offsets = Hashtbl.create 32;
      stored_vars = Hashtbl.create 32;
    } in
    (* 为参数分配栈空间 *)
    List.iteri (fun _i param_name ->
        info.stack_size <- info.stack_size + 4;  (* 先更新栈空间大小 *)
        let offset = -info.stack_size in         (* 再计算偏移值 *)
        Hashtbl.add info.var_offsets param_name offset;
      (* Printf.printf "alloc space for param %s at offset %d\n" param_name offset; *)
    ) param_names;
    Hashtbl.add func_table name info;
    current_func := name;
    current_info := Some info
  in

  let add_var_if_new var =
    match !current_info with
    | Some info when not (Hashtbl.mem info.var_offsets var) ->
          info.var_count <- info.var_count + 1;
          info.stack_size <- info.stack_size + 4;
          let offset = -info.stack_size in
          Hashtbl.add info.var_offsets var offset;
          (* Printf.printf "alloc space for variable %s\n" var; *)
    | _ -> ()
  in

  List.iter (fun tac ->
    match tac with
    | TacComment (_, comment_str, param_names) ->
        if String.length comment_str > 9 && String.sub comment_str 0 9 = "function " then
          let name = String.sub comment_str 9 (String.length comment_str - 9) in
          init_func_info name param_names
    | TacBinOp (dest, src1, _, src2) ->
        add_var_if_new dest;
        add_var_if_new src1;
        add_var_if_new src2
    | TacUnOp (dest, _, src) ->
        add_var_if_new dest;
        add_var_if_new src
    | TacAssign (dest, _) ->
        add_var_if_new dest
    | TacCall (dest, _, _, _) ->
        add_var_if_new dest
    | _ -> ()
  ) tac_list;

  (* 对齐每个函数的栈空间 *)
  Hashtbl.iter (fun _ info ->
    info.stack_size <- align_stack info.stack_size
  ) func_table;
  
  func_table

let string_of_tac tac =
  match tac with
  | TacAssign (dest, src) -> "TacAssign(" ^ dest ^ ", " ^ src ^ ")"
  | TacBinOp (dest, src1, op, src2) -> "TacBinOp(" ^ dest ^ ", " ^ src1 ^ ", " ^ op ^ ", " ^ src2 ^ ")"
  | TacUnOp (dest, op, src) -> "TacUnOp(" ^ dest ^ ", " ^ op ^ ", " ^ src ^ ")"
  | TacIfGoto (cond, label) -> "TacIfGoto(" ^ cond ^ ", " ^ label ^ ")"
  | TacCall (dest, func_name, _, _args) -> "TacCall(" ^ dest ^ ", " ^ func_name ^ ", args)"
  | TacReturn (Some var) -> "TacReturn(" ^ var ^ ")"
  | TacReturn None -> "TacReturn(None)"
  | _ -> "Unknown TAC"

(* 生成 RISC-V 代码 *)
let tac_to_riscv tac_list =
  let func_table = scan_functions tac_list in
  let riscv_code = ref [] in
  let current_func = ref "" in
  let current_info = ref None in

  (* 生成函数序言 *)
  let emit_prologue name param_names =
    let info = Hashtbl.find func_table name in
    current_func := name;
    current_info := Some info;
    riscv_code := !riscv_code @ [
      RAddi ("sp", "sp", -info.stack_size);
      RSw ("ra", info.stack_size - 4, "sp");
      RSw ("s0", info.stack_size - 8, "sp");
      RAddi ("s0", "sp", info.stack_size)
    ];
    List.iteri (fun i param_name ->
    let offset = Hashtbl.find info.var_offsets param_name in
    if i < 8 then
      (* 前8个参数使用寄存器传递 *)
      riscv_code := !riscv_code @ [
        RSw (Printf.sprintf "a%d" i, offset, "s0")
      ]
    else
      (* 超过8个参数的情况需要通过栈传递 *)
      riscv_code := !riscv_code @ [
        RLw ("a0", (i - 8) * 4, "s0");  (* 从栈中加载参数 *)
        RSw ("a0", offset, "s0")   (* 将参数存储到栈中 *)
      ]
    ) param_names;
  in
  let is_digit_string s =
  String.fold_left (fun acc c -> acc && Char.code c >= Char.code '0' && Char.code c <= Char.code '9') true s
  in
  (* 获取变量在栈中的位置 *)
  let get_var_offset var tac =
  match !current_info with
  | Some info ->
      if Hashtbl.mem info.var_offsets var then
        Hashtbl.find info.var_offsets var
      else if is_digit_string var then
        (Printf.eprintf "Error: Constant value used as variable: %s in TAC: %s\n" var (string_of_tac tac);
        failwith ("Constant value used as variable: " ^ var ^ " in TAC: " ^ string_of_tac tac))
      else
        (Printf.eprintf "Error: Variable not found: %s in TAC: %s\n" var (string_of_tac tac);
        failwith ("Variable not found: " ^ var ^ " in TAC: " ^ string_of_tac tac))
  | None -> failwith "No active function"
  in

  let rec process_tac acc = function
    | [] -> List.rev acc
    | TacComment (_, comment_str, param_names) :: xs ->
      (* 使用字符串匹配提取函数名 *)
      if String.length comment_str > 9 && String.sub comment_str 0 9 = "function " then
        let name = String.sub comment_str 9 (String.length comment_str - 9) in
        riscv_code := [];
        emit_prologue name param_names;
        process_tac (List.rev (!riscv_code) @ [RLabel name] @  acc) xs
      else
        process_tac acc xs
    
    | TacAssign (dest, src) :: xs ->
      (* Printf.printf "Processing TacAssign: %s = %s\n" dest src; *)
      (* 获取目标变量的栈偏移 *)
      let dest_offset = get_var_offset dest (TacAssign (dest, src)) in
      (try
        let value = int_of_string src in
        (* Printf.printf "int value = %d to dest %s\n" value dest; *)
        (* 如果 src 是常量，直接加载到寄存器 a0 *)
        (* 标记变量已经存储到栈中 *)
        (match !current_info with
        | Some info -> Hashtbl.add info.stored_vars dest true; Hashtbl.replace info.var_offsets dest dest_offset
        | None -> failwith "No active function");
        (* 如果是常量赋值，直接加载到寄存器并存储到栈中 *)
        process_tac ([
          RSw ("a0", dest_offset, "s0");  (* 将寄存器 a0 的值存储到栈中 *)  
          RLi ("a0", value)  (* 将常量加载到寄存器 a0 *)
        ] @ acc) xs
        
      with Failure _ ->
        (* Printf.eprintf "Failure occurred: %s\n" msg;
        Printf.printf "int variable = %s to dest %s\n" src dest; *)
        let src_offset = get_var_offset src (TacAssign (dest, src)) in
        (* 标记变量已经存储到栈中 *)
        (match !current_info with
        | Some info -> Hashtbl.add info.stored_vars dest true
        | None -> failwith "No active function");
        (* 始终生成赋值指令，无论 dest 是否已存储到栈中 *)
        process_tac ([
          RSw ("a0", dest_offset, "s0");  
          RLw ("a0", src_offset, "s0")
        ] @ acc) xs
        )

    | TacBinOp (x1, x, op, a) :: TacUnOp (x3, "!", x2) :: TacIfGoto (x4, label) :: xs when x2 = x1 && x4 = x3 && op <> "&&" && op <> "||" ->
        (* 优化模式：直接生成 beq/bne 指令 *)
        let src1_offset = get_var_offset x (TacBinOp (x1, x, op, a)) in
        let src2_offset = get_var_offset a (TacBinOp (x1, x, op, a)) in
        let instr = match op with
          | "==" -> [RBne ("a0", "a1", label)]  (* 生成 RBne 指令 *)
          | "!=" -> [RBeq ("a0", "a1", label)]  (* 生成 RBeq 指令 *)
          | "<" -> [RBge ("a0", "a1", label)]  (* 生成 RBge 指令 *)
          | "<=" -> [RBgt ("a0", "a1", label)]  (* 生成 RBgt 指令 *)
          | ">" -> [RBle ("a0", "a1", label)]  (* 生成 RBle 指令 *)
          | ">=" -> [RBlt ("a0", "a1", label)]  (* 生成 RBlt 指令 *)
          | _ -> failwith "Unsupported operation in if-goto"
        in
        process_tac (
          instr @ [
            RLw ("a0", src1_offset, "s0");  (* 加载 x 的值到寄存器 a0 *)
            RLw ("a1", src2_offset, "s0")   (* 加载 a 的值到寄存器 a1 *)
          ] @ acc
        ) xs

    | TacBinOp (dest, src1, op, src2) :: xs ->
        let dest_offset = get_var_offset dest (TacBinOp (dest, src1, op, src2))in
        let src1_offset = get_var_offset src1 (TacBinOp (dest, src1, op, src2))in
        let src2_offset = get_var_offset src2 (TacBinOp (dest, src1, op, src2))in
        let instr = match op with
          | "+" -> (fun rd rs1 rs2 -> [RAdd (rd, rs1, rs2)])
          | "-" -> (fun rd rs1 rs2 -> [RSub (rd, rs1, rs2)])
          | "*" -> (fun rd rs1 rs2 -> [RMul (rd, rs1, rs2)])
          | "/" -> (fun rd rs1 rs2 -> [RDiv (rd, rs1, rs2)])
          | "%" -> (fun rd rs1 rs2 -> [RRem (rd, rs1, rs2)])
          | "==" -> (fun rd rs1 rs2 -> [RSub (rd, rs1, rs2); RSeqz (rd, rd)])
          | "!=" -> (fun rd rs1 rs2 -> [RSub (rd, rs1, rs2); RSeqz (rd, rd); RXori (rd, rd, 1)])
          | "<" -> (fun rd rs1 rs2 -> [RSlt (rd, rs1, rs2)])
          | "<=" -> (fun rd rs1 rs2 -> [RSlt (rd, rs1, rs2); RXori (rd, rd, 1)])
          | ">" -> (fun rd rs1 rs2 -> [RSgt (rd, rs1, rs2)])
          | ">=" -> (fun rd rs1 rs2 -> [RSgt (rd, rs1, rs2); RXori (rd, rd, 1)])
          | "&&" -> (fun rd rs1 rs2 -> [RAnd (rd, rs1, rs2)])
          | "||" -> (fun rd rs1 rs2 -> [ROr (rd, rs1, rs2)])
          | _ -> failwith ("Unsupported operation " ^ op)
        in
        process_tac (
          [RSw ("a2", dest_offset, "s0")] @
          instr "a2" "a1" "a0" @  
          [RLw ("a1", src1_offset, "s0");
          RLw ("a0", src2_offset, "s0")] @ acc) xs
    
    | TacUnOp (dest, op, src) :: xs ->
      let dest_offset = get_var_offset dest (TacUnOp (dest, op, src)) in
      let src_offset = get_var_offset src (TacUnOp (dest, op, src))in
      let instr = match op with
        | "+" -> [RMv ("a0", "a1")]  (* 正号操作：将 src 的值复制到 a0 *)
        | "!" -> [RSeqz ("a0", "a1")]  (* 非操作：将 src 的值取反 *)
        | "-" -> [RNeg ("a0", "a1")]  (* 负号操作：将 src 的值取负 *)
        | _ -> (Printf.eprintf "Unsupported unary operation: %s" op; failwith ("Unsupported unary operation: " ^ op))
      in
      process_tac (
        [RSw ("a0", dest_offset, "s0")] @ instr @ [RLw ("a1", src_offset, "s0")] @ acc) xs
    
    | TacLabel l :: xs when String.starts_with ~prefix:"if_" l || 
                           String.starts_with ~prefix:"then_" l || 
                           String.starts_with ~prefix:"while_" l-> process_tac ([RLabel l] @ acc) xs
      
    | TacGoto l :: xs -> process_tac ([RJ l] @ acc) xs

    | TacIfGoto (cond, label) :: xs ->
      let cond_offset = get_var_offset cond (TacIfGoto (cond, label)) in
      process_tac (
        [RBnez ("a0", label);            (* 如果条件为真，跳转到指定标签 *)
          RLw ("a0", cond_offset, "s0")  (* 从栈中加载条件变量的值到寄存器 a0 *) 
        ] @ acc
      ) xs

    | TacCall (dest, func_name, n, args) :: xs ->
        (* 准备参数 *)
        let param_insts = List.mapi (fun i arg ->
          let arg_offset = get_var_offset arg (TacCall (dest, func_name, n, args)) in
          if i < 8 then
            (* Printf.printf "param %s in register a%d\n" arg i; *)
            (* 前8个参数使用寄存器传递 *)
            [RLw (Printf.sprintf "a%d" i, arg_offset, "s0")]  (* 使用寄存器传递参数 *)
          else
            (* 超过8个参数的情况需要通过栈传递 *)
            (* Printf.printf "param %s in stack at offset %d\n" arg ((i - 8) * 4); *)
            (* 将参数存储到栈中 *)
            [RSw ("a0", (i - 8) * 4, "sp");RLw ("a0", arg_offset, "s0")]
        ) args |> List.flatten in
        (* 调用函数 *)
        let call_inst = [RCall func_name] in
        (* 保存返回值 *)
        let dest_offset =
          match !current_info with
          | Some info ->
              if Hashtbl.mem info.var_offsets dest then
                Hashtbl.find info.var_offsets dest  (* 使用已有的栈偏移 *)
              else begin
                let new_offset = -info.stack_size in
                info.stack_size <- info.stack_size + 4;
                Hashtbl.add info.var_offsets dest new_offset;
                new_offset
              end
          | None -> failwith "No active function"
        in
        let save_return_inst = [RSw ("a0", dest_offset, "s0")] in
        process_tac (save_return_inst @ call_inst @ param_insts @ acc) xs

    | TacReturn (Some var) :: xs ->
        let offset = get_var_offset var (TacReturn (Some var)) in
        (match !current_info with
        | Some info ->
            process_tac ( List.rev [
              RLw ("a0", offset, "s0");
              RLw ("ra", info.stack_size - 4, "sp");
              RLw ("s0", info.stack_size - 8, "sp");
              RAddi ("sp", "sp", info.stack_size);
              RRet
            ] @ acc) xs
        | None -> failwith "No active function for return")
    
    | TacReturn None :: xs ->
        (match !current_info with
        | Some info ->
            process_tac ( List.rev [
              RLw ("ra", info.stack_size - 4, "sp");
              RLw ("s0", info.stack_size - 8, "sp");
              RAddi ("sp", "sp", info.stack_size);
              RRet
            ] @ acc) xs
        | None -> failwith "No active function for return")

    | _ :: xs -> process_tac acc xs
  in
  process_tac [] tac_list