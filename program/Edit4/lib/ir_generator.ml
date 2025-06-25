(* 三地址码中间代码生成器 *)
open Ast

(* 三地址码操作类型 *)
type three_addr_op =
  | Add | Sub | Mul | Div | Mod
  | Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual
  | LogicalAnd | LogicalOr | LogicalNot
  | UnaryPlus | UnaryMinus

(* 操作数类型 *)
type operand =
  | Temp of int          (* 临时变量 t1, t2, ... *)
  | Var of string        (* 程序变量 *)
  | Const of int         (* 常量 *)
  | Label_ref of string  (* 标签引用 *)

(* 三地址码指令 *)
type three_addr_instr =
  | Binary of operand * three_addr_op * operand * operand  (* result = op1 op op2 *)
  | Unary of operand * three_addr_op * operand             (* result = op operand *)
  | Copy of operand * operand                              (* dest = src *)
  | Jump_instr of string                                   (* goto label *)
  | JumpCond of operand * bool * string                    (* if operand [true/false] goto label *)
  | Label_instr of string                                  (* label: *)
  | Call_instr of operand option * string * int           (* [result =] call func(param_count) *)
  | Param_instr of operand                                 (* param operand *)
  | Return_instr of operand option                         (* return [value] *)

(* 代码生成器状态 *)
type gen_state = {
  mutable code: three_addr_instr list;     (* 生成的代码 *)
  mutable temp_counter: int;               (* 临时变量计数器 *)
  mutable label_counter: int;              (* 标签计数器 *)
  mutable break_label: string option;     (* 当前break标签 *)
  mutable continue_label: string option;  (* 当前continue标签 *)
}

(* 创建新的生成器状态 *)
let create_gen_state () = {
  code = [];
  temp_counter = 0;
  label_counter = 0;
  break_label = None;
  continue_label = None;
}

(* 生成新的临时变量 *)
let new_temp state =
  let temp_num = state.temp_counter in
  state.temp_counter <- temp_num + 1;
  Temp temp_num

(* 生成新的标签 *)
let new_label state prefix =
  let label_num = state.label_counter in
  state.label_counter <- label_num + 1;
  prefix ^ (string_of_int label_num)

(* 添加指令到代码列表 *)
let emit state instr =
  state.code <- instr :: state.code

(* 二元操作符转换 *)
let binary_op_to_three_addr = function
  | Ast.Add -> Add
  | Ast.Sub -> Sub
  | Ast.Mul -> Mul
  | Ast.Div -> Div
  | Ast.Mod -> Mod
  | Ast.Equal -> Equal
  | Ast.NotEqual -> NotEqual
  | Ast.Less -> Less
  | Ast.LessEqual -> LessEqual
  | Ast.Greater -> Greater
  | Ast.GreaterEqual -> GreaterEqual
  | Ast.LogicalAnd -> LogicalAnd
  | Ast.LogicalOr -> LogicalOr

(* 一元操作符转换 *)
let unary_op_to_three_addr = function
  | Ast.UnaryPlus -> UnaryPlus
  | Ast.UnaryMinus -> UnaryMinus
  | Ast.LogicalNot -> LogicalNot

(* 表达式代码生成 *)
let rec gen_expr state expr =
  match expr with
  | Number n ->
      Const n
  
  | Identifier name ->
      Var name
  
  | UnaryOp (op, expr) ->
      let operand = gen_expr state expr in
      let result = new_temp state in
      let three_addr_op = unary_op_to_three_addr op in
      emit state (Unary (result, three_addr_op, operand));
      result
  
  | BinaryOp (left, op, right) ->
      (match op with
       | Ast.LogicalAnd ->
           (* 短路求值：if !left goto false_label; result = right; goto end_label; false_label: result = 0; end_label: *)
           let left_operand = gen_expr state left in
           let false_label = new_label state "and_false_" in
           let end_label = new_label state "and_end_" in
           let result = new_temp state in
           
           emit state (JumpCond (left_operand, false, false_label));
           let right_operand = gen_expr state right in
           emit state (Copy (result, right_operand));
           emit state (Jump_instr end_label);
           emit state (Label_instr false_label);
           emit state (Copy (result, Const 0));
           emit state (Label_instr end_label);
           result
       
       | Ast.LogicalOr ->
           (* 短路求值：if left goto true_label; result = right; goto end_label; true_label: result = 1; end_label: *)
           let left_operand = gen_expr state left in
           let true_label = new_label state "or_true_" in
           let end_label = new_label state "or_end_" in
           let result = new_temp state in
           
           emit state (JumpCond (left_operand, true, true_label));
           let right_operand = gen_expr state right in
           emit state (Copy (result, right_operand));
           emit state (Jump_instr end_label);
           emit state (Label_instr true_label);
           emit state (Copy (result, Const 1));
           emit state (Label_instr end_label);
           result
       
       | _ ->
           let left_operand = gen_expr state left in
           let right_operand = gen_expr state right in
           let result = new_temp state in
           let three_addr_op = binary_op_to_three_addr op in
           emit state (Binary (result, three_addr_op, left_operand, right_operand));
           result)
  
  | FunctionCall (func_name, args) ->
      (* 生成参数传递代码 *)
      let arg_operands = List.map (gen_expr state) args in
      List.iter (fun arg -> emit state (Param_instr arg)) (List.rev arg_operands);
      let result = new_temp state in
      emit state (Call_instr (Some result, func_name, List.length args));
      result

(* 语句代码生成 *)
let rec gen_stmt state stmt =
  match stmt with
  | Block stmts ->
      List.iter (gen_stmt state) stmts
  
  | EmptyStmt -> ()
  
  | ExprStmt expr ->
      let _ = gen_expr state expr in
      ()
  
  | Assignment (var, expr) ->
      let expr_result = gen_expr state expr in
      emit state (Copy (Var var, expr_result))
  
  | VarDecl (var, expr) ->
      let expr_result = gen_expr state expr in
      emit state (Copy (Var var, expr_result))
  
  | IfStmt (cond, then_stmt, else_stmt) ->
      let cond_result = gen_expr state cond in
      let else_label = new_label state "else_" in
      let end_label = new_label state "end_if_" in
      
      (* 条件跳转 *)
      emit state (JumpCond (cond_result, false, else_label));
      
      (* then分支 *)
      gen_stmt state then_stmt;
      emit state (Jump_instr end_label);
      
      (* else分支 *)
      emit state (Label_instr else_label);
      (match else_stmt with
       | Some stmt -> gen_stmt state stmt
       | None -> ());
      
      emit state (Label_instr end_label)
  
  | WhileStmt (cond, body) ->
      let start_label = new_label state "while_start_" in
      let end_label = new_label state "while_end_" in
      
      (* 保存之前的break/continue标签 *)
      let old_break = state.break_label in
      let old_continue = state.continue_label in
      state.break_label <- Some end_label;
      state.continue_label <- Some start_label;
      
      emit state (Label_instr start_label);
      let cond_result = gen_expr state cond in
      emit state (JumpCond (cond_result, false, end_label));
      
      gen_stmt state body;
      emit state (Jump_instr start_label);
      emit state (Label_instr end_label);
      
      (* 恢复之前的break/continue标签 *)
      state.break_label <- old_break;
      state.continue_label <- old_continue
  
  | BreakStmt ->
      (match state.break_label with
       | Some label -> emit state (Jump_instr label)
       | None -> failwith "break statement outside loop")
  
  | ContinueStmt ->
      (match state.continue_label with
       | Some label -> emit state (Jump_instr label)
       | None -> failwith "continue statement outside loop")
  
  | ReturnStmt expr_opt ->
      (match expr_opt with
       | Some expr ->
           let result = gen_expr state expr in
           emit state (Return_instr (Some result))
       | None ->
           emit state (Return_instr None))

(* 检查语句块是否以return语句结尾 *)
let rec ends_with_return stmt =
  match stmt with
  | ReturnStmt _ -> true
  | Block stmts when stmts <> [] -> ends_with_return (List.hd (List.rev stmts))
  | IfStmt (_, then_stmt, Some else_stmt) -> 
      ends_with_return then_stmt && ends_with_return else_stmt
  | _ -> false

(* 函数代码生成 *)
let gen_func_def state (FuncDef (ret_type, name, params, body)) =
  (* 函数标签 *)
  emit state (Label_instr name);
  
  (* 参数处理 - 为每个参数生成赋值语句 *)
  List.iter (fun (Param param_name) ->
    emit state (Copy (Var param_name, Temp (-1))) (* 使用特殊临时变量表示参数 *)
  ) params;
  
  (* 函数体 *)
  gen_stmt state body;
  
  (* 只有当函数没有显式返回时，才添加默认返回 *)
  if not (ends_with_return body) then
    match ret_type with
    | Void -> emit state (Return_instr None)
    | Int -> emit state (Return_instr (Some (Const 0)))

(* 程序代码生成 *)
let gen_program program =
  let state = create_gen_state () in
  List.iter (gen_func_def state) program;
  List.rev state.code

(* 打印三地址码 *)
let string_of_operand = function
  | Temp n when n = -1 -> "param"
  | Temp n -> "t" ^ (string_of_int n)
  | Var name -> name
  | Const n -> string_of_int n
  | Label_ref name -> name

let string_of_op = function
  | Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/" | Mod -> "%"
  | Equal -> "==" | NotEqual -> "!=" | Less -> "<" | LessEqual -> "<=" 
  | Greater -> ">" | GreaterEqual -> ">="
  | LogicalAnd -> "&&" | LogicalOr -> "||" | LogicalNot -> "!"
  | UnaryPlus -> "+" | UnaryMinus -> "-"

let string_of_three_addr_instr = function
  | Binary (result, op, op1, op2) ->
      Printf.sprintf "%s = %s %s %s"
        (string_of_operand result)
        (string_of_operand op1)
        (string_of_op op)
        (string_of_operand op2)
  
  | Unary (result, op, operand) ->
      Printf.sprintf "%s = %s %s"
        (string_of_operand result)
        (string_of_op op)
        (string_of_operand operand)
  
  | Copy (dest, src) ->
      Printf.sprintf "%s = %s"
        (string_of_operand dest)
        (string_of_operand src)
  
  | Jump_instr label ->
      Printf.sprintf "goto %s" label
  
  | JumpCond (cond, true_jump, label) ->
      let condition = if true_jump then "" else "!" in
      Printf.sprintf "if %s%s goto %s" condition (string_of_operand cond) label
  
  | Label_instr label ->
      Printf.sprintf "%s:" label
  
  | Call_instr (Some result, func, argc) ->
      Printf.sprintf "%s = call %s, %d" (string_of_operand result) func argc
  
  | Call_instr (None, func, argc) ->
      Printf.sprintf "call %s, %d" func argc
  
  | Param_instr operand ->
      Printf.sprintf "param %s" (string_of_operand operand)
  
  | Return_instr (Some value) ->
      Printf.sprintf "return %s" (string_of_operand value)
  
  | Return_instr None ->
      "return"

let print_three_addr_code code =
  let rec print_with_spacing = function
    | [] -> ()
    | [instr] -> Printf.printf "%s\n" (string_of_three_addr_instr instr)
    | instr1 :: instr2 :: rest ->
        Printf.printf "%s\n" (string_of_three_addr_instr instr1);
        (* 如果当前指令是 return，且下一个指令是 label（新函数开始），则添加空行 *)
        (match instr1, instr2 with
         | Return_instr _, Label_instr _ -> Printf.printf "\n"
         | _ -> ());
        print_with_spacing (instr2 :: rest)
  in
  print_with_spacing code

(* 从AST生成并打印三地址码 *)
let generate_and_print_ir ast =
  let code = gen_program ast in
  print_three_addr_code code;
  code