open Interpreterlib
open Ast
let rec string_of_expr = function
  | Int x -> Printf.sprintf "Int %d" x
  | Var i -> Printf.sprintf "Var %s" i
  | Bool b ->
    let sign = match b with
      | true -> "true"
      | false -> "false"
    in Printf.sprintf "Bool %s" sign
  | Binop (binop, e1, e2) -> 
    let bop = match binop with
      | Add -> "Add"
      | Sub -> "Sub"
      | Mul -> "Mul"
      | Div -> "Div"
      | Leq -> "Leq"
    in Printf.sprintf "Binop (%s, %s, %s)" bop (string_of_expr e1) (string_of_expr e2)
  | If (e1, e2, e3) -> Printf.sprintf "If (%s, %s, %s)" (string_of_expr e1) (string_of_expr e2) (string_of_expr e3)
  | Let (x, e1, e2) -> Printf.sprintf "Let (%s, %s, %s)" x (string_of_expr e1) (string_of_expr e2)
  | Func (x, e) -> Printf.sprintf "Func (%s, %s)" x (string_of_expr e)
  | App (e1, e2) -> Printf.sprintf "App (%s, %s)" (string_of_expr e1) (string_of_expr e2)
let parse s : expr =
  let lexbuf = Lexing.from_string s in
  let ast = Parser.main Lexer.read lexbuf in
  ast
let is_value = function
  | Int _ | Bool _ | Func _ -> true
  | Var _ | Binop _ | If _ | Let _ | App _ -> false
module VarSet = Set.Make(String)
let singleton = VarSet.singleton
let union = VarSet.union
let diff = VarSet.diff
let mem = VarSet.mem
let rec freevar : expr -> VarSet.t = function
  | Var x -> singleton x
  | App (e1, e2) -> union (freevar e1) (freevar e2)
  | Func (x, e) -> diff (freevar e) (singleton x)
  | _ -> failwith "Unnecessary generation"
let gensym =
  let counter = ref 0 in
  fun () ->
    incr counter; "$x" ^ string_of_int !counter
let rec replace e v x = match e with
  | Var y -> if y = x then Var v else e
  | App (e1, e2) -> App (replace e1 v x, replace e2 v x)
  | Func (y, e1) -> Func ((if y = x then v else y), replace e1 v x)
let rec subst e v x = match e with
  | Int _ | Bool _ -> e
  | Var y -> if y = x then v else e
  | Binop (binop, e1, e2) -> Binop (binop, subst e1 v x, subst e2 v x)
  | If (e1, e2, e3) -> If (subst e1 v x, subst e2 v x, subst e3 v x)
  | Let (y, e1, e2) -> if y = x then Let (y, subst e1 e x, e2) else Let (y, subst e1 v x, subst e2 v x)
  | App (e1, e2) -> App (subst e1 v x, subst e2 v x)
  | Func (y, e1) -> 
    if y = x then e
    else if not (mem y (freevar v)) then Func (y, subst e1 v x)
    else 
      let newvar = gensym () in
      let newexpr = replace e1 newvar y in
      Func (newvar, subst newexpr v x)
let rec step = function
  | Int _ -> failwith "Does not step on an integer"
  | Bool _ -> failwith "Does not step on a boolean"
  | Var _ -> failwith "Variable is unsteppable"
  | Binop (binop, e1, e2) when is_value e1 && is_value e2 -> step_binop binop e1 e2
  | Binop (binop, e1, e2) when is_value e1 -> Binop (binop, e1, step e2)
  | Binop (binop, e1, e2) -> Binop (binop, step e1, e2)
  | If (Bool true, e2, _) -> e2
  | If (Bool false, _, e3) -> e3
  | If (Int _, _, _) -> failwith "Condition must be a boolean"
  | If (e1, e2, e3) -> If (step e1, e2, e3) 
  | Let (x, e1, e2) when is_value e1 -> subst e2 e1 x
  | Let (x, e1, e2) -> Let (x, step e1, e2)
  | _ -> failwith "Func and App not using small-step"
and step_binop binop e1 e2 = match binop, e1, e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Sub, Int a, Int b -> Int (a - b)
  | Mul, Int a, Int b -> Int (a * b)
  | Div, Int a, Int b when b <> 0 -> Int (a / b)
  | Div, Int _, Int 0 -> failwith "Can't be divided by zero"
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Not binop operations"
let rec eval e = 
  if is_value e then e
  else e |> step |> eval
let interp s = 
  s |> parse |> eval |> string_of_expr
type strategy = CBV | CBN
let curr_strat = CBV
let rec eval_big e = match e with
  | Int _ | Bool _ | Func _ -> e
  | Var _ -> failwith "Variable is unsteppable"
  | Binop (binop, e1, e2) -> eval_bop binop e1 e2
  | If (e1, e2, e3) -> eval_if e1 e2 e3
  | Let (x, e1, e2) -> eval_big (subst e2 (eval_big e1) x)
  | App (e1, e2) -> eval_app e1 e2
and eval_bop binop e1 e2 = match binop, eval_big e1, eval_big e2 with
  | Add, Int a, Int b -> Int (a + b)
  | Sub, Int a, Int b -> Int (a - b)
  | Mul, Int a, Int b -> Int (a * b)
  | Div, Int a, Int b when b <> 0 -> Int (a / b)
  | Div, Int _, Int 0 -> failwith "Can't be divided by zero"
  | Leq, Int a, Int b -> Bool (a <= b)
  | _ -> failwith "Not binop operations"
and eval_if e1 e2 e3 = match eval_big e1 with
  | Bool true -> eval_big e2
  | Bool false -> eval_big e3
  | _ -> failwith "Not if operations"
and eval_app e1 e2 = match eval_big e1 with
  | Func (x, e) -> 
    let e' = match curr_strat with
      | CBV -> eval_big e2
      | CBN -> e2
    in
    eval_big (subst e e' x)
  | _ ->  failwith "Must apply to a function"
let interp_big s = 
  s |> parse |> eval_big |> string_of_expr
let () =
  let filename = "/home/oldfather/ocaml/exam/tut5/test3.in" in
  let in_channel = open_in filename in
  let file_content = really_input_string in_channel (in_channel_length in_channel) in
  close_in in_channel;
  (* let res = interp file_content in
  Printf.printf "Result of interpreting: %s\n" res; *)
  let res = interp_big file_content in
  Printf.printf "Result of interpreting with big-step model: %s\n" res;
  let ast = parse file_content in
  Printf.printf "AST: %s\n" (string_of_expr ast);