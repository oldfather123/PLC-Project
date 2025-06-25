(* Interpreter for ToyC language *)

open Ast


(* 异常定义 *)
exception RuntimeError of string

(* 值类型 *)
type value = 
  | IntValue of int
  | VoidValue

(* 环境：变量名到值的映射 *)
module Environment = struct
  type 'a env = (string * 'a) list

  let empty = []

  let bind name value env = (name, value) :: env

  let rec lookup name env =
    match env with
    | [] -> raise (RuntimeError ("Undefined variable: " ^ name))
    | (n, v) :: rest -> if n = name then v else lookup name rest

  let rec update name value env =
    match env with
    | [] -> raise (RuntimeError ("Undefined variable: " ^ name))
    | (n, _) :: rest when n = name -> (n, value) :: rest
    | binding :: rest -> binding :: (update name value rest)
end

(* 其他异常定义 *)
exception BreakException of value Environment.env
exception ContinueException of value Environment.env
exception ReturnException of int option



(* 函数环境：函数名到函数定义的映射 *)
type func_env = (string * func_def) list

let rec lookup_function name func_env =
  match func_env with
  | [] -> raise (RuntimeError ("Undefined function: " ^ name))
  | (n, f) :: rest -> if n = name then f else lookup_function name rest

(* 将值转换为字符串（用于调试） *)
let string_of_value = function
  | IntValue i -> string_of_int i
  | VoidValue -> "void"

(* 将值转换为布尔值 *)
let value_to_bool = function
  | IntValue 0 -> false
  | IntValue _ -> true
  | VoidValue -> false

(* 将布尔值转换为值 *)
let bool_to_value b = IntValue (if b then 1 else 0)

(* 求值表达式 *)
let rec eval_expr expr env func_env =
  match expr with
  | Identifier id -> Environment.lookup id env
  | Number n -> IntValue n
  | UnaryOp (op, e) ->
    let v = eval_expr e env func_env in
    (match op, v with
     | UnaryPlus, IntValue i -> IntValue i
     | UnaryMinus, IntValue i -> IntValue (-i)
     | LogicalNot, v -> bool_to_value (not (value_to_bool v))
     | _ -> raise (RuntimeError "Invalid unary operation"))
  | BinaryOp (e1, op, e2) ->
    let v1 = eval_expr e1 env func_env in
    let v2 = eval_expr e2 env func_env in
    eval_binary_op v1 op v2
  | FunctionCall (name, args) ->
    let arg_values = List.map (fun e -> eval_expr e env func_env) args in
    call_function name arg_values env func_env

and eval_binary_op v1 op v2 =
  match v1, op, v2 with
  | IntValue i1, Add, IntValue i2 -> IntValue (i1 + i2)
  | IntValue i1, Sub, IntValue i2 -> IntValue (i1 - i2)
  | IntValue i1, Mul, IntValue i2 -> IntValue (i1 * i2)
  | IntValue i1, Div, IntValue i2 -> 
    if i2 = 0 then raise (RuntimeError "Division by zero")
    else IntValue (i1 / i2)
  | IntValue i1, Mod, IntValue i2 -> 
    if i2 = 0 then raise (RuntimeError "Modulo by zero")
    else IntValue (i1 mod i2)
  | v1, Equal, v2 -> bool_to_value (compare_values v1 v2 = 0)
  | v1, NotEqual, v2 -> bool_to_value (compare_values v1 v2 <> 0)
  | IntValue i1, Less, IntValue i2 -> bool_to_value (i1 < i2)
  | IntValue i1, LessEqual, IntValue i2 -> bool_to_value (i1 <= i2)
  | IntValue i1, Greater, IntValue i2 -> bool_to_value (i1 > i2)
  | IntValue i1, GreaterEqual, IntValue i2 -> bool_to_value (i1 >= i2)
  | v1, LogicalAnd, v2 -> 
    if value_to_bool v1 then v2 else IntValue 0
  | v1, LogicalOr, v2 -> 
    if value_to_bool v1 then v1 else v2
  | _ -> raise (RuntimeError "Invalid binary operation")

and compare_values v1 v2 =
  match v1, v2 with
  | IntValue i1, IntValue i2 -> compare i1 i2
  | VoidValue, VoidValue -> 0
  | _ -> raise (RuntimeError "Cannot compare different types")

and call_function name args env func_env =
  if name = "putint" then
    (* 内置函数：打印整数 *)
    (match args with
     | [IntValue i] -> 
       print_int i; 
       print_newline(); 
       VoidValue
     | _ -> raise (RuntimeError "putint expects one integer argument"))
  else if name = "getint" then
    (* 内置函数：读取整数 *)
    (match args with
     | [] -> 
       print_string "Enter an integer: ";
       flush_all ();
       (try IntValue (read_int ())
        with _ -> raise (RuntimeError "Invalid input"))
     | _ -> raise (RuntimeError "getint expects no arguments"))
  else
    (* 用户定义函数 *)
    let FuncDef (ret_type, _, params, body) = lookup_function name func_env in
    if List.length params <> List.length args then
      raise (RuntimeError ("Function " ^ name ^ " expects " ^ 
                          string_of_int (List.length params) ^ " arguments, got " ^
                          string_of_int (List.length args)))
    else
      let param_names = List.map (function Param name -> name) params in
      let new_env = List.fold_right2 Environment.bind param_names args env in
      try
        let _ = exec_stmt body new_env func_env in
        (* 如果函数没有显式返回，根据返回类型返回默认值 *)
        match ret_type with
        | Void -> VoidValue
        | Int -> IntValue 0
      with
      | ReturnException (Some i) -> IntValue i
      | ReturnException None -> VoidValue

(* 执行语句 *)
and exec_stmt stmt env func_env =
  match stmt with
  | Block stmts -> exec_block stmts env func_env
  | EmptyStmt -> env
  | ExprStmt expr -> 
    let _ = eval_expr expr env func_env in
    env
  | Assignment (id, expr) ->
    let value = eval_expr expr env func_env in
    Environment.update id value env
  | VarDecl (id, expr) ->
    let value = eval_expr expr env func_env in
    Environment.bind id value env
  | IfStmt (cond, then_stmt, else_stmt) ->
    let cond_value = eval_expr cond env func_env in
    if value_to_bool cond_value then
      exec_stmt then_stmt env func_env
    else
      (match else_stmt with
       | Some stmt -> exec_stmt stmt env func_env
       | None -> env)
  | WhileStmt (cond, body) ->
    exec_while cond body env func_env
  | BreakStmt -> raise (BreakException env)
  | ContinueStmt -> raise (ContinueException env)
  | ReturnStmt expr_opt ->
    let return_value = 
      match expr_opt with
      | Some expr -> 
        (match eval_expr expr env func_env with
         | IntValue i -> Some i
         | VoidValue -> None)
      | None -> None
    in
    raise (ReturnException return_value)

and exec_block stmts env func_env =
  let rec exec_stmts_with_exceptions stmts current_env =
    match stmts with
    | [] -> current_env
    | stmt :: rest ->
      try
        let new_env = exec_stmt stmt current_env func_env in
        exec_stmts_with_exceptions rest new_env
      with
      | BreakException env -> raise (BreakException env)
      | ContinueException env -> raise (ContinueException env)
      | ReturnException v -> raise (ReturnException v)
  in
  exec_stmts_with_exceptions stmts env

and exec_while cond body env func_env =
  let rec loop current_env =
    let cond_value = eval_expr cond current_env func_env in
    if value_to_bool cond_value then
      try
        let new_env = exec_stmt body current_env func_env in
        loop new_env
      with
      | BreakException break_env -> break_env
      | ContinueException continue_env -> loop continue_env
    else
      current_env
  in
  loop env

(* 构建函数环境 *)
let build_func_env comp_unit =
  List.map (fun (FuncDef (_, name, _, _) as func_def) -> (name, func_def)) comp_unit

(* 查找主函数 *)
let find_main_function func_env =
  try
    Some (lookup_function "main" func_env)
  with
  | RuntimeError _ -> None

(* 执行程序 *)
let interpret program =
  try
    let func_env = build_func_env program in
    match find_main_function func_env with
    | Some (FuncDef (_, func_name, params, body)) ->
      if func_name <> "main" then
        raise (RuntimeError "Function found is not named 'main'")
      else if List.length params <> 0 then
        raise (RuntimeError "main function should have no parameters")
      else
        let initial_env = Environment.empty in
        (try
          let _ = exec_stmt body initial_env func_env in
          print_endline "Program finished normally (implicit return 0)";
          0
        with
        | ReturnException (Some i) -> 
          print_endline ("Program finished with return code: " ^ string_of_int i);
          i
        | ReturnException None -> 
          print_endline "Program finished with void return";
          0)
    | None ->
      raise (RuntimeError "No main function found")
  with
  | RuntimeError msg ->
    print_endline ("Runtime Error: " ^ msg);
    1
  | BreakException _ ->
    print_endline "Runtime Error: break statement outside loop";
    1
  | ContinueException _ ->
    print_endline "Runtime Error: continue statement outside loop";
    1
  | ReturnException _ ->
    print_endline "Runtime Error: return statement outside function";
    1

(* 辅助函数：打印程序执行结果 *)
let run_program program =
  let exit_code = interpret program in
  exit_code