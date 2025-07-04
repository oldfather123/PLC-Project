(* lib/interpreter.ml *)

module A = Ast
module E = Env

let rec eval_expr (env : E.t) (e : A.expression) : E.value =
  match e with
  | A.Number n -> E.Number n
  | A.Identifier name -> E.find_var env name
  | A.UnaryOp (op, e1) -> (
      match eval_expr env e1 with
      | E.Number n ->
          let result = match op with
            | A.UnaryPlus -> n
            | A.UnaryMinus -> -n
            | A.LogicalNot -> if n = 0 then 1 else 0
          in
          E.Number result
      | _ -> raise (E.RuntimeError "Unary operation on non-number")
    )
  | A.BinaryOp (e1, op, e2) -> (
      match eval_expr env e1, eval_expr env e2 with
      | E.Number v1, E.Number v2 ->
          let result = match op with
            | A.Add -> v1 + v2
            | A.Sub -> v1 - v2
            | A.Mul -> v1 * v2
            | A.Div -> if v2 = 0 then raise (E.RuntimeError "Division by zero") else v1 / v2
            | A.Mod ->if v2 = 0 then raise (E.RuntimeError "Modulo by zero") else v1 mod v2
            | A.Equal -> if v1 = v2 then 1 else 0
            | A.NotEqual -> if v1 <> v2 then 1 else 0
            | A.Less -> if v1 < v2 then 1 else 0
            | A.LessEqual -> if v1 <= v2 then 1 else 0
            | A.Greater -> if v1 > v2 then 1 else 0
            | A.GreaterEqual -> if v1 >= v2 then 1 else 0
            | A.LogicalAnd -> if v1 <> 0 && v2 <> 0 then 1 else 0
            | A.LogicalOr -> if v1 <> 0 || v2 <> 0 then 1 else 0
          in
          E.Number result
      | _ -> raise (E.RuntimeError "Binary operation on non-numbers")
    )
  | A.FunctionCall (fname, args) ->
      let A.FuncDef (_, _, params, body) = E.find_func env fname in
      if List.length args <> List.length params then
        raise (E.RuntimeError ("Function " ^ fname ^ " called with wrong number of arguments"));
      let new_env = E.create ~parent:(Some env) () in
      List.iter2
        (fun (A.Param pname) arg_expr ->
          let arg_val = eval_expr env arg_expr in
          E.set_var new_env pname arg_val)
        params args;
      try
        eval_stmt new_env body;
        E.Number 0
      with
      | E.Return (Some v) -> v
      | E.Return None -> E.Number 0

and eval_stmt (env : E.t) (s : A.statement) : unit =
  match s with
  | A.Block stmts -> List.iter (eval_stmt env) stmts
  | A.EmptyStmt -> ()
  | A.ExprStmt e -> ignore (eval_expr env e)
  | A.Assignment (name, e) ->
      let v = eval_expr env e in
      E.set_var env name v
  | A.VarDecl (name, e) ->
      let v = eval_expr env e in
      E.set_var env name v
  | A.IfStmt (cond, then_stmt, else_stmt_opt) ->
      let v = eval_expr env cond in
      (match v with
       | E.Number n ->
           if n <> 0 then eval_stmt env then_stmt
           else Option.iter (eval_stmt env) else_stmt_opt
       | _ -> raise (E.RuntimeError "Non-number used as condition"))
  | A.WhileStmt (cond, body) ->
      let rec loop () =
        match eval_expr env cond with
        | E.Number n when n <> 0 ->
            (try
               eval_stmt env body;
               loop ()
             with
             | E.Continue -> loop ()
             | E.Break -> ())
        | E.Number _ -> ()
        | _ -> raise (E.RuntimeError "Non-number used as condition")
      in loop ()
  | A.BreakStmt -> raise E.Break
  | A.ContinueStmt -> raise E.Continue
  | A.ReturnStmt None -> raise (E.Return None)
  | A.ReturnStmt (Some e) ->
      let v = eval_expr env e in
      raise (E.Return (Some v))
