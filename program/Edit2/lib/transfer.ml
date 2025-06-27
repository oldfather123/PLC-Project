open Ast

type tac =
  | TacAssign of string * string
  | TacBinOp of string * string * string * string
  | TacUnOp of string * string * string
  | TacLabel of string
  | TacGoto of string
  | TacIfGoto of string * string
  | TacParam of string
  | TacCall of string * string * identifier list * int
  | TacReturn of string option
  | TacComment of string
  | TacPhi of string * string * string

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
      code := !code @ [TacCall (t, fname, arg_temps, List.length args)];
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
    let cond_t = gen_expr cond env code in
    let cond_not_t = new_temp () in
    code := !code @ [TacUnOp (cond_not_t, "!", cond_t)];
    (match else_s_opt with
      | Some else_s ->
         let l_else = new_label () in
         let l_end = new_label () in
         code := !code @ [TacIfGoto (cond_not_t, l_else)];
         let env_then = Hashtbl.copy env in
         let code_then = ref [] in
         gen_stmt then_s env_then code_then;
         code_then := !code_then @ [TacGoto l_end];
         (* Hashtbl.iter (fun k v -> Hashtbl.replace env k v) env_then; *)
         let env_else = Hashtbl.copy env in
         let code_else = ref [] in
         code_else := !code_else @ [TacLabel l_else];
         gen_stmt else_s env_else code_else;
         code := !code @ !code_then @ !code_else;
         code := !code @ [TacLabel l_end];
          let vars = Hashtbl.fold (fun k _ acc -> if List.mem k acc then acc else k::acc) env_then [] in
          let vars = Hashtbl.fold (fun k _ acc -> if List.mem k acc then acc else k::acc) env_else vars in
          List.iter (fun var_name ->
            let then_ver = try Hashtbl.find env_then var_name with Not_found -> Hashtbl.find env var_name in
            let else_ver = try Hashtbl.find env_else var_name with Not_found -> Hashtbl.find env var_name in
            let then_ssa = ssa_var_name var_name then_ver in
            let else_ssa = ssa_var_name var_name else_ver in
            (* if then_ssa <> else_ssa then *)
            let merged_ver = max then_ver else_ver + 1 in
            Hashtbl.replace env var_name merged_ver;
            let phi_name = ssa_var_name var_name merged_ver in
            code := !code @ [TacPhi (phi_name, then_ssa, else_ssa)]
          ) vars  
      | None ->
        let l_end = new_label () in
        code := !code @ [TacIfGoto (cond_not_t, l_end)];
        gen_stmt then_s env code;
        code := !code @ [TacLabel l_end])
   | WhileStmt (cond, body) ->
      let l_cond = new_label () in
      let l_body = new_label () in
      let l_end = new_label () in
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
      let l_continue = new_label () in
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
    end

   | BreakStmt ->
      (match !break_stack with
       | l_end :: _ -> code := !code @ [TacGoto l_end]
       | [] -> code := !code @ [TacComment "break (not in loop)"])

  | ContinueStmt ->
      (match !continue_stack with
       | l_cond :: _ -> code := !code @ [TacGoto l_cond]
       | [] -> code := !code @ [TacComment "continue (not in loop)"])

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
