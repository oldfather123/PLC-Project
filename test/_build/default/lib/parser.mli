type token =
  | NUMBER of (
# 6 "lib/parser.mly"
        int
# 6 "lib/parser.mli"
)
  | IDENTIFIER of (
# 7 "lib/parser.mly"
        string
# 11 "lib/parser.mli"
)
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
