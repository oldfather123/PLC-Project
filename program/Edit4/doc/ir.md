# ToyC 语言三地址码中间代码生成器说明文档

## 概述

本模块是 ToyC 语言编译器的中间代码生成器，负责将抽象语法树（AST）转换为三地址码（Three-Address Code, TAC）形式的中间表示。该模块实现了完整的三地址码生成功能，包括表达式求值、控制流处理、函数调用机制等核心编译器技术。

## 核心数据结构

### 1. 三地址码操作类型 (three_addr_op)

```ocaml
type three_addr_op =
  | Add | Sub | Mul | Div | Mod                              (* 算术运算 *)
  | Equal | NotEqual | Less | LessEqual | Greater | GreaterEqual  (* 比较运算 *)
  | LogicalAnd | LogicalOr | LogicalNot                      (* 逻辑运算 *)
  | UnaryPlus | UnaryMinus                                    (* 一元运算 *)
```

**设计特点：**
- 直接对应 ToyC 语言的所有运算符
- 为后续优化和代码生成提供统一接口

### 2. 操作数类型 (operand)

```ocaml
type operand =
  | Temp of int          (* 临时变量 t0, t1, t2, ... *)
  | Var of string        (* 程序变量 *)
  | Const of int         (* 整数常量 *)
  | Label_ref of string  (* 标签引用 *)
```

**操作数说明：**
- **Temp(-1)**: 特殊标记，表示函数参数
- **Temp(n)**: 编译器生成的临时变量，用于存储中间计算结果
- **Var(name)**: 用户定义的变量
- **Const(value)**: 编译时常量
- **Label_ref(name)**: 跳转目标标签

### 3. 三地址码指令 (three_addr_instr)

```ocaml
type three_addr_instr =
  | Binary of operand * three_addr_op * operand * operand    (* result = op1 op op2 *)
  | Unary of operand * three_addr_op * operand               (* result = op operand *)
  | Copy of operand * operand                                (* dest = src *)
  | Jump_instr of string                                     (* goto label *)
  | JumpCond of operand * bool * string                      (* if [!]operand goto label *)
  | Label_instr of string                                    (* label: *)
  | Call_instr of operand option * string * int             (* [result =] call func(argc) *)
  | Param_instr of operand                                   (* param operand *)
  | Return_instr of operand option                           (* return [value] *)
```

**指令类型详解：**

| 指令类型 | 格式 | 描述 | 示例 |
|----------|------|------|------|
| **Binary** | `result = op1 op op2` | 二元运算 | `t1 = a + b` |
| **Unary** | `result = op operand` | 一元运算 | `t2 = -x` |
| **Copy** | `dest = src` | 赋值操作 | `x = t1` |
| **Jump_instr** | `goto label` | 无条件跳转 | `goto end_0` |
| **JumpCond** | `if [!]cond goto label` | 条件跳转 | `if !t3 goto else_1` |
| **Label_instr** | `label:` | 标签定义 | `while_start_2:` |
| **Call_instr** | `[result =] call func(argc)` | 函数调用 | `t4 = call add, 2` |
| **Param_instr** | `param operand` | 参数传递 | `param a` |
| **Return_instr** | `return [value]` | 函数返回 | `return t5` |

### 4. 代码生成器状态 (gen_state)

```ocaml
type gen_state = {
  mutable code: three_addr_instr list;        (* 生成的指令序列 *)
  mutable temp_counter: int;                  (* 临时变量计数器 *)
  mutable label_counter: int;                 (* 标签计数器 *)
  mutable break_label: string option;        (* 当前循环的break标签 *)
  mutable continue_label: string option;     (* 当前循环的continue标签 *)
}
```

**状态管理特性：**
- **可变状态**：使用 `mutable` 字段便于指令生成过程中的状态更新
- **临时变量管理**：自动分配唯一的临时变量编号
- **标签管理**：生成唯一的跳转标签
- **控制流栈**：支持嵌套循环的 break/continue 处理

## 核心功能模块

### 1. 表达式代码生成 (gen_expr)

#### 函数签名
```ocaml
gen_expr : gen_state -> expr -> operand
```

#### 处理的表达式类型

**基本表达式：**
```ocaml
| Number n -> Const n                    (* 整数字面量 *)
| Identifier name -> Var name            (* 变量引用 *)
```

**一元运算表达式：**
```ocaml
| UnaryOp (op, expr) ->
    let operand = gen_expr state expr in
    let result = new_temp state in
    let three_addr_op = unary_op_to_three_addr op in
    emit state (Unary (result, three_addr_op, operand));
    result
```

**二元运算表达式：**

普通二元运算直接生成三地址码：
```ocaml
let left_operand = gen_expr state left in
let right_operand = gen_expr state right in
let result = new_temp state in
let three_addr_op = binary_op_to_three_addr op in
emit state (Binary (result, three_addr_op, left_operand, right_operand));
result
```

**短路求值处理：**

逻辑与（&&）的实现：
```ocaml
| Ast.LogicalAnd ->
    let left_operand = gen_expr state left in
    let false_label = new_label state "and_false_" in
    let end_label = new_label state "and_end_" in
    let result = new_temp state in
    
    emit state (JumpCond (left_operand, false, false_label));  (* if !left goto false *)
    let right_operand = gen_expr state right in
    emit state (Copy (result, right_operand));                (* result = right *)
    emit state (Jump_instr end_label);                         (* goto end *)
    emit state (Label_instr false_label);                      (* false: *)
    emit state (Copy (result, Const 0));                       (* result = 0 *)
    emit state (Label_instr end_label);                        (* end: *)
    result
```

逻辑或（||）的实现类似，但在左操作数为真时短路。

**函数调用：**
```ocaml
| FunctionCall (func_name, args) ->
    let arg_operands = List.map (gen_expr state) args in
    List.iter (fun arg -> emit state (Param_instr arg)) (List.rev arg_operands);
    let result = new_temp state in
    emit state (Call_instr (Some result, func_name, List.length args));
    result
```

**参数传递顺序：**参数按从右到左的顺序压栈（`List.rev`），符合函数调用约定。

### 2. 语句代码生成 (gen_stmt)

#### 函数签名
```ocaml
gen_stmt : gen_state -> stmt -> unit
```

#### 支持的语句类型

**基本语句：**
```ocaml
| Block stmts -> List.iter (gen_stmt state) stmts    (* 语句块 *)
| EmptyStmt -> ()                                     (* 空语句 *)
| ExprStmt expr -> let _ = gen_expr state expr in ()  (* 表达式语句 *)
```

**变量操作：**
```ocaml
| Assignment (var, expr) ->                          (* 赋值语句 *)
    let expr_result = gen_expr state expr in
    emit state (Copy (Var var, expr_result))

| VarDecl (var, expr) ->                             (* 变量声明 *)
    let expr_result = gen_expr state expr in
    emit state (Copy (Var var, expr_result))
```

**条件语句：**
```ocaml
| IfStmt (cond, then_stmt, else_stmt) ->
    let cond_result = gen_expr state cond in
    let else_label = new_label state "else_" in
    let end_label = new_label state "end_if_" in
    
    emit state (JumpCond (cond_result, false, else_label));  (* if !cond goto else *)
    gen_stmt state then_stmt;                               (* then分支 *)
    emit state (Jump_instr end_label);                       (* goto end *)
    emit state (Label_instr else_label);                     (* else: *)
    (match else_stmt with                                    (* else分支 *)
     | Some stmt -> gen_stmt state stmt
     | None -> ());
    emit state (Label_instr end_label)                       (* end: *)
```

**循环语句：**
```ocaml
| WhileStmt (cond, body) ->
    let start_label = new_label state "while_start_" in
    let end_label = new_label state "while_end_" in
    
    (* 保存外层循环标签 *)
    let old_break = state.break_label in
    let old_continue = state.continue_label in
    state.break_label <- Some end_label;
    state.continue_label <- Some start_label;
    
    emit state (Label_instr start_label);                    (* start: *)
    let cond_result = gen_expr state cond in
    emit state (JumpCond (cond_result, false, end_label));   (* if !cond goto end *)
    gen_stmt state body;                                     (* 循环体 *)
    emit state (Jump_instr start_label);                     (* goto start *)
    emit state (Label_instr end_label);                      (* end: *)
    
    (* 恢复外层循环标签 *)
    state.break_label <- old_break;
    state.continue_label <- old_continue
```

**控制流语句：**
```ocaml
| BreakStmt ->
    (match state.break_label with
     | Some label -> emit state (Jump_instr label)
     | None -> failwith "break statement outside loop")

| ContinueStmt ->
    (match state.continue_label with
     | Some label -> emit state (Jump_instr label)
     | None -> failwith "continue statement outside loop")

| ReturnStmt expr_opt ->
    (match expr_opt with
     | Some expr ->
         let result = gen_expr state expr in
         emit state (Return_instr (Some result))
     | None ->
         emit state (Return_instr None))
```

### 3. 函数代码生成 (gen_func_def)

```ocaml
let gen_func_def state (FuncDef (ret_type, name, params, body)) =
  (* 函数标签 *)
  emit state (Label_instr name);
  
  (* 参数处理 *)
  List.iter (fun (Param param_name) ->
    emit state (Copy (Var param_name, Temp (-1)))
  ) params;
  
  (* 函数体 *)
  gen_stmt state body;
  
  (* 默认返回值处理 *)
  if not (ends_with_return body) then
    match ret_type with
    | Void -> emit state (Return_instr None)
    | Int -> emit state (Return_instr (Some (Const 0)))
```

**函数处理特性：**
- **函数标签**：为每个函数生成入口标签
- **参数绑定**：使用特殊临时变量 `Temp(-1)` 表示参数传递
- **默认返回**：只有在函数没有显式返回时才添加默认返回
- **类型匹配**：根据函数返回类型生成相应的默认返回值

### 4. 返回语句检查 (ends_with_return)

```ocaml
let rec ends_with_return stmt =
  match stmt with
  | ReturnStmt _ -> true
  | Block stmts when stmts <> [] -> 
      ends_with_return (List.hd (List.rev stmts))
  | IfStmt (_, then_stmt, Some else_stmt) -> 
      ends_with_return then_stmt && ends_with_return else_stmt
  | _ -> false
```

**检查逻辑：**
- **直接返回**：`return` 语句直接返回 true
- **语句块**：检查最后一条语句
- **完整的 if-else**：两个分支都必须以 return 结尾
- **其他情况**：返回 false

## 辅助功能模块

### 1. 状态管理

**临时变量生成：**
```ocaml
let new_temp state =
  let temp_num = state.temp_counter in
  state.temp_counter <- temp_num + 1;
  Temp temp_num
```

**标签生成：**
```ocaml
let new_label state prefix =
  let label_num = state.label_counter in
  state.label_counter <- label_num + 1;
  prefix ^ (string_of_int label_num)
```

**指令发射：**
```ocaml
let emit state instr =
  state.code <- instr :: state.code
```

### 2. 操作符转换

**二元操作符映射：**
```ocaml
let binary_op_to_three_addr = function
  | Ast.Add -> Add | Ast.Sub -> Sub | Ast.Mul -> Mul
  | Ast.Div -> Div | Ast.Mod -> Mod
  | Ast.Equal -> Equal | Ast.NotEqual -> NotEqual
  | Ast.Less -> Less | Ast.LessEqual -> LessEqual
  | Ast.Greater -> Greater | Ast.GreaterEqual -> GreaterEqual
  | Ast.LogicalAnd -> LogicalAnd | Ast.LogicalOr -> LogicalOr
```

**一元操作符映射：**
```ocaml
let unary_op_to_three_addr = function
  | Ast.UnaryPlus -> UnaryPlus
  | Ast.UnaryMinus -> UnaryMinus
  | Ast.LogicalNot -> LogicalNot
```

## 输出和格式化

### 1. 操作数字符串化

```ocaml
let string_of_operand = function
  | Temp n when n = -1 -> "param"           (* 参数标记 *)
  | Temp n -> "t" ^ (string_of_int n)       (* 临时变量 *)
  | Var name -> name                        (* 变量名 *)
  | Const n -> string_of_int n              (* 常量值 *)
  | Label_ref name -> name                  (* 标签名 *)
```

### 2. 指令字符串化

```ocaml
let string_of_three_addr_instr = function
  | Binary (result, op, op1, op2) ->
      Printf.sprintf "%s = %s %s %s"
        (string_of_operand result)
        (string_of_operand op1)
        (string_of_op op)
        (string_of_operand op2)
  
  | Copy (dest, src) ->
      Printf.sprintf "%s = %s"
        (string_of_operand dest)
        (string_of_operand src)
  
  | JumpCond (cond, true_jump, label) ->
      let condition = if true_jump then "" else "!" in
      Printf.sprintf "if %s%s goto %s" condition (string_of_operand cond) label
  
  (* ... 其他指令格式 ... *)
```

### 3. 格式化输出

```ocaml
let print_three_addr_code code =
  let rec print_with_spacing = function
    | [] -> ()
    | [instr] -> Printf.printf "%s\n" (string_of_three_addr_instr instr)
    | instr1 :: instr2 :: rest ->
        Printf.printf "%s\n" (string_of_three_addr_instr instr1);
        (* 在函数之间添加空行 *)
        (match instr1, instr2 with
         | Return_instr _, Label_instr _ -> Printf.printf "\n"
         | _ -> ());
        print_with_spacing (instr2 :: rest)
  in
  print_with_spacing code
```

**格式化特性：**
- 每条指令单独一行
- 函数之间自动添加空行分隔
- 清晰的可读格式