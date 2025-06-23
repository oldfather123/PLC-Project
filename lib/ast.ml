(* Abstract Syntax Tree for ToyC language *)

type identifier = string

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
  | Number of int
  | UnaryOp of unary_operator * expression
  | BinaryOp of expression * binary_operator * expression
  | FunctionCall of identifier * expression list

type type_specifier =
  | Int
  | Void

type param =
  | Param of identifier

type statement =
  | Block of statement list
  | EmptyStmt
  | ExprStmt of expression
  | Assignment of identifier * expression
  | VarDecl of identifier * expression
  | IfStmt of expression * statement * statement option
  | WhileStmt of expression * statement
  | BreakStmt
  | ContinueStmt
  | ReturnStmt of expression option  (* 修改：支持可选的返回值 *)

type func_def =
  | FuncDef of type_specifier * identifier * param list * statement

type comp_unit = func_def list

type program = comp_unit