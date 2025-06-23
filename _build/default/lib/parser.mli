type token =
  | INTEGER_CONSTANT of (
# 6 "lib/parser.mly"
        int
# 6 "lib/parser.mli"
)
  | CHARACTER_CONSTANT of (
# 7 "lib/parser.mly"
        char
# 11 "lib/parser.mli"
)
  | STRING_CONSTANT of (
# 8 "lib/parser.mly"
        string
# 16 "lib/parser.mli"
)
  | IDENTIFIER of (
# 9 "lib/parser.mly"
        string
# 21 "lib/parser.mli"
)
  | AUTO
  | BREAK
  | CASE
  | CHAR
  | CONST
  | CONTINUE
  | DEFAULT
  | DO
  | DOUBLE
  | ELSE
  | ENUM
  | EXTERN
  | FLOAT
  | FOR
  | GOTO
  | IF
  | INT
  | LONG
  | REGISTER
  | RETURN
  | SHORT
  | SIGNED
  | SIZEOF
  | STATIC
  | STRUCT
  | SWITCH
  | TYPEDEF
  | UNION
  | UNSIGNED
  | VOID
  | VOLATILE
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
  | AMPERSAND
  | PIPE
  | HAT
  | LSHIFT
  | RSHIFT
  | BANG
  | TILDE
  | INCR
  | DECR
  | ASSIGN
  | PLUS_ASSIGN
  | MINUS_ASSIGN
  | STAR_ASSIGN
  | DIV_ASSIGN
  | MOD_ASSIGN
  | AND_ASSIGN
  | OR_ASSIGN
  | XOR_ASSIGN
  | LSHIFT_ASSIGN
  | RSHIFT_ASSIGN
  | LPAREN
  | RPAREN
  | LBRACKET
  | RBRACKET
  | LBRACE
  | RBRACE
  | SEMICOLON
  | COMMA
  | DOT
  | ARROW
  | QUESTION
  | COLON
  | EOF

val translation_unit :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.translation_unit
