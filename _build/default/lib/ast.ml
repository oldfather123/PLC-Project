type binop =
  | Add
  | Sub
  | Mul 
  | Div 
  | Leq
type expr = 
  | Var of string
  | Int of int
  | Bool of bool
  | Binop of binop * expr * expr
  | If of expr * expr * expr
  | Let of string * expr * expr
  | Func of string * expr
  | App of expr * expr