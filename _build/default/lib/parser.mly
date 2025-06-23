%{
  open Ast
  let rec apply e = function
    | [] -> failwith "Apply at least two expressions"
    | [ e1 ] -> App (e, e1)
    | h :: ((_ :: _) as t) -> apply (App (e, h)) t
%}
%token <int> INT
%token <string> VAR
%token ADD SUB MUL DIV LEQ EOF
%token LPAREN RPAREN
%token IF THEN ELSE
%token LET EQUALS IN
%token TRUE FALSE
%token FUNC ARROW

%nonassoc IN
%nonassoc ELSE
%left LEQ
%left ADD SUB
%left MUL DIV

%start main
%type <Ast.expr> main 
%%
main:
  init EOF {$1}
;
init:
  | expr {$1}
  | expr expr+ {apply $1 $2}
  | FUNC VAR ARROW init {Func ($2, $4)}
;
expr:
  | INT {Int $1}
  | VAR {Var $1}
  | TRUE {Bool true}
  | FALSE {Bool false}
  | expr ADD expr {Binop (Add, $1, $3)}
  | expr SUB expr {Binop (Sub, $1, $3)}
  | expr MUL expr {Binop (Mul, $1, $3)}
  | expr DIV expr {Binop (Div, $1, $3)}
  | expr LEQ expr {Binop (Leq, $1, $3)}
  | LPAREN init RPAREN {$2}
  | IF expr THEN expr ELSE expr {If ($2, $4, $6)}
  | LET VAR EQUALS expr IN expr {Let ($2, $4, $6)}
;