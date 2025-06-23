{
  open Parser
  exception LexError of string
}

let whitespace = [' ' '\t']
let newline = '\r' | '\n' | "\r\n"
let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z']
let identifier = (letter | '_') (letter | digit | '_')*
let integer_constant = digit+

rule token = parse
  | whitespace+ { token lexbuf }
  | newline { Lexing.new_line lexbuf; token lexbuf }
  | "/*" { comment lexbuf }
  | "//" { line_comment lexbuf }
  
  (* Keywords *)
  | "break" { BREAK }
  | "continue" { CONTINUE }
  | "else" { ELSE }
  | "if" { IF }
  | "int" { INT }
  | "return" { RETURN }
  | "void" { VOID }
  | "while" { WHILE }

  (* Operators *)
  | "+" { PLUS }
  | "-" { MINUS }
  | "*" { STAR }
  | "/" { DIV }
  | "==" { EQ }
  | "!=" { NE }
  | "<" { LT }
  | "<=" { LE }
  | ">" { GT }
  | ">=" { GE }
  | "&&" { AND }
  | "||" { OR }
  | "=" { ASSIGN }

  (* Punctuation *)
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "{" { LBRACE }
  | "}" { RBRACE }
  | ";" { SEMICOLON }
  | "," { COMMA }

  (* Constants and identifiers *)
  | integer_constant as i { INTEGER_CONSTANT (int_of_string i) }
  | identifier as id { IDENTIFIER id }

  | eof { EOF }
  | _ as c { raise (LexError ("Unexpected character: " ^ String.make 1 c)) }

and comment = parse
  | "*/" { token lexbuf }
  | newline { Lexing.new_line lexbuf; comment lexbuf }
  | _ { comment lexbuf }
  | eof { raise (LexError "Unterminated comment") }

and line_comment = parse
  | newline { Lexing.new_line lexbuf; token lexbuf }
  | _ { line_comment lexbuf }
  | eof { EOF }