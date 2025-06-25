(* 测试运行器 *)
let () =
  if Array.length Sys.argv < 2 then (
    Printf.eprintf "Usage: %s <test_type> [specific_file]\n" Sys.argv.(0);
    Printf.eprintf "  test_type: ast      - run AST tests\n";
    Printf.eprintf "             interp   - run interpreter tests\n";
    Printf.eprintf "             ir       - run IR generation tests\n";
    Printf.eprintf "             features - run specific IR feature tests\n";
    Printf.eprintf "             all      - run all tests\n";
    Printf.eprintf "  specific_file: optional path to specific test file\n";
    exit 1
  );
  
  let test_type = Sys.argv.(1) in
  
  match test_type with
  | "ast" -> 
    if Array.length Sys.argv >= 3 then
      let _ = Ast_test.test_single_file Sys.argv.(2) in ()
    else
      Ast_test.run_tests ()
  | "interp" -> 
    if Array.length Sys.argv >= 3 then
      let _ = Interpreter_test.test_single_file Sys.argv.(2) in ()
    else
      Interpreter_test.run_tests ()
  | "ir" ->
    if Array.length Sys.argv >= 3 then
      let _ = Ir_test.test_single_file Sys.argv.(2) in ()
    else
      Ir_test.run_tests ()
  | "features" ->
    Ir_test.test_ir_features ()
  | "all" ->
    Printf.printf "=== Running All Tests ===\n";
    Ast_test.run_tests ();
    Printf.printf "\n";
    Interpreter_test.run_tests ();
    Printf.printf "\n";
    Ir_test.run_tests ()
  | _ ->
    Printf.eprintf "Invalid test type: %s\n" test_type;
    Printf.eprintf "Valid types: ast, interp, ir, features, all\n";
    exit 1