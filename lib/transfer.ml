open Ast

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

type scope_kind = While | If | Block | FBlock

let temp_counter = ref 0
let if_label_counter = ref 0
let then_label_counter = ref 0
let while_label_counter = ref 0
let break_stack = ref []
let continue_stack = ref []
let current_func = ref ""
let scope_stack = ref []
let scope_kinds = ref []

let new_temp () =
  let t = Printf.sprintf "t%d" !temp_counter in
  incr temp_counter; t

let if_new_label () =
  let l = Printf.sprintf "if_L%d" !if_label_counter in
  incr if_label_counter; l

let then_new_label () =
  let l = Printf.sprintf "then_L%d" !then_label_counter in
  incr then_label_counter; l

let while_new_label () =
  let l = Printf.sprintf "while_L%d" !while_label_counter in
  incr while_label_counter; l

let string_of_binop = function
  | Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/" | Mod -> "%"
  | Equal -> "==" | NotEqual -> "!=" | Less -> "<" | LessEqual -> "<="
  | Greater -> ">" | GreaterEqual -> ">="
  | LogicalAnd -> "&&" | LogicalOr -> "||"

let string_of_unop = function
  | UnaryPlus -> "+" | UnaryMinus -> "-" | LogicalNot -> "!"

module SSAMap = Hashtbl
let ssa_version () = Hashtbl.create 32


let ssa_var_name name ver scope_type =
  match scope_type with
  | `Block -> Printf.sprintf "%s_%s_%d_%s" name "Block" ver !current_func  
  | `FBlock -> Printf.sprintf "%s_%s_%d_%s" name "FBlock" ver !current_func
  | `Control -> Printf.sprintf "%s_%s_%d_%s" name "Control" ver !current_func   

(* 修改 get_ssa_name 函数 *)
let get_ssa_name env name scope_type =
  try
    let v = SSAMap.find env name in
    ssa_var_name name v scope_type
  with Not_found -> ssa_var_name name 0 scope_type

(* 修改 inc_ssa_version 函数 *)
let inc_ssa_version env name scope_type =
  let v = try SSAMap.find env name with Not_found -> 0 in
  SSAMap.replace env name (v + 1);
  ssa_var_name name (v + 1) scope_type

(* 添加作用域类型判断函数 *)
let get_current_scope_type scope_stack =
  let is_in_block = function
    | [] -> false
    | _::rest -> 
        if List.length rest > 1 then true  (* 嵌套块 *)
        else false
  in
  if is_in_block scope_stack then `Block
  else `Control

(* 修改 push_scope 函数 *)
let push_scope (kind:scope_kind) =
  scope_kinds := kind :: !scope_kinds;
  scope_stack := (Hashtbl.create 32) :: !scope_stack

(* 修改 pop_scope 函数 *)
let pop_scope () =
  match !scope_stack, !scope_kinds with
  | _::rest, _::rest_kinds -> 
      scope_stack := rest;
      scope_kinds := rest_kinds
  | _ -> failwith "No scope to pop"


(* 在作用域栈中查找变量 *)
let rec lookup_var name = function
  | [] -> None
  | scope::rest ->
      match Hashtbl.find_opt scope name with
      | Some v -> Some v
      | None -> lookup_var name rest

let rec gen_expr (e : expression) (env : (string, int) Hashtbl.t)  (code : tac list ref) : string =
  match e with
  (* | Identifier id -> get_ssa_name env id *)
  | Identifier id -> 
    (* 查找变量最近的定义 *)
    (match lookup_var id !scope_stack with
    | Some v -> v  (* 如果找到了变量的定义，直接使用它的SSA名称 *)
    | None -> 
        (* 如果在当前作用域中找不到，使用Control类型作为默认类型 *)
        get_ssa_name env id `Control)
  | Number n ->
      let t = new_temp () in
      code := !code @ [TacAssign (t, string_of_int n)];
      t
  | UnaryOp (op, e1) ->
      let t1 = gen_expr e1 env code in
      let t = new_temp () in
      code := !code @ [TacUnOp (t, string_of_unop op, t1)];
      t
  | BinaryOp (e1, op, e2) ->
      let t1 = gen_expr e1 env code in
      let t2 = gen_expr e2 env code in
      let t = new_temp () in
      code := !code @ [TacBinOp (t, t1, string_of_binop op, t2)];
      t
  | FunctionCall (fname, args) ->
      let arg_temps = List.map (fun a -> gen_expr a env code) args in
      List.iter (fun t -> code := !code @ [TacParam t]) (List.rev arg_temps);
      let t = new_temp () in
      code := !code @ [TacCall (t, fname, List.length args, arg_temps)];
      t

let rec gen_stmt (s : statement) (env : (string, int) Hashtbl.t) (code : tac list ref) : unit =
  match s with
  | Block stmts -> 
      push_scope Block;  (* 创建新作用域 *)
      let old_env = Hashtbl.copy env in  (* 保存旧环境 *)
      List.iter (fun st -> gen_stmt st env code) stmts;
      (* 恢复旧环境并弹出作用域 *)
      Hashtbl.clear env;
      Hashtbl.iter (fun k v -> Hashtbl.add env k v) old_env;
      pop_scope ();
  | EmptyStmt -> ()
  | ExprStmt e -> ignore (gen_expr e env code)
  | Assignment (id, e) ->
      let t = gen_expr e env code in
      let ssa_id = 
        match lookup_var id !scope_stack with
        | Some v -> v
        | None -> 
          let scope_type = 
            match !scope_kinds with
            | Block :: FBlock :: _ -> 
                `Control  (* 如果是最外层的Block，则是函数作用域，使用Control类型 *)
            | While::_ | If::_ -> 
                `Control  (* 控制结构中使用Control类型 *)
            | Block::_ -> 
                `Block   (* 嵌套块中使用Block类型 *)
            | _ -> 
                `Control (* 默认使用Control类型 *)
          in
          inc_ssa_version env id scope_type
      in
      code := !code @ [TacAssign (ssa_id, t)]
  | VarDecl (id, e) ->
      let t = gen_expr e env code in
      let scope_type = 
      match !scope_kinds with
      | Block :: FBlock :: _ -> 
          `Control  (* 如果是最外层的Block，则是函数作用域，使用Control类型 *)
      | While::_ | If::_ -> 
          `Control  (* 控制结构中使用Control类型 *)
      | Block::_ -> 
          `Block   (* 嵌套块中使用Block类型 *)
      | _ -> 
          `Control (* 默认使用Control类型 *)
    in
      let ssa_id = inc_ssa_version env id scope_type in
      (match !scope_stack with
       | current::_ -> Hashtbl.add current id ssa_id
       | [] -> failwith "No active scope");
      code := !code @ [TacAssign (ssa_id, t)]
   | IfStmt (cond, then_s, else_s_opt) ->
    push_scope If;
    let cond_t = gen_expr cond env code in
    let cond_not_t = new_temp () in
    code := !code @ [TacUnOp (cond_not_t, "!", cond_t)];
    (match else_s_opt with
      | Some else_s ->
         let l_else = if_new_label () in
         (* let l_end = if_new_label () in *)
         code := !code @ [TacIfGoto (cond_not_t, l_else)];
         let l_then = then_new_label () in
          code := !code @ [TacLabel l_then];
         let env_then = Hashtbl.copy env in
         let code_then = ref [] in
         gen_stmt then_s env_then code_then;
         (* code_then := !code_then @ [TacGoto l_end]; *)
         (* Hashtbl.iter (fun k v -> Hashtbl.replace env k v) env_then; *)
         let env_else = Hashtbl.copy env in
         let code_else = ref [] in
         code_else := !code_else @ [TacLabel l_else];
         gen_stmt else_s env_else code_else;
         code := !code @ !code_then @ !code_else;
         (* code := !code @ [TacLabel l_end]; *)
          let vars = Hashtbl.fold (fun k _ acc -> if List.mem k acc then acc else k::acc) env_then [] in
          let vars = Hashtbl.fold (fun k _ acc -> if List.mem k acc then acc else k::acc) env_else vars in
          List.iter (fun var_name ->
            let then_ver = try Hashtbl.find env_then var_name with Not_found -> Hashtbl.find env var_name in
            let else_ver = try Hashtbl.find env_else var_name with Not_found -> Hashtbl.find env var_name in
            let scope_type = get_current_scope_type !scope_stack in
            let then_ssa = ssa_var_name var_name then_ver scope_type in
            let else_ssa = ssa_var_name var_name else_ver scope_type in
            let merged_ver = max then_ver else_ver + 1 in
            Hashtbl.replace env var_name merged_ver;
            let phi_name = ssa_var_name var_name merged_ver scope_type in
            code := !code @ [TacPhi (phi_name, then_ssa, else_ssa)]
          ) vars;
          pop_scope();  
      | None ->
        let l_end = if_new_label () in
        code := !code @ [TacIfGoto (cond_not_t, l_end)];
        gen_stmt then_s env code;
        code := !code @ [TacLabel l_end];
        pop_scope();)
   | WhileStmt (cond, body) ->
      push_scope While;
      let l_cond = while_new_label () in
      let l_body = while_new_label () in
      let l_end = while_new_label () in
      (* 检查循环体是否包含continue语句的标志 *)
      let has_continue = ref false in
      (* 检查循环体中是否有continue语句 *)
      let rec check_continue stmt =
        match stmt with
        | ContinueStmt -> has_continue := true
        | Block stmts -> List.iter check_continue stmts
        | IfStmt (_, then_s, Some else_s) ->
            check_continue then_s;
            check_continue else_s
        | IfStmt (_, then_s, None) ->
            check_continue then_s
        | WhileStmt (_, s) -> check_continue s
        | _ -> ()
      in
      check_continue body;
      break_stack := l_end :: !break_stack;
    if (!has_continue = true) then begin
      let l_continue = while_new_label () in
      continue_stack := l_continue :: !continue_stack;
      code := !code @ [TacGoto l_cond];
      code := !code @ [TacLabel l_cond];
      let cond_t = gen_expr cond env code in
      let cond_not_t = new_temp () in
      code := !code @ [TacUnOp (cond_not_t, "!", cond_t)];
      code := !code @ [TacIfGoto (cond_not_t, l_end)];                 
      code := !code @ [TacLabel l_body];
      gen_stmt body env code;
      code := !code @ [TacGoto l_cond]; 
      code := !code @ [TacLabel l_continue];
      code := !code @ [TacGoto l_cond]; 
      code := !code @ [TacLabel l_end];
      continue_stack := List.tl !continue_stack;
      break_stack := List.tl !break_stack
    end
    else begin
      code := !code @ [TacGoto l_cond];
      code := !code @ [TacLabel l_cond];
      let cond_t = gen_expr cond env code in
      let cond_not_t = new_temp () in
      code := !code @ [TacUnOp (cond_not_t, "!", cond_t)];
      code := !code @ [TacIfGoto (cond_not_t, l_end)];                 
      code := !code @ [TacLabel l_body];
      gen_stmt body env code;
      code := !code @ [TacGoto l_cond];  
      code := !code @ [TacLabel l_end];
      break_stack := List.tl !break_stack
    end;
      pop_scope ();

   | BreakStmt ->
      (match !break_stack with
       | l_end :: _ -> code := !code @ [TacGoto l_end]
       | [] -> code := !code @ [TacComment ("a0", "break (not in loop)", [])])

  | ContinueStmt ->
      (match !continue_stack with
       | l_cond :: _ -> code := !code @ [TacGoto l_cond]
       | [] -> code := !code @ [TacComment ("a0", "continue (not in loop)", [])])

  | ReturnStmt eo ->
      (match eo with
      | None -> code := !code @ [TacReturn None]
      | Some e ->
          let t = gen_expr e env code in
          code := !code @ [TacReturn (Some t)])

let gen_func (FuncDef (ret_ty, name, params, body)) : tac list =
  current_func := name;
  (* let a = List.map (function Param id -> id) params in
  let t = new_temp () in
  let code = ref [TacComment (t, "function " ^ name, a)] in *)
  let env = ssa_version () in
  push_scope FBlock;  (* 创建函数作用域 *)
  (* 处理函数参数 *)
  let param_names = List.map (function Param id -> 
    let ssa_id = get_ssa_name env id `Control in  (* 使用Control类型 *)
    match !scope_stack with
    | current::_ -> 
        Hashtbl.add current id ssa_id;  (* 添加到当前作用域 *)
        id ^ "_Control_0_" ^ name 
    | [] -> failwith "No active scope"
  ) params in

  let t = new_temp () in
  let code = ref [TacComment (t, "function " ^ name, param_names)] in
  code := !code @ [TacLabel name];
  let env = ssa_version () in
  gen_stmt body env code;
  (match ret_ty, List.rev !code with
   | Void, last::_ ->
      (match last with
       | TacReturn None -> ()
       | _ -> code := !code @ [TacReturn None])
   | _ -> ());
   pop_scope ();  (* 弹出函数作用域 *)
  !code

let gen_comp_unit (cu : comp_unit) : tac list =
  List.flatten (List.map gen_func cu)
