(* Abstract Syntax Tree for C subset *)

type identifier = string

type constant = 
  | IntConst of int
  | CharConst of char
  | StringConst of string

type unary_operator =
  | UnaryPlus
  | UnaryMinus
  | LogicalNot
  | BitwiseNot

type binary_operator =
  | Add | Sub | Mul | Div | Mod
  | Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual
  | LogicalAnd | LogicalOr
  | BitwiseAnd | BitwiseOr | BitwiseXor
  | LeftShift | RightShift
  | Assign

type expression =
  | Identifier of identifier
  | Constant of constant
  | UnaryOp of unary_operator * expression
  | BinaryOp of expression * binary_operator * expression
  | FunctionCall of identifier * expression list
  | ArrayAccess of expression * expression
  | PostIncrement of expression
  | PostDecrement of expression
  | PreIncrement of expression
  | PreDecrement of expression
  | ConditionalExpr of expression * expression * expression
  | Assignment of expression * expression

type type_specifier =
  | Int
  | Char
  | Void

type declarator =
  | DirectDeclarator of identifier
  | PointerDeclarator of declarator
  | ArrayDeclarator of declarator * expression option
  | FunctionDeclarator of declarator * parameter list

and parameter =
  | Parameter of type_specifier * declarator

type declaration =
  | Declaration of type_specifier * declarator list

type statement =
  | ExpressionStmt of expression option
  | CompoundStmt of statement list
  | IfStmt of expression * statement * statement option
  | WhileStmt of expression * statement
  | ForStmt of expression option * expression option * expression option * statement
  | ReturnStmt of expression option
  | BreakStmt
  | ContinueStmt
  | DeclarationStmt of declaration

type function_definition =
  | FunctionDef of type_specifier * declarator * declaration list * statement

type external_declaration =
  | FuncDef of function_definition
  | Decl of declaration

type translation_unit = external_declaration list

type program = translation_unit