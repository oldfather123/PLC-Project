{
  open Parser
}
rule read = parse
  | [' ' '\t' '\n']+ {read lexbuf}
  | '+' {ADD}
  | '-' {SUB}
  | '*' {MUL}
  | '/' {DIV}
  | "<=" {LEQ}
  | '(' {LPAREN}
  | ')' {RPAREN}
  | "if" {IF}
  | "then" {THEN}
  | "else" {ELSE}
  | "let" {LET}
  | '=' {EQUALS}
  | "in" {IN}
  | "true" {TRUE}
  | "false" {FALSE}
  | "fun" {FUNC}
  | "->" {ARROW}
  | ['0' - '9']+ as num {INT (int_of_string num)}
  | ['A' - 'Z' 'a' - 'z']+ as var {VAR var}
  | eof {EOF}
  | _ {failwith "Invalid grammar"}