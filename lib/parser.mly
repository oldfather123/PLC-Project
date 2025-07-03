%{
  open Ast
%}

// (* Tokens *)
%token <int> NUMBER
%token <string> IDENTIFIER

// (* Keywords *)
%token BREAK CONTINUE ELSE IF INT RETURN VOID WHILE

// (* Operators *)
%token PLUS MINUS STAR DIV MOD
%token EQ NE LT LE GT GE
%token AND OR BANG
%token ASSIGN

// (* Punctuation *)
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA

%token EOF

// (* Precedence and associativity *)
%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left STAR DIV MOD
%right BANG UNARY_PLUS UNARY_MINUS
%nonassoc IF
%nonassoc ELSE

%start comp_unit
%type <Ast.comp_unit> comp_unit

%%

// (* CompUnit → FuncDef+ *)
comp_unit:
  | func_def_list EOF { $1 }

func_def_list:
  | func_def { [$1] }
  | func_def_list func_def { $1 @ [$2] }

// (* FuncDef → ("int" | "void") ID "(" (Param ("," Param)*)? ")" Block *)
func_def:
  | type_spec IDENTIFIER LPAREN param_list_opt RPAREN block
    { FuncDef ($1, $2, $4, $6) }

type_spec:
  | INT { Int }
  | VOID { Void }

param_list_opt:
  | /*(* empty *)*/ { [] }
  | param_list { $1 }

param_list:
  | param { [$1] }
  | param_list COMMA param { $1 @ [$3] }

// (* Param → "int" ID *)
param:
  | INT IDENTIFIER { Param $2 }

// (* Block → "{" Stmt* "}" *)
block:
  | LBRACE stmt_list RBRACE { Block $2 }

stmt_list:
  | /*(* empty *)*/ { [] }
  | stmt_list stmt { $1 @ [$2] }

// (* Stmt规则 - 调整顺序 *)
stmt:
  | block { $1 }
  | SEMICOLON { EmptyStmt }
  | IDENTIFIER ASSIGN expr SEMICOLON { Assignment ($1, $3) }
  | INT IDENTIFIER ASSIGN expr SEMICOLON { VarDecl ($2, $4) }
  | IF LPAREN expr RPAREN stmt %prec IF { IfStmt ($3, $5, None) }
  | IF LPAREN expr RPAREN stmt ELSE stmt { IfStmt ($3, $5, Some $7) }
  | WHILE LPAREN expr RPAREN stmt { WhileStmt ($3, $5) }
  | BREAK SEMICOLON { BreakStmt }
  | CONTINUE SEMICOLON { ContinueStmt }
  | RETURN SEMICOLON { ReturnStmt None }
  | RETURN expr SEMICOLON { ReturnStmt (Some $2) }
  | expr SEMICOLON { ExprStmt $1 }

// (* 其余规则保持不变 *)
expr:
  | lor_expr { $1 }

lor_expr:
  | land_expr { $1 }
  | lor_expr OR land_expr { BinaryOp ($1, LogicalOr, $3) }

land_expr:
  | rel_expr { $1 }
  | land_expr AND rel_expr { BinaryOp ($1, LogicalAnd, $3) }

rel_expr:
  | add_expr { $1 }
  | rel_expr LT add_expr { BinaryOp ($1, Less, $3) }
  | rel_expr GT add_expr { BinaryOp ($1, Greater, $3) }
  | rel_expr LE add_expr { BinaryOp ($1, LessEqual, $3) }
  | rel_expr GE add_expr { BinaryOp ($1, GreaterEqual, $3) }
  | rel_expr EQ add_expr { BinaryOp ($1, Equal, $3) }
  | rel_expr NE add_expr { BinaryOp ($1, NotEqual, $3) }

add_expr:
  | mul_expr { $1 }
  | add_expr PLUS mul_expr { BinaryOp ($1, Add, $3) }
  | add_expr MINUS mul_expr { BinaryOp ($1, Sub, $3) }

mul_expr:
  | unary_expr { $1 }
  | mul_expr STAR unary_expr { BinaryOp ($1, Mul, $3) }
  | mul_expr DIV unary_expr { BinaryOp ($1, Div, $3) }
  | mul_expr MOD unary_expr { BinaryOp ($1, Mod, $3) }

unary_expr:
  | primary_expr { $1 }
  | PLUS unary_expr %prec UNARY_PLUS { UnaryOp (UnaryPlus, $2) }
  | MINUS unary_expr %prec UNARY_MINUS { UnaryOp (UnaryMinus, $2) }
  | BANG unary_expr { UnaryOp (LogicalNot, $2) }

primary_expr:
  | IDENTIFIER { Identifier $1 }
  | NUMBER { Number $1 }
  | LPAREN expr RPAREN { $2 }
  | IDENTIFIER LPAREN expr_list_opt RPAREN { FunctionCall ($1, $3) }

expr_list_opt:
  | /*(* empty *)*/ { [] }
  | expr_list { $1 }

expr_list:
  | expr { [$1] }
  | expr_list COMMA expr { $1 @ [$3] }

%%