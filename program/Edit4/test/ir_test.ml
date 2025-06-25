(* IR 中间代码生成测试 *)
open Lib.Lexer
open Lib.Parser
open Lib.Ir_generator

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
  Printf.printf "\n=== Testing IR Generation for: %s ===\n" filename;
  try
    let ast = parse_file filename in
    Printf.printf "--- Generated Three-Address Code ---\n";
    let _ = generate_and_print_ir ast in
    Printf.printf "--- End of Three-Address Code ---\n";
    Printf.printf "✓ IR generation test completed for %s\n" filename;
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
    Printf.eprintf "✗ IR generation error for %s: %s\n" filename (Printexc.to_string e); 
    false

let test_directory dir_path =
  Printf.printf "\n=== Running IR Generation Tests from %s ===\n" dir_path;
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
  
  Printf.printf "\n=== IR Generation Test Summary ===\n";
  Printf.printf "Total: %d, Completed: %d, Failed: %d\n" total !passed (total - !passed);
  
  if !passed = total then
    Printf.printf "✓ All IR generation tests completed!\n"
  else
    Printf.printf "✗ %d IR generation tests failed!\n" (total - !passed)

let run_tests () =
  test_directory "test/test_Ast"

(* 针对特定 IR 特性的测试 *)
let test_ir_features () =
  Printf.printf "\n=== Testing Specific IR Features ===\n";
  
  (* 测试基本算术运算 *)
  Printf.printf "\n--- Testing Basic Arithmetic ---\n";
  let _ = test_single_file "test/test_Ast/test2.c" in
  
  (* 测试控制流 *)
  Printf.printf "\n--- Testing Control Flow ---\n";
  let _ = test_single_file "test/test_Ast/test3.c" in
  
  (* 测试函数调用 *)
  Printf.printf "\n--- Testing Function Calls ---\n";
  let _ = test_single_file "test/test_Ast/test4.c" in
  
  (* 测试逻辑运算（短路求值） *)
  Printf.printf "\n--- Testing Logical Operations ---\n";
  let _ = test_single_file "test/test_Ast/test7.c" in
  
  (* 测试复杂程序 *)
  Printf.printf "\n--- Testing Complex Program ---\n";
  let _ = test_single_file "test/test_Ast/test10.c" in
  
  Printf.printf "\n=== IR Feature Tests Completed ===\n"