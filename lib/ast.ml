(* Abstract Syntax Tree for C subset *)

type identifier = string

type intconstant = int

type unary_operator =
  | UnaryPlus
  | UnaryMinus
  | LogicalNot

type binary_operator =
  | Add | Sub | Mul | Div | Mod
  | Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual
  | LogicalAnd | LogicalOr

type expression =
  | Identifier of identifier
  | IntConstant of intconstant
  | UnaryOp of unary_operator * expression
  | BinaryOp of expression * binary_operator * expression
  | FunctionCall of identifier * expression list
  | Assignment of expression * expression

type type_specifier =
  | Int

type declarator =
  | DirectDeclarator of identifier
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