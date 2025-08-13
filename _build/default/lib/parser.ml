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

open Parsing;;
let _ = parse_error;;
# 2 "lib/parser.mly"
  open Ast
# 40 "lib/parser.ml"
let yytransl_const = [|
  259 (* BREAK *);
  260 (* CONTINUE *);
  261 (* ELSE *);
  262 (* IF *);
  263 (* INT *);
  264 (* RETURN *);
  265 (* VOID *);
  266 (* WHILE *);
  267 (* PLUS *);
  268 (* MINUS *);
  269 (* STAR *);
  270 (* DIV *);
  271 (* MOD *);
  272 (* EQ *);
  273 (* NE *);
  274 (* LT *);
  275 (* LE *);
  276 (* GT *);
  277 (* GE *);
  278 (* AND *);
  279 (* OR *);
  280 (* BANG *);
  281 (* ASSIGN *);
  282 (* LPAREN *);
  283 (* RPAREN *);
  284 (* LBRACE *);
  285 (* RBRACE *);
  286 (* SEMICOLON *);
  287 (* COMMA *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  257 (* NUMBER *);
  258 (* IDENTIFIER *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\003\000\004\000\004\000\005\000\005\000\
\007\000\007\000\008\000\006\000\009\000\009\000\010\000\010\000\
\010\000\010\000\010\000\010\000\010\000\010\000\010\000\010\000\
\010\000\010\000\011\000\012\000\012\000\013\000\013\000\014\000\
\014\000\014\000\014\000\014\000\014\000\014\000\015\000\015\000\
\015\000\016\000\016\000\016\000\016\000\017\000\017\000\017\000\
\017\000\018\000\018\000\018\000\018\000\019\000\019\000\020\000\
\020\000\000\000"

let yylen = "\002\000\
\002\000\001\000\002\000\006\000\001\000\001\000\000\000\001\000\
\001\000\003\000\002\000\003\000\000\000\002\000\001\000\001\000\
\004\000\005\000\005\000\007\000\005\000\002\000\002\000\002\000\
\003\000\002\000\001\000\001\000\003\000\001\000\003\000\001\000\
\003\000\003\000\003\000\003\000\003\000\003\000\001\000\003\000\
\003\000\001\000\003\000\003\000\003\000\001\000\002\000\002\000\
\002\000\001\000\001\000\003\000\004\000\000\000\001\000\001\000\
\003\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\005\000\006\000\058\000\000\000\002\000\000\000\
\001\000\003\000\000\000\000\000\000\000\000\000\000\000\009\000\
\011\000\000\000\000\000\013\000\004\000\010\000\000\000\051\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\012\000\016\000\015\000\014\000\000\000\
\000\000\000\000\000\000\000\000\000\000\042\000\046\000\000\000\
\000\000\022\000\023\000\000\000\000\000\000\000\024\000\000\000\
\000\000\047\000\048\000\049\000\000\000\026\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\056\000\000\000\000\000\000\000\
\000\000\025\000\000\000\052\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\043\000\044\000\
\045\000\017\000\053\000\000\000\000\000\000\000\000\000\057\000\
\000\000\018\000\021\000\000\000\020\000"

let yydgoto = "\002\000\
\005\000\006\000\007\000\008\000\014\000\038\000\015\000\016\000\
\023\000\039\000\040\000\041\000\042\000\043\000\044\000\045\000\
\046\000\047\000\078\000\079\000"

let yysindex = "\011\000\
\069\255\000\000\000\000\000\000\000\000\001\000\000\000\000\255\
\000\000\000\000\247\254\018\255\019\255\006\255\015\255\000\000\
\000\000\022\255\018\255\000\000\000\000\000\000\028\255\000\000\
\017\255\029\255\031\255\040\255\082\255\111\255\060\255\002\255\
\002\255\002\255\002\255\000\000\000\000\000\000\000\000\058\255\
\073\255\089\255\211\255\094\255\252\254\000\000\000\000\002\255\
\002\255\000\000\000\000\002\255\093\255\088\255\000\000\086\255\
\002\255\000\000\000\000\000\000\097\255\000\000\002\255\002\255\
\002\255\002\255\002\255\002\255\002\255\002\255\002\255\002\255\
\002\255\002\255\002\255\090\255\000\000\106\255\103\255\128\255\
\002\255\000\000\129\255\000\000\089\255\211\255\094\255\094\255\
\094\255\094\255\094\255\094\255\252\254\252\254\000\000\000\000\
\000\000\000\000\000\000\002\255\091\255\108\255\091\255\000\000\
\152\255\000\000\000\000\091\255\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\136\255\000\000\000\000\145\255\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\203\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\050\255\014\255\249\254\109\255\148\255\000\000\000\000\000\000\
\146\255\000\000\000\000\000\000\000\000\131\255\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\147\255\000\000\
\000\000\000\000\000\000\000\000\077\255\052\255\218\255\238\255\
\254\255\014\000\030\000\046\000\165\255\182\255\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\061\255\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\000\000\174\000\000\000\000\000\171\000\000\000\172\000\
\000\000\208\255\226\255\000\000\127\000\133\000\013\001\038\000\
\230\255\000\000\000\000\000\000"

let yytablesize = 339
let yytable = "\056\000\
\009\000\011\000\024\000\054\000\061\000\058\000\059\000\060\000\
\073\000\074\000\075\000\001\000\032\000\033\000\030\000\030\000\
\012\000\076\000\077\000\030\000\017\000\080\000\030\000\030\000\
\013\000\034\000\083\000\035\000\024\000\025\000\026\000\027\000\
\018\000\028\000\029\000\030\000\028\000\031\000\032\000\033\000\
\028\000\048\000\049\000\028\000\028\000\019\000\095\000\096\000\
\097\000\020\000\102\000\034\000\105\000\035\000\107\000\020\000\
\036\000\037\000\050\000\109\000\051\000\019\000\019\000\019\000\
\019\000\052\000\019\000\019\000\019\000\104\000\019\000\019\000\
\019\000\031\000\031\000\003\000\027\000\004\000\031\000\027\000\
\027\000\031\000\031\000\053\000\019\000\057\000\019\000\062\000\
\019\000\019\000\019\000\024\000\025\000\026\000\027\000\063\000\
\028\000\029\000\030\000\029\000\031\000\032\000\033\000\029\000\
\071\000\072\000\029\000\029\000\093\000\094\000\064\000\024\000\
\054\000\049\000\034\000\082\000\035\000\081\000\020\000\098\000\
\037\000\032\000\033\000\084\000\032\000\032\000\032\000\032\000\
\032\000\032\000\032\000\032\000\099\000\100\000\034\000\032\000\
\035\000\106\000\032\000\032\000\055\000\050\000\050\000\050\000\
\050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
\050\000\050\000\101\000\103\000\108\000\050\000\039\000\039\000\
\050\000\050\000\007\000\039\000\039\000\039\000\039\000\039\000\
\039\000\039\000\039\000\008\000\054\000\055\000\039\000\040\000\
\040\000\039\000\039\000\010\000\040\000\040\000\040\000\040\000\
\040\000\040\000\040\000\040\000\021\000\085\000\022\000\040\000\
\041\000\041\000\040\000\040\000\086\000\041\000\041\000\041\000\
\041\000\041\000\041\000\041\000\041\000\000\000\000\000\000\000\
\041\000\000\000\000\000\041\000\041\000\050\000\050\000\050\000\
\050\000\050\000\050\000\050\000\050\000\050\000\050\000\050\000\
\050\000\050\000\065\000\066\000\067\000\068\000\069\000\070\000\
\050\000\037\000\037\000\037\000\037\000\037\000\037\000\037\000\
\037\000\000\000\000\000\000\000\037\000\000\000\000\000\037\000\
\037\000\000\000\000\000\000\000\000\000\038\000\038\000\038\000\
\038\000\038\000\038\000\038\000\038\000\000\000\000\000\003\000\
\038\000\004\000\000\000\038\000\038\000\033\000\033\000\033\000\
\033\000\033\000\033\000\033\000\033\000\000\000\000\000\000\000\
\033\000\000\000\000\000\033\000\033\000\035\000\035\000\035\000\
\035\000\035\000\035\000\035\000\035\000\000\000\000\000\000\000\
\035\000\000\000\000\000\035\000\035\000\034\000\034\000\034\000\
\034\000\034\000\034\000\034\000\034\000\000\000\000\000\000\000\
\034\000\000\000\000\000\034\000\034\000\036\000\036\000\036\000\
\036\000\036\000\036\000\036\000\036\000\000\000\000\000\000\000\
\036\000\000\000\000\000\036\000\036\000\087\000\088\000\089\000\
\090\000\091\000\092\000"

let yycheck = "\030\000\
\000\000\002\001\001\001\002\001\035\000\032\000\033\000\034\000\
\013\001\014\001\015\001\001\000\011\001\012\001\022\001\023\001\
\026\001\048\000\049\000\027\001\002\001\052\000\030\001\031\001\
\007\001\024\001\057\000\026\001\001\001\002\001\003\001\004\001\
\027\001\006\001\007\001\008\001\023\001\010\001\011\001\012\001\
\027\001\025\001\026\001\030\001\031\001\031\001\073\000\074\000\
\075\000\028\001\081\000\024\001\101\000\026\001\103\000\028\001\
\029\001\030\001\030\001\108\000\030\001\001\001\002\001\003\001\
\004\001\026\001\006\001\007\001\008\001\100\000\010\001\011\001\
\012\001\022\001\023\001\007\001\027\001\009\001\027\001\030\001\
\031\001\030\001\031\001\002\001\024\001\026\001\026\001\030\001\
\028\001\029\001\030\001\001\001\002\001\003\001\004\001\023\001\
\006\001\007\001\008\001\023\001\010\001\011\001\012\001\027\001\
\011\001\012\001\030\001\031\001\071\000\072\000\022\001\001\001\
\002\001\026\001\024\001\030\001\026\001\025\001\028\001\030\001\
\030\001\011\001\012\001\027\001\016\001\017\001\018\001\019\001\
\020\001\021\001\022\001\023\001\027\001\031\001\024\001\027\001\
\026\001\030\001\030\001\031\001\030\001\011\001\012\001\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\022\001\023\001\027\001\027\001\005\001\027\001\011\001\012\001\
\030\001\031\001\027\001\016\001\017\001\018\001\019\001\020\001\
\021\001\022\001\023\001\027\001\027\001\027\001\027\001\011\001\
\012\001\030\001\031\001\006\000\016\001\017\001\018\001\019\001\
\020\001\021\001\022\001\023\001\018\000\063\000\019\000\027\001\
\011\001\012\001\030\001\031\001\064\000\016\001\017\001\018\001\
\019\001\020\001\021\001\022\001\023\001\255\255\255\255\255\255\
\027\001\255\255\255\255\030\001\031\001\011\001\012\001\013\001\
\014\001\015\001\016\001\017\001\018\001\019\001\020\001\021\001\
\022\001\023\001\016\001\017\001\018\001\019\001\020\001\021\001\
\030\001\016\001\017\001\018\001\019\001\020\001\021\001\022\001\
\023\001\255\255\255\255\255\255\027\001\255\255\255\255\030\001\
\031\001\255\255\255\255\255\255\255\255\016\001\017\001\018\001\
\019\001\020\001\021\001\022\001\023\001\255\255\255\255\007\001\
\027\001\009\001\255\255\030\001\031\001\016\001\017\001\018\001\
\019\001\020\001\021\001\022\001\023\001\255\255\255\255\255\255\
\027\001\255\255\255\255\030\001\031\001\016\001\017\001\018\001\
\019\001\020\001\021\001\022\001\023\001\255\255\255\255\255\255\
\027\001\255\255\255\255\030\001\031\001\016\001\017\001\018\001\
\019\001\020\001\021\001\022\001\023\001\255\255\255\255\255\255\
\027\001\255\255\255\255\030\001\031\001\016\001\017\001\018\001\
\019\001\020\001\021\001\022\001\023\001\255\255\255\255\255\255\
\027\001\255\255\255\255\030\001\031\001\065\000\066\000\067\000\
\068\000\069\000\070\000"

let yynames_const = "\
  BREAK\000\
  CONTINUE\000\
  ELSE\000\
  IF\000\
  INT\000\
  RETURN\000\
  VOID\000\
  WHILE\000\
  PLUS\000\
  MINUS\000\
  STAR\000\
  DIV\000\
  MOD\000\
  EQ\000\
  NE\000\
  LT\000\
  LE\000\
  GT\000\
  GE\000\
  AND\000\
  OR\000\
  BANG\000\
  ASSIGN\000\
  LPAREN\000\
  RPAREN\000\
  LBRACE\000\
  RBRACE\000\
  SEMICOLON\000\
  COMMA\000\
  EOF\000\
  "

let yynames_block = "\
  NUMBER\000\
  IDENTIFIER\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'func_def_list) in
    Obj.repr(
# 41 "lib/parser.mly"
                      ( _1 )
# 293 "lib/parser.ml"
               : Ast.comp_unit))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'func_def) in
    Obj.repr(
# 44 "lib/parser.mly"
             ( [_1] )
# 300 "lib/parser.ml"
               : 'func_def_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'func_def_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'func_def) in
    Obj.repr(
# 45 "lib/parser.mly"
                           ( _1 @ [_2] )
# 308 "lib/parser.ml"
               : 'func_def_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 5 : 'type_spec) in
    let _2 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 2 : 'param_list_opt) in
    let _6 = (Parsing.peek_val __caml_parser_env 0 : 'block) in
    Obj.repr(
# 50 "lib/parser.mly"
    ( FuncDef (_1, _2, _4, _6) )
# 318 "lib/parser.ml"
               : 'func_def))
; (fun __caml_parser_env ->
    Obj.repr(
# 53 "lib/parser.mly"
        ( Int )
# 324 "lib/parser.ml"
               : 'type_spec))
; (fun __caml_parser_env ->
    Obj.repr(
# 54 "lib/parser.mly"
         ( Void )
# 330 "lib/parser.ml"
               : 'type_spec))
; (fun __caml_parser_env ->
    Obj.repr(
# 57 "lib/parser.mly"
                    ( [] )
# 336 "lib/parser.ml"
               : 'param_list_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'param_list) in
    Obj.repr(
# 58 "lib/parser.mly"
               ( _1 )
# 343 "lib/parser.ml"
               : 'param_list_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'param) in
    Obj.repr(
# 61 "lib/parser.mly"
          ( [_1] )
# 350 "lib/parser.ml"
               : 'param_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'param_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'param) in
    Obj.repr(
# 62 "lib/parser.mly"
                           ( _1 @ [_3] )
# 358 "lib/parser.ml"
               : 'param_list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 66 "lib/parser.mly"
                   ( Param _2 )
# 365 "lib/parser.ml"
               : 'param))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'stmt_list) in
    Obj.repr(
# 70 "lib/parser.mly"
                            ( Block _2 )
# 372 "lib/parser.ml"
               : 'block))
; (fun __caml_parser_env ->
    Obj.repr(
# 73 "lib/parser.mly"
                    ( [] )
# 378 "lib/parser.ml"
               : 'stmt_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'stmt_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 74 "lib/parser.mly"
                   ( _1 @ [_2] )
# 386 "lib/parser.ml"
               : 'stmt_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'block) in
    Obj.repr(
# 78 "lib/parser.mly"
          ( _1 )
# 393 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 79 "lib/parser.mly"
              ( EmptyStmt )
# 399 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 80 "lib/parser.mly"
                                     ( Assignment (_1, _3) )
# 407 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 81 "lib/parser.mly"
                                         ( VarDecl (_2, _4) )
# 415 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 82 "lib/parser.mly"
                                        ( IfStmt (_3, _5, None) )
# 423 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : 'stmt) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 83 "lib/parser.mly"
                                         ( IfStmt (_3, _5, Some _7) )
# 432 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 84 "lib/parser.mly"
                                  ( WhileStmt (_3, _5) )
# 440 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 85 "lib/parser.mly"
                    ( BreakStmt )
# 446 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 86 "lib/parser.mly"
                       ( ContinueStmt )
# 452 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 87 "lib/parser.mly"
                     ( ReturnStmt None )
# 458 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 88 "lib/parser.mly"
                          ( ReturnStmt (Some _2) )
# 465 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 89 "lib/parser.mly"
                   ( ExprStmt _1 )
# 472 "lib/parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'lor_expr) in
    Obj.repr(
# 93 "lib/parser.mly"
             ( _1 )
# 479 "lib/parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'land_expr) in
    Obj.repr(
# 96 "lib/parser.mly"
              ( _1 )
# 486 "lib/parser.ml"
               : 'lor_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'lor_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'land_expr) in
    Obj.repr(
# 97 "lib/parser.mly"
                          ( BinaryOp (_1, LogicalOr, _3) )
# 494 "lib/parser.ml"
               : 'lor_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'rel_expr) in
    Obj.repr(
# 100 "lib/parser.mly"
             ( _1 )
# 501 "lib/parser.ml"
               : 'land_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'land_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'rel_expr) in
    Obj.repr(
# 101 "lib/parser.mly"
                           ( BinaryOp (_1, LogicalAnd, _3) )
# 509 "lib/parser.ml"
               : 'land_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 104 "lib/parser.mly"
             ( _1 )
# 516 "lib/parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 105 "lib/parser.mly"
                         ( BinaryOp (_1, Less, _3) )
# 524 "lib/parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 106 "lib/parser.mly"
                         ( BinaryOp (_1, Greater, _3) )
# 532 "lib/parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 107 "lib/parser.mly"
                         ( BinaryOp (_1, LessEqual, _3) )
# 540 "lib/parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 108 "lib/parser.mly"
                         ( BinaryOp (_1, GreaterEqual, _3) )
# 548 "lib/parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 109 "lib/parser.mly"
                         ( BinaryOp (_1, Equal, _3) )
# 556 "lib/parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'rel_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'add_expr) in
    Obj.repr(
# 110 "lib/parser.mly"
                         ( BinaryOp (_1, NotEqual, _3) )
# 564 "lib/parser.ml"
               : 'rel_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'mul_expr) in
    Obj.repr(
# 113 "lib/parser.mly"
             ( _1 )
# 571 "lib/parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'add_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'mul_expr) in
    Obj.repr(
# 114 "lib/parser.mly"
                           ( BinaryOp (_1, Add, _3) )
# 579 "lib/parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'add_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'mul_expr) in
    Obj.repr(
# 115 "lib/parser.mly"
                            ( BinaryOp (_1, Sub, _3) )
# 587 "lib/parser.ml"
               : 'add_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 118 "lib/parser.mly"
               ( _1 )
# 594 "lib/parser.ml"
               : 'mul_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mul_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 119 "lib/parser.mly"
                             ( BinaryOp (_1, Mul, _3) )
# 602 "lib/parser.ml"
               : 'mul_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mul_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 120 "lib/parser.mly"
                            ( BinaryOp (_1, Div, _3) )
# 610 "lib/parser.ml"
               : 'mul_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'mul_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 121 "lib/parser.mly"
                            ( BinaryOp (_1, Mod, _3) )
# 618 "lib/parser.ml"
               : 'mul_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'primary_expr) in
    Obj.repr(
# 124 "lib/parser.mly"
                 ( _1 )
# 625 "lib/parser.ml"
               : 'unary_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 125 "lib/parser.mly"
                                     ( UnaryOp (UnaryPlus, _2) )
# 632 "lib/parser.ml"
               : 'unary_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 126 "lib/parser.mly"
                                       ( UnaryOp (UnaryMinus, _2) )
# 639 "lib/parser.ml"
               : 'unary_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'unary_expr) in
    Obj.repr(
# 127 "lib/parser.mly"
                    ( UnaryOp (LogicalNot, _2) )
# 646 "lib/parser.ml"
               : 'unary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 130 "lib/parser.mly"
               ( Identifier _1 )
# 653 "lib/parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 131 "lib/parser.mly"
           ( Number _1 )
# 660 "lib/parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 132 "lib/parser.mly"
                       ( _2 )
# 667 "lib/parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr_list_opt) in
    Obj.repr(
# 133 "lib/parser.mly"
                                           ( FunctionCall (_1, _3) )
# 675 "lib/parser.ml"
               : 'primary_expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 136 "lib/parser.mly"
                    ( [] )
# 681 "lib/parser.ml"
               : 'expr_list_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr_list) in
    Obj.repr(
# 137 "lib/parser.mly"
              ( _1 )
# 688 "lib/parser.ml"
               : 'expr_list_opt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 140 "lib/parser.mly"
         ( [_1] )
# 695 "lib/parser.ml"
               : 'expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 141 "lib/parser.mly"
                         ( _1 @ [_3] )
# 703 "lib/parser.ml"
               : 'expr_list))
(* Entry comp_unit *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let comp_unit (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.comp_unit)
;;
