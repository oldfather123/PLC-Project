(* filepath: /home/lee77/PLC-Summer/program/Edit2/test/interpreter_test.ml *)
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

let test_single_file filename =
  Printf.printf "\n=== Testing Interpreter for: %s ===\n" filename;
  try
    let ast = parse_file filename in
    Printf.printf "--- Executing Program ---\n";
    let exit_code = run_program ast in
    Printf.printf "--- Program Exit Code: %d ---\n" exit_code;
    Printf.printf "✓ Interpreter test completed for %s\n" filename;
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
    Printf.eprintf "✗ Runtime error for %s: %s\n" filename (Printexc.to_string e); 
    false

let test_directory dir_path =
  Printf.printf "\n=== Running Interpreter Tests from %s ===\n" dir_path;
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
  
  Printf.printf "\n=== Interpreter Test Summary ===\n";
  Printf.printf "Total: %d, Completed: %d, Failed: %d\n" total !passed (total - !passed);
  
  if !passed = total then
    Printf.printf "✓ All interpreter tests completed!\n"
  else
    Printf.printf "✗ %d interpreter tests failed!\n" (total - !passed)

let run_tests () =
  test_directory "test/test_Interp"