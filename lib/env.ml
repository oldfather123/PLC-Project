open Ast

exception RuntimeError of string
exception Break
exception Continue


type value =
  | Number of int
  | Function of func_def

exception Return of value option

type t = {
  vars : (identifier, value) Hashtbl.t;
  funcs : (identifier, func_def) Hashtbl.t;
  parent : t option;
}

let create ?(parent=None) () =
  { vars = Hashtbl.create 16; funcs = Hashtbl.create 8; parent }

let rec find_var env name =
  match Hashtbl.find_opt env.vars name with
  | Some v -> v
  | None ->
    (match env.parent with
     | Some p -> find_var p name
     | None -> raise (RuntimeError ("Unbound variable: " ^ name)))

let rec find_func env name =
  match Hashtbl.find_opt env.funcs name with
  | Some f -> f
  | None ->
    (match env.parent with
     | Some p -> find_func p name
     | None -> raise (RuntimeError ("Unbound function: " ^ name)))

let set_var env name value =
  Hashtbl.replace env.vars name value

let add_func env (FuncDef (_, name, _, _) as def) =
  Hashtbl.replace env.funcs name def