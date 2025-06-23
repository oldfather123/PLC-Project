%{
  open Ast
%}

// Tokens 
%token <int> INTEGER_CONSTANT
%token <char> CHARACTER_CONSTANT
%token <string> STRING_CONSTANT
%token <string> IDENTIFIER

// Keywords 
%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM
%token EXTERN FLOAT FOR GOTO IF INT LONG REGISTER RETURN SHORT SIGNED
%token SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE

// Operators 
%token PLUS MINUS STAR DIV MOD
%token EQ NE LT LE GT GE
%token AND OR AMPERSAND PIPE HAT LSHIFT RSHIFT
%token BANG TILDE INCR DECR
%token ASSIGN PLUS_ASSIGN MINUS_ASSIGN STAR_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token AND_ASSIGN OR_ASSIGN XOR_ASSIGN LSHIFT_ASSIGN RSHIFT_ASSIGN

// Punctuation 
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token SEMICOLON COMMA DOT ARROW QUESTION COLON

%token EOF

// Precedence and associativity
%right ASSIGN PLUS_ASSIGN MINUS_ASSIGN STAR_ASSIGN DIV_ASSIGN MOD_ASSIGN AND_ASSIGN OR_ASSIGN XOR_ASSIGN LSHIFT_ASSIGN RSHIFT_ASSIGN
%right QUESTION COLON
%left OR
%left AND
%left PIPE
%left HAT
%left AMPERSAND
%left EQ NE
%left LT LE GT GE
%left LSHIFT RSHIFT
%left PLUS MINUS
%left STAR DIV MOD
%right BANG TILDE INCR DECR UNARY_PLUS UNARY_MINUS
%left LBRACKET RBRACKET LPAREN RPAREN DOT ARROW

%start translation_unit
%type <Ast.translation_unit> translation_unit

%%

// Translation unit 
translation_unit:
  | external_declaration_list EOF { $1 }

external_declaration_list:
  | external_declaration { [$1] }
  | external_declaration_list external_declaration { $1 @ [$2] }

external_declaration:
  | function_definition { FuncDef $1 }
  | declaration { Decl $1 }

// Function definition 
function_definition:
  | type_specifier direct_declarator declaration_list compound_statement 
    { FunctionDef ($1, $2, $3, $4) }
  | type_specifier direct_declarator compound_statement 
    { FunctionDef ($1, $2, [], $3) }

declaration_list:
  | declaration { [$1] }
  | declaration_list declaration { $1 @ [$2] }

// Declarations 
declaration:
  | type_specifier init_declarator_list SEMICOLON { Declaration ($1, $2) }

init_declarator_list:
  | direct_declarator { [$1] }
  | init_declarator_list COMMA direct_declarator { $1 @ [$3] }

type_specifier:
  | INT { Int }

// Declarators 
direct_declarator:
  | IDENTIFIER { DirectDeclarator $1 }
  | LPAREN direct_declarator RPAREN { $2 }
  | direct_declarator LPAREN parameter_type_list RPAREN 
    { FunctionDeclarator ($1, $3) }
  | direct_declarator LPAREN RPAREN 
    { FunctionDeclarator ($1, []) }

parameter_type_list:
  | parameter_list { $1 }

parameter_list:
  | parameter_declaration { [$1] }
  | parameter_list COMMA parameter_declaration { $1 @ [$3] }

parameter_declaration:
  | type_specifier direct_declarator { Parameter ($1, $2) }
  | type_specifier { Parameter ($1, DirectDeclarator "") }

// Statements 
statement:
  | expression_statement { $1 }
  | compound_statement { $1 }
  | selection_statement { $1 }
  | iteration_statement { $1 }
  | jump_statement { $1 }

expression_statement:
  | SEMICOLON { ExpressionStmt None }
  | expression SEMICOLON { ExpressionStmt (Some $1) }

compound_statement:
  | LBRACE RBRACE { CompoundStmt [] }
  | LBRACE statement_list RBRACE { CompoundStmt $2 }
  | LBRACE declaration_list RBRACE 
    { CompoundStmt (List.map (fun d -> DeclarationStmt d) $2) }
  | LBRACE declaration_list statement_list RBRACE 
    { CompoundStmt ((List.map (fun d -> DeclarationStmt d) $2) @ $3) }

statement_list:
  | statement { [$1] }
  | statement_list statement { $1 @ [$2] }

selection_statement:
  | IF LPAREN expression RPAREN statement 
    { IfStmt ($3, $5, None) }
  | IF LPAREN expression RPAREN statement ELSE statement 
    { IfStmt ($3, $5, Some $7) }

iteration_statement:
  | WHILE LPAREN expression RPAREN statement 
    { WhileStmt ($3, $5) }

jump_statement:
  | CONTINUE SEMICOLON { ContinueStmt }
  | BREAK SEMICOLON { BreakStmt }
  | RETURN SEMICOLON { ReturnStmt None }
  | RETURN expression SEMICOLON { ReturnStmt (Some $2) }

// Expressions 
expression:
  | assignment_expression { $1 }

assignment_expression:
  | conditional_expression { $1 }
  | unary_expression ASSIGN assignment_expression { Assignment ($1, $3) }

conditional_expression:
  | logical_or_expression { $1 }

logical_or_expression:
  | logical_and_expression { $1 }
  | logical_or_expression OR logical_and_expression 
    { BinaryOp ($1, LogicalOr, $3) }

logical_and_expression:
  | relational_expression { $1 }
  | logical_and_expression AND relational_expression 
    { BinaryOp ($1, LogicalAnd, $3) }

relational_expression:
  | additive_expression { $1 }
  | relational_expression LT additive_expression 
    { BinaryOp ($1, Less, $3) }
  | relational_expression GT additive_expression 
    { BinaryOp ($1, Greater, $3) }
  | relational_expression LE additive_expression 
    { BinaryOp ($1, LessEqual, $3) }
  | relational_expression GE additive_expression 
    { BinaryOp ($1, GreaterEqual, $3) }
  | relational_expression EQ additive_expression 
    { BinaryOp ($1, Equal, $3) }
  | relational_expression NE additive_expression 
    { BinaryOp ($1, NotEqual, $3) }

additive_expression:
  | multiplicative_expression { $1 }
  | additive_expression PLUS multiplicative_expression 
    { BinaryOp ($1, Add, $3) }
  | additive_expression MINUS multiplicative_expression 
    { BinaryOp ($1, Sub, $3) }

multiplicative_expression:
  | unary_expression { $1 }
  | multiplicative_expression STAR unary_expression 
    { BinaryOp ($1, Mul, $3) }
  | multiplicative_expression DIV unary_expression 
    { BinaryOp ($1, Div, $3) }
  | multiplicative_expression MOD unary_expression 
    { BinaryOp ($1, Mod, $3) }

unary_expression:
  | postfix_expression { $1 }
  | PLUS unary_expression %prec UNARY_PLUS { UnaryOp (UnaryPlus, $2) }
  | MINUS unary_expression %prec UNARY_MINUS { UnaryOp (UnaryMinus, $2) }
  | BANG unary_expression { UnaryOp (LogicalNot, $2) }

postfix_expression:
  | primary_expression { $1 }
  | postfix_expression LPAREN RPAREN 
    { match $1 with 
      | Identifier id -> FunctionCall (id, [])
      | _ -> failwith "Invalid function call" }
  | postfix_expression LPAREN argument_expression_list RPAREN 
    { match $1 with 
      | Identifier id -> FunctionCall (id, $3)
      | _ -> failwith "Invalid function call" }

primary_expression:
  | IDENTIFIER { Identifier $1 }
  | INTEGER_CONSTANT { IntConstant $1 }
  | LPAREN expression RPAREN { $2 }

argument_expression_list:
  | assignment_expression { [$1] }
  | argument_expression_list COMMA assignment_expression { $1 @ [$3] }

constant_expression:
  | conditional_expression { $1 }

expression_opt:
  | /* empty */ { None }
  | expression { Some $1 }

%%