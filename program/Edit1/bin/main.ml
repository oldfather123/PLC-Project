open Lib.Ast
open Lib.Lexer
open Lib.Parser

(* 打印AST的辅助函数 *)
let print_type_specifier = function
  | Int -> "int"
  | Char -> "char"
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
  | BitwiseAnd -> "&"
  | BitwiseOr -> "|"
  | BitwiseXor -> "^"
  | LeftShift -> "<<"
  | RightShift -> ">>"
  | Assign -> "="

let print_unary_operator = function
  | UnaryPlus -> "+"
  | UnaryMinus -> "-"
  | LogicalNot -> "!"
  | BitwiseNot -> "~"

let print_constant = function
  | IntConst i -> string_of_int i
  | CharConst c -> Printf.sprintf "'%c'" c
  | StringConst s -> Printf.sprintf "\"%s\"" s

let rec print_expression = function
  | Identifier id -> id
  | Constant c -> print_constant c
  | UnaryOp (op, e) -> Printf.sprintf "(%s%s)" (print_unary_operator op) (print_expression e)
  | BinaryOp (e1, op, e2) -> 
      Printf.sprintf "(%s %s %s)" (print_expression e1) (print_binary_operator op) (print_expression e2)
  | FunctionCall (name, args) ->
      let arg_strs = List.map print_expression args in
      Printf.sprintf "%s(%s)" name (String.concat ", " arg_strs)
  | ArrayAccess (arr, idx) ->
      Printf.sprintf "%s[%s]" (print_expression arr) (print_expression idx)
  | PostIncrement e -> Printf.sprintf "(%s)++" (print_expression e)
  | PostDecrement e -> Printf.sprintf "(%s)--" (print_expression e)
  | PreIncrement e -> Printf.sprintf "++(%s)" (print_expression e)
  | PreDecrement e -> Printf.sprintf "--(%s)" (print_expression e)
  | ConditionalExpr (cond, then_expr, else_expr) ->
      Printf.sprintf "(%s ? %s : %s)" 
        (print_expression cond) (print_expression then_expr) (print_expression else_expr)
  | Assignment (lval, rval) ->
      Printf.sprintf "%s = %s" (print_expression lval) (print_expression rval)

let rec print_declarator = function
  | DirectDeclarator id -> id
  | PointerDeclarator d -> Printf.sprintf "*%s" (print_declarator d)
  | ArrayDeclarator (d, None) -> Printf.sprintf "%s[]" (print_declarator d)
  | ArrayDeclarator (d, Some size) -> 
      Printf.sprintf "%s[%s]" (print_declarator d) (print_expression size)
  | FunctionDeclarator (d, params) ->
      let param_strs = List.map print_parameter params in
      Printf.sprintf "%s(%s)" (print_declarator d) (String.concat ", " param_strs)

and print_parameter = function
  | Parameter (ts, d) -> 
      Printf.sprintf "%s %s" (print_type_specifier ts) (print_declarator d)

let print_init_declarator = function
  | InitDeclarator (d, None) -> print_declarator d
  | InitDeclarator (d, Some init) -> 
      Printf.sprintf "%s = %s" (print_declarator d) (print_expression init)

let print_declaration = function
  | Declaration (ts, init_declarators) ->
      let decl_strs = List.map print_init_declarator init_declarators in
      Printf.sprintf "%s %s;" (print_type_specifier ts) (String.concat ", " decl_strs)

let rec print_statement indent = function
  | ExpressionStmt None -> Printf.sprintf "%s;" indent
  | ExpressionStmt (Some e) -> Printf.sprintf "%s%s;" indent (print_expression e)
  | CompoundStmt stmts ->
      let stmt_strs = List.map (print_statement (indent ^ "  ")) stmts in
      Printf.sprintf "%s{\n%s\n%s}" indent (String.concat "\n" stmt_strs) indent
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
  | ForStmt (init, cond, update, body) ->
      let init_str = match init with None -> "" | Some e -> print_expression e in
      let cond_str = match cond with None -> "" | Some e -> print_expression e in
      let update_str = match update with None -> "" | Some e -> print_expression e in
      Printf.sprintf "%sfor (%s; %s; %s)\n%s" 
        indent init_str cond_str update_str (print_statement (indent ^ "  ") body)
  | ReturnStmt None -> Printf.sprintf "%sreturn;" indent
  | ReturnStmt (Some e) -> Printf.sprintf "%sreturn %s;" indent (print_expression e)
  | BreakStmt -> Printf.sprintf "%sbreak;" indent
  | ContinueStmt -> Printf.sprintf "%scontinue;" indent
  | DeclarationStmt d -> Printf.sprintf "%s%s" indent (print_declaration d)

let print_function_definition = function
  | FunctionDef (ts, d, decls, body) ->
      let decl_strs = List.map print_declaration decls in
      let decls_section = if decls = [] then "" else 
        Printf.sprintf "\n%s\n" (String.concat "\n" decl_strs) in
      Printf.sprintf "%s %s%s\n%s" 
        (print_type_specifier ts) (print_declarator d) decls_section 
        (print_statement "" body)

let print_external_declaration = function
  | FuncDef fd -> print_function_definition fd
  | Decl d -> print_declaration d

let print_translation_unit tu =
  Printf.printf "=== C Program AST ===\n\n";
  List.iteri (fun i ext_decl ->
    Printf.printf "External Declaration %d:\n" (i + 1);
    Printf.printf "%s\n\n" (print_external_declaration ext_decl)
  ) tu

let parse_file filename =
  let ic = open_in filename in
  let lexbuf = Lexing.from_channel ic in
  (* 设置文件名用于错误报告 *)
  Lexing.set_filename lexbuf filename;
  try
    let ast = translation_unit token lexbuf in
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

let () =
  if Array.length Sys.argv <> 2 then (
    Printf.eprintf "Usage: %s <input_file>\n" Sys.argv.(0);
    exit 1
  );
  
  let filename = Sys.argv.(1) in
  try
    let ast = parse_file filename in
    print_translation_unit ast
  with
  | Sys_error msg -> Printf.eprintf "Error: %s\n" msg
  | Parsing.Parse_error -> Printf.eprintf "Parse error\n"
  | Lib.Lexer.LexError msg -> Printf.eprintf "Lexical error: %s\n" msg
  | e -> Printf.eprintf "Error: %s\n" (Printexc.to_string e)