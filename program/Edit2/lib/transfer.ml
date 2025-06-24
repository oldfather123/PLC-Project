open Ast

type tac =
  | TacAssign of string * string
  | TacBinOp of string * string * string * string
  | TacUnOp of string * string * string
  | TacLabel of string
  | TacGoto of string
  | TacIfGoto of string * string
  | TacParam of string
  | TacCall of string * string * int
  | TacReturn of string option
  | TacComment of string

let temp_counter = ref 0
let label_counter = ref 0
let break_stack = ref []
let continue_stack = ref []
let new_temp () =
  let t = Printf.sprintf "t%d" !temp_counter in
  incr temp_counter; t

let new_label () =
  let l = Printf.sprintf "L%d" !label_counter in
  incr label_counter; l

let string_of_binop = function
  | Add -> "+" | Sub -> "-" | Mul -> "*" | Div -> "/" | Mod -> "%"
  | Equal -> "==" | NotEqual -> "!=" | Less -> "<" | LessEqual -> "<="
  | Greater -> ">" | GreaterEqual -> ">="
  | LogicalAnd -> "&&" | LogicalOr -> "||"

let string_of_unop = function
  | UnaryPlus -> "+" | UnaryMinus -> "-" | LogicalNot -> "!"

module SSAMap = Hashtbl
let ssa_version () = Hashtbl.create 32

let ssa_var_name name ver =
  Printf.sprintf "%s_%d" name ver

let get_ssa_name env name =
  try
    let v = SSAMap.find env name in
    ssa_var_name name v
  with Not_found -> ssa_var_name name 0

let inc_ssa_version env name =
  let v = try SSAMap.find env name with Not_found -> 0 in
  SSAMap.replace env name (v + 1);
  ssa_var_name name (v + 1)

let rec gen_expr (e : expression) (env : (string, int) Hashtbl.t)  (code : tac list ref) : string =
  match e with
  | Identifier id -> get_ssa_name env id
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
      code := !code @ [TacCall (t, fname, List.length args)];
      t

let rec gen_stmt (s : statement) (env : (string, int) Hashtbl.t) (code : tac list ref) : unit =
  match s with
  | Block stmts -> List.iter (fun st -> gen_stmt st env code) stmts
  | EmptyStmt -> ()
  | ExprStmt e -> ignore (gen_expr e env code)
  | Assignment (id, e) ->
      let t = gen_expr e env code in
      let ssa_id = inc_ssa_version env id in
      code := !code @ [TacAssign (ssa_id, t)]
  | VarDecl (id, e) ->
      let t = gen_expr e env code in
      let ssa_id = inc_ssa_version env id in
      code := !code @ [TacAssign (ssa_id, t)]
  | IfStmt (cond, then_s, else_s_opt) ->
      let l_true = new_label () in
      let l_end = new_label () in
      let cond_t = gen_expr cond env code in
      code := !code @ [TacIfGoto (cond_t, l_true)];
      (match else_s_opt with
      | Some else_s ->
          (* 复制环境，分支独立 *)
          let env_else = Hashtbl.copy env in
          gen_stmt else_s env_else code;
          code := !code @ [TacGoto l_end];
          code := !code @ [TacLabel l_true];
          let env_then = Hashtbl.copy env in
          gen_stmt then_s env_then code;
          code := !code @ [TacLabel l_end]
          (* 这里未实现phi合并，适合简单情况 *)
      | None ->
          code := !code @ [TacLabel l_true];
          gen_stmt then_s env code;
          code := !code @ [TacLabel l_end])
  | WhileStmt (cond, body) ->
      let l_begin = new_label () in
      let l_true = new_label () in
      let l_end = new_label () in
      continue_stack := l_begin :: !continue_stack;
      break_stack := l_end :: !break_stack;
      code := !code @ [TacLabel l_begin];
      let cond_t = gen_expr cond env code in
      code := !code @ [TacIfGoto (cond_t, l_true)];
      code := !code @ [TacGoto l_end];
      code := !code @ [TacLabel l_true];
      gen_stmt body env code;
      code := !code @ [TacGoto l_begin];
      code := !code @ [TacLabel l_end];
      continue_stack := List.tl !continue_stack;
      break_stack := List.tl !break_stack;
  | BreakStmt -> 
    (match !break_stack with
      | l_end :: _ -> code := !code @ [TacGoto l_end]
      | [] -> code := !code @ [TacComment "break (no loop context)"])
  | ContinueStmt -> 
    (match !continue_stack with
      | l_begin :: _ -> code := !code @ [TacGoto l_begin]
      | [] -> code := !code @ [TacComment "continue (no loop context)"])
  | ReturnStmt eo ->
      (match eo with
      | None -> code := !code @ [TacReturn None]
      | Some e ->
          let t = gen_expr e env code in
          code := !code @ [TacReturn (Some t)])

let gen_func (FuncDef (_ret_ty, name, _params, body)) : tac list =
  let code = ref [TacComment ("function " ^ name)] in
  let env = ssa_version () in
  gen_stmt body env code;
  !code

let gen_comp_unit (cu : comp_unit) : tac list =
  List.flatten (List.map gen_func cu)
