(* filepath: /home/lee77/PLC-Summer/program/Edit2/test/ast_test.ml *)
open Lib.Ast
open Lib.Lexer
open Lib.Parser

(* 打印AST的辅助函数 *)
let print_type_specifier = function
  | Int -> "int"
  | Void -> "void"

let print_binary_operator = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Equal -> "=="
  | NotEqual -> "!="
  | Less -> "<"
  | LessEqual -> "<="
  | Greater -> ">"
  | GreaterEqual -> ">="
  | LogicalAnd -> "&&"
  | LogicalOr -> "||"

let print_unary_operator = function
  | UnaryPlus -> "+"
  | UnaryMinus -> "-"
  | LogicalNot -> "!"

let rec print_expression = function
  | Identifier id -> id
  | Number n -> string_of_int n
  | UnaryOp (op, e) -> Printf.sprintf "(%s%s)" (print_unary_operator op) (print_expression e)
  | BinaryOp (e1, op, e2) -> 
      Printf.sprintf "(%s %s %s)" (print_expression e1) (print_binary_operator op) (print_expression e2)
  | FunctionCall (name, args) ->
      let arg_strs = List.map print_expression args in
      Printf.sprintf "%s(%s)" name (String.concat ", " arg_strs)

let print_param = function
  | Param id -> Printf.sprintf "int %s" id

let rec print_statement indent = function
  | Block stmts ->
      let stmt_strs = List.map (print_statement (indent ^ "  ")) stmts in
      Printf.sprintf "%s{\n%s\n%s}" indent (String.concat "\n" stmt_strs) indent
  | EmptyStmt -> Printf.sprintf "%s;" indent
  | ExprStmt e -> Printf.sprintf "%s%s;" indent (print_expression e)
  | Assignment (id, e) -> Printf.sprintf "%s%s = %s;" indent id (print_expression e)
  | VarDecl (id, e) -> Printf.sprintf "%sint %s = %s;" indent id (print_expression e)
  | IfStmt (cond, then_stmt, None) ->
      Printf.sprintf "%sif (%s)\n%s" 
        indent (print_expression cond) (print_statement (indent ^ "  ") then_stmt)
  | IfStmt (cond, then_stmt, Some else_stmt) ->
      Printf.sprintf "%sif (%s)\n%s\n%selse\n%s" 
        indent (print_expression cond) 
        (print_statement (indent ^ "  ") then_stmt)
        indent
        (print_statement (indent ^ "  ") else_stmt)
  | WhileStmt (cond, body) ->
      Printf.sprintf "%swhile (%s)\n%s" 
        indent (print_expression cond) (print_statement (indent ^ "  ") body)
  | BreakStmt -> Printf.sprintf "%sbreak;" indent
  | ContinueStmt -> Printf.sprintf "%scontinue;" indent
  | ReturnStmt None -> Printf.sprintf "%sreturn;" indent
  | ReturnStmt (Some e) -> Printf.sprintf "%sreturn %s;" indent (print_expression e)

let print_func_def = function
  | FuncDef (ts, name, params, body) ->
      let param_strs = List.map print_param params in
      Printf.sprintf "%s %s(%s)\n%s" 
        (print_type_specifier ts) name (String.concat ", " param_strs)
        (print_statement "" body)

let print_comp_unit comp_unit =
  Printf.printf "=== ToyC Program AST ===\n\n";
  List.iteri (fun i func_def ->
    Printf.printf "Function %d:\n" (i + 1);
    Printf.printf "%s\n\n" (print_func_def func_def)
  ) comp_unit

let parse_file filename =
  let ic = open_in filename in
  let lexbuf = Lexing.from_channel ic in
  Lexing.set_filename lexbuf filename;
  try
    let ast = comp_unit token lexbuf in
    close_in ic;
    ast
  with
  | e -> 
    close_in ic;
    let pos = Lexing.lexeme_start_p lexbuf in
    Printf.eprintf "Error in file %s at line %d, character %d\n" 
      pos.pos_fname
      pos.pos_lnum 
      (pos.pos_cnum - pos.pos_bol + 1);
    raise e

let test_single_file filename =
  Printf.printf "\n=== Testing AST for: %s ===\n" filename;
  try
    let ast = parse_file filename in
    print_comp_unit ast;
    Printf.printf "✓ AST test passed for %s\n" filename;
    true
  with
  | Sys_error msg -> 
    Printf.eprintf "✗ File error for %s: %s\n" filename msg; 
    false
  | Parsing.Parse_error -> 
    Printf.eprintf "✗ Parse error for %s\n" filename; 
    false
  | Lib.Lexer.LexError msg -> 
    Printf.eprintf "✗ Lexical error for %s: %s\n" filename msg; 
    false
  | e -> 
    Printf.eprintf "✗ Error for %s: %s\n" filename (Printexc.to_string e); 
    false

let test_directory dir_path =
  Printf.printf "\n=== Running AST Tests from %s ===\n" dir_path;
  let files = Sys.readdir dir_path in
  let c_files = Array.to_list files |> List.filter (fun f -> Filename.check_suffix f ".c") in
  let c_files = List.sort String.compare c_files in
  
  let total = List.length c_files in
  let passed = ref 0 in
  
  List.iter (fun file ->
    let full_path = Filename.concat dir_path file in
    if test_single_file full_path then
      incr passed
  ) c_files;
  
  Printf.printf "\n=== AST Test Summary ===\n";
  Printf.printf "Total: %d, Passed: %d, Failed: %d\n" total !passed (total - !passed);
  
  if !passed = total then
    Printf.printf "✓ All AST tests passed!\n"
  else
    Printf.printf "✗ %d AST tests failed!\n" (total - !passed)

let run_tests () =
  test_directory "test/test_Ast"