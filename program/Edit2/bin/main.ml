open Lib.Ast
open Lib.Lexer
open Lib.Parser
open Lib.Transfer
open Lib.Riscv_gen

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
      Printf.sprintf "%s %s %s" (print_expression e1) (print_binary_operator op) (print_expression e2)
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

let test_files = [ 
  "test/test1.c"; "test/test2.c"; "test/test3.c"; "test/test4.c"; "test/test5.c";
  "test/test6.c"; "test/test7.c"; "test/test8.c"; "test/test9.c"; "test/test10.c"; "test/test11.c"
]


let run_comp_unit comp_unit =
  let env = Lib.Env.create () in
  List.iter (Lib.Env.add_func env) comp_unit;
  match Lib.Env.find_func env "main" with
  | FuncDef (_, _, _, body) ->
      let ret_val =
        try
          Lib.Interpreter.eval_stmt env body;
          Lib.Env.Number 0  (* 如果 main 没有return，默认0 *)
        with
        | Lib.Env.Return (Some v) -> v
        | Lib.Env.Return None -> Lib.Env.Number 0
      in
      (match ret_val with
       | Lib.Env.Number n -> Printf.printf "Program returned: %d\n" n
       | _ -> Printf.printf "Program returned a function\n")
  | exception _ -> Printf.eprintf "No 'main' function found\n"

let string_of_tac = function
  | TacAssign (a, b) -> Printf.sprintf "%s = %s" a b
  | TacBinOp (a, b, op, c) -> Printf.sprintf "%s = %s %s %s" a b op c
  | TacUnOp (a, op, b) -> Printf.sprintf "%s = %s %s" a op b
  | TacLabel l -> l ^ ":"
  | TacGoto l -> "goto " ^ l
  | TacIfGoto (cond, l) -> Printf.sprintf "if %s goto %s" cond l
  | TacParam t -> "param " ^ t
  | TacCall (t, f, n) -> Printf.sprintf "%s = call %s, %d" t f n
  | TacReturn None -> "return"
  | TacReturn (Some t) -> "return " ^ t
  | TacComment s -> "# " ^ s
  | TacPhi (p,t,e) -> Printf.sprintf "%s = phi(%s, %s)" p t e

let print_tac tac_list =
  List.iter (fun tac -> print_endline (string_of_tac tac)) tac_list

let print_riscv_inst = function
  | RAdd (rd, rs1, rs2) -> Printf.printf "add %s, %s, %s\n" rd rs1 rs2
  | RSub (rd, rs1, rs2) -> Printf.printf "sub %s, %s, %s\n" rd rs1 rs2
  | RMul (rd, rs1, rs2) -> Printf.printf "mul %s, %s, %s\n" rd rs1 rs2
  | RDiv (rd, rs1, rs2) -> Printf.printf "div %s, %s, %s\n" rd rs1 rs2
  | RRem (rd, rs1, rs2) -> Printf.printf "rem %s, %s, %s\n" rd rs1 rs2
  | RSlt (rd, rs1, rs2) -> Printf.printf "slt %s, %s, %s\n" rd rs1 rs2
  | RSle (rd, rs1, rs2) -> Printf.printf "sle %s, %s, %s\n" rd rs1 rs2
  | RSgt (rd, rs1, rs2) -> Printf.printf "sgt %s, %s, %s\n" rd rs1 rs2
  | RSge (rd, rs1, rs2) -> Printf.printf "sge %s, %s, %s\n" rd rs1 rs2
  | RSeqz (rd, rs) -> Printf.printf "seqz %s, %s\n" rd rs
  | RNeg (rd, rs) -> Printf.printf "neg %s, %s\n" rd rs
  | RMv (rd, rs) -> Printf.printf "mv %s, %s\n" rd rs
  | RLi (rd, imm) -> Printf.printf "li %s, %d\n" rd imm
  | RLabel l -> Printf.printf "%s:\n" l
  | RJ l -> Printf.printf "j %s\n" l
  | RBnez (rs, l) -> Printf.printf "bnez %s, %s\n" rs l
  | RPush (v, _) -> Printf.printf "addi sp, sp, -4\n"; Printf.printf "sw %s, 0(sp)\n" v
  | RPop (v, _) -> Printf.printf "lw %s, 0(sp)\n" v ; Printf.printf "addi sp, sp, 4\n"
  | RCall f -> Printf.printf "call %s\n" f
  | RRet (Some v) -> Printf.printf "mv a0, %s\nret\n" v
  | RRet None -> Printf.printf "ret\n"
  | RComment s -> Printf.printf "# %s\n" s

let print_riscv riscv_list =
  List.iter print_riscv_inst riscv_list

let () =
  match Array.length Sys.argv with
  | 1 ->  
      List.iter (fun filename ->
        Printf.printf "=== Parsing file: %s ===\n" filename;
        try
          let ast = parse_file filename in
          print_comp_unit ast;

          run_comp_unit ast;

          let tac_list = Lib.Transfer.gen_comp_unit ast in
          Printf.printf "==Original TAC==\n";
          print_tac tac_list;
          Printf.printf "==Original RISC-V Code==\n";
          let riscv_list = tac_to_riscv tac_list in
          print_riscv (riscv_list);
          Printf.printf "==Optimized TAC==\n";
          print_tac (Lib.Ssa_opt.optimize tac_list);
          Printf.printf "==Optimized RISC-V Code==\n";
          let riscv_list = tac_to_riscv (Lib.Ssa_opt.optimize tac_list) in
          print_riscv (riscv_list);

        with
        | Sys_error msg -> Printf.eprintf "Error: %s\n" msg
        | Parsing.Parse_error -> Printf.eprintf "Parse error\n"
        | Lib.Lexer.LexError msg -> Printf.eprintf "Lexical error: %s\n" msg
        | e -> Printf.eprintf "Error: %s\n" (Printexc.to_string e)
      ) test_files

  | 2 ->  
      let filename = Sys.argv.(1) in
      Printf.printf "=== Parsing file: %s ===\n" filename;
      (try
        let ast = parse_file filename in
        print_comp_unit ast;

        run_comp_unit ast;

        let tac_list = Lib.Transfer.gen_comp_unit ast in
        Printf.printf "==Original TAC==\n";
        print_tac tac_list;
        Printf.printf "==Original RISC-V Code==\n";
        let riscv_list = tac_to_riscv tac_list in
        print_riscv (riscv_list);
        Printf.printf "==Optimized TAC==\n";
        print_tac (Lib.Ssa_opt.optimize tac_list);
        Printf.printf "==Optimized RISC-V Code==\n";
        let riscv_list = tac_to_riscv (Lib.Ssa_opt.optimize tac_list) in
        print_riscv (riscv_list);

      with
      | Sys_error msg -> Printf.eprintf "Error: %s\n" msg
      | Parsing.Parse_error -> Printf.eprintf "Parse error\n"
      | Lib.Lexer.LexError msg -> Printf.eprintf "Lexical error: %s\n" msg
      | e -> Printf.eprintf "Error: %s\n" (Printexc.to_string e)
      )

  | _ ->
      Printf.eprintf "Usage:\n  %s         # run all tests\n  %s <file>  # run test on <file>\n" Sys.argv.(0) Sys.argv.(0);
      exit 1

