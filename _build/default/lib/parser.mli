
(* The type of tokens. *)

type token = 
  | VAR of (string)
  | TRUE
  | THEN
  | SUB
  | RPAREN
  | MUL
  | LPAREN
  | LET
  | LEQ
  | INT of (int)
  | IN
  | IF
  | FUNC
  | FALSE
  | EQUALS
  | EOF
  | ELSE
  | DIV
  | ARROW
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.expr)
