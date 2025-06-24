(* filepath: /home/lee77/PLC-Summer/program/Edit2/bin/main.ml *)
open Lib.Lexer
open Lib.Parser
open Lib.Interpreter

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
  if Array.length Sys.argv < 2 then (
    Printf.eprintf "Usage: %s <command> [args]\n" Sys.argv.(0);
    Printf.eprintf "Commands:\n";
    Printf.eprintf "  test ast           - run AST tests\n";
    Printf.eprintf "  test interp        - run interpreter tests\n";
    Printf.eprintf "  test all           - run all tests\n";
    Printf.eprintf "  run <file>         - parse and execute a single file\n";
    Printf.eprintf "  parse <file>       - parse and show AST for a single file\n";
    exit 1
  );
  
  let command = Sys.argv.(1) in
  
  match command with
  | "test" when Array.length Sys.argv >= 3 ->
    let test_type = Sys.argv.(2) in
    let test_runner_cmd = 
      if Array.length Sys.argv >= 4 then
        Printf.sprintf "./_build/default/test/test_runner.exe %s %s" test_type Sys.argv.(3)
      else
        Printf.sprintf "./_build/default/test/test_runner.exe %s" test_type
    in
    let exit_code = Sys.command test_runner_cmd in
    exit exit_code
    
  | "run" when Array.length Sys.argv >= 3 ->
    let filename = Sys.argv.(2) in
    (try
      let ast = parse_file filename in
      Printf.printf "=== Executing ToyC Program: %s ===\n\n" filename;
      let exit_code = run_program ast in
      Printf.printf "\n=== Program Exit Code: %d ===\n" exit_code;
      exit exit_code
    with
    | Sys_error msg -> Printf.eprintf "Error: %s\n" msg; exit 1
    | Parsing.Parse_error -> Printf.eprintf "Parse error\n"; exit 1
    | Lib.Lexer.LexError msg -> Printf.eprintf "Lexical error: %s\n" msg; exit 1
    | e -> Printf.eprintf "Error: %s\n" (Printexc.to_string e); exit 1)
    
  | "parse" when Array.length Sys.argv >= 3 ->
    let filename = Sys.argv.(2) in
    let ast_test_cmd = Printf.sprintf "./_build/default/test/test_runner.exe ast %s" filename in
    let exit_code = Sys.command ast_test_cmd in
    exit exit_code
    
  | _ ->
    Printf.eprintf "Invalid command or missing arguments\n";
    Printf.eprintf "Use '%s' without arguments to see usage\n" Sys.argv.(0);
    exit 1