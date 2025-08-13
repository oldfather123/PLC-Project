type token =
  | NUMBER of (int)
  | IDENTIFIER of (string)
  | BREAK
  | CONTINUE
  | ELSE
  | IF
  | INT
  | RETURN
  | VOID
  | WHILE
  | PLUS
  | MINUS
  | STAR
  | DIV
  | MOD
  | EQ
  | NE
  | LT
  | LE
  | GT
  | GE
  | AND
  | OR
  | BANG
  | ASSIGN
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | SEMICOLON
  | COMMA
  | EOF

val comp_unit :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.comp_unit
