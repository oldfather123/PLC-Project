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
let character_constant = '\'' ([^ '\'' '\\'] | '\\' ['n' 't' 'r' '\\' '\'' '"']) '\''
let string_constant = '"' ([^ '"' '\\'] | '\\' ['n' 't' 'r' '\\' '\'' '"'])* '"'

rule token = parse
  | whitespace+ { token lexbuf }
  | newline { Lexing.new_line lexbuf; token lexbuf }
  | "/*" { comment lexbuf }
  | "//" { line_comment lexbuf }
  
  (* Keywords *)
  | "auto" { AUTO }
  | "break" { BREAK }
  | "case" { CASE }
  | "char" { CHAR }
  | "const" { CONST }
  | "continue" { CONTINUE }
  | "default" { DEFAULT }
  | "do" { DO }
  | "double" { DOUBLE }
  | "else" { ELSE }
  | "enum" { ENUM }
  | "extern" { EXTERN }
  | "float" { FLOAT }
  | "for" { FOR }
  | "goto" { GOTO }
  | "if" { IF }
  | "int" { INT }
  | "long" { LONG }
  | "register" { REGISTER }
  | "return" { RETURN }
  | "short" { SHORT }
  | "signed" { SIGNED }
  | "sizeof" { SIZEOF }
  | "static" { STATIC }
  | "struct" { STRUCT }
  | "switch" { SWITCH }
  | "typedef" { TYPEDEF }
  | "union" { UNION }
  | "unsigned" { UNSIGNED }
  | "void" { VOID }
  | "volatile" { VOLATILE }
  | "while" { WHILE }

  (* Operators *)
  | "+" { PLUS }
  | "-" { MINUS }
  | "*" { STAR }
  | "/" { DIV }
  | "%" { MOD }
  | "==" { EQ }
  | "!=" { NE }
  | "<" { LT }
  | "<=" { LE }
  | ">" { GT }
  | ">=" { GE }
  | "&&" { AND }
  | "||" { OR }
  | "&" { AMPERSAND }
  | "|" { PIPE }
  | "^" { HAT }
  | "<<" { LSHIFT }
  | ">>" { RSHIFT }
  | "!" { BANG }
  | "~" { TILDE }
  | "++" { INCR }
  | "--" { DECR }
  | "=" { ASSIGN }
  | "+=" { PLUS_ASSIGN }
  | "-=" { MINUS_ASSIGN }
  | "*=" { STAR_ASSIGN }
  | "/=" { DIV_ASSIGN }
  | "%=" { MOD_ASSIGN }
  | "&=" { AND_ASSIGN }
  | "|=" { OR_ASSIGN }
  | "^=" { XOR_ASSIGN }
  | "<<=" { LSHIFT_ASSIGN }
  | ">>=" { RSHIFT_ASSIGN }

  (* Punctuation *)
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "[" { LBRACKET }
  | "]" { RBRACKET }
  | "{" { LBRACE }
  | "}" { RBRACE }
  | ";" { SEMICOLON }
  | "," { COMMA }
  | "." { DOT }
  | "->" { ARROW }
  | "?" { QUESTION }
  | ":" { COLON }

  (* Constants and identifiers *)
  | integer_constant as i { INTEGER_CONSTANT (int_of_string i) }
  | character_constant as c { 
      let s = String.sub c 1 (String.length c - 2) in
      let ch = if String.length s = 1 then s.[0]
               else match s with
                 | "\\n" -> '\n'
                 | "\\t" -> '\t'
                 | "\\r" -> '\r'
                 | "\\\\" -> '\\'
                 | "\\'" -> '\''
                 | "\\\"" -> '"'
                 | _ -> raise (LexError ("Invalid character constant: " ^ c))
      in CHARACTER_CONSTANT ch
    }
  | string_constant as s { 
      let content = String.sub s 1 (String.length s - 2) in
      STRING_CONSTANT content
    }
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