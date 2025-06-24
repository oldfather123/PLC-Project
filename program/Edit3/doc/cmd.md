### 运行所有AST测试
```bash
    dune exec Edit3 test ast
```

### 运行所有解释器测试  
```bash
    dune exec Edit3 test interp
```

### 运行所有测试
```bash
    dune exec Edit3 test all
```

### 测试单个文件（AST）
```bash
    dune exec Edit3 parse test/test_Ast/test1.c
```

### 执行单个文件
```bash
    dune exec Edit3 run test/test_Interp/test1.c
```

```ocaml
    open Lib.Ast
    open Lib.Lexer
    open Lib.Parser
    open Lib.Interpreter

    (* 主程序入口 *)

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

    let () =
    if Array.length Sys.argv <> 3 then (
        Printf.eprintf "Usage: %s <input_file> <mode>\n" Sys.argv.(0);
        Printf.eprintf "  mode: parse  - show AST only\n";
        Printf.eprintf "        run    - parse and execute\n";
        Printf.eprintf "        both   - show AST and execute\n";
        exit 1
    );
    
    let filename = Sys.argv.(1) in
    let mode = Sys.argv.(2) in
    
    try
        let ast = parse_file filename in
        
        (match mode with
        | "parse" -> 
            print_comp_unit ast
        | "run" -> 
            Printf.printf "=== Executing ToyC Program ===\n\n";
            let exit_code = run_program ast in
            Printf.printf "\n=== Program Exit Code: %d ===\n" exit_code
        | "both" -> 
            print_comp_unit ast;
            Printf.printf "=== Executing ToyC Program ===\n\n";
            let exit_code = run_program ast in
            Printf.printf "\n=== Program Exit Code: %d ===\n" exit_code
        | _ -> 
            Printf.eprintf "Invalid mode: %s\n" mode;
            Printf.eprintf "Valid modes: parse, run, both\n";
            exit 1)
    with
    | Sys_error msg -> Printf.eprintf "Error: %s\n" msg; exit 1
    | Parsing.Parse_error -> Printf.eprintf "Parse error\n"; exit 1
    | Lib.Lexer.LexError msg -> Printf.eprintf "Lexical error: %s\n" msg; exit 1
    | e -> Printf.eprintf "Error: %s\n" (Printexc.to_string e); exit 1

```