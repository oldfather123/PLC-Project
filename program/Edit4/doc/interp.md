# ToyC 语言解释器说明文档

## 概述

本解释器是为 ToyC 语言设计的直接执行器，能够解析并执行 ToyC 程序。解释器采用树遍历的方式，直接在抽象语法树（AST）上执行程序，无需生成中间代码或目标代码。

## 核心数据结构

### 1. 值类型 (Value Type)

```ocaml
type value = 
  | IntValue of int     (* 整数值 *)
  | VoidValue          (* 空值，用于 void 函数返回 *)
```

### 2. 环境 (Environment)

环境用于管理变量的作用域和值绑定：

```ocaml
module Environment = struct
  type 'a env = (string * 'a) list  (* 变量名到值的映射列表 *)
  
  val empty : 'a env                (* 空环境 *)
  val bind : string -> 'a -> 'a env -> 'a env     (* 绑定变量 *)
  val lookup : string -> 'a env -> 'a             (* 查找变量 *)
  val update : string -> 'a -> 'a env -> 'a env   (* 更新变量 *)
end
```

**特点：**
- 使用关联列表实现
- 支持变量的遮蔽（shadowing）
- 新绑定的变量会覆盖同名的外层变量

### 3. 函数环境 (Function Environment)

```ocaml
type func_env = (string * func_def) list
```

存储所有用户定义的函数，支持函数查找和调用。

## 异常处理机制

### 1. 运行时异常

```ocaml
exception RuntimeError of string
```

用于处理运行时错误，如：
- 未定义的变量或函数
- 类型错误
- 除零错误
- 参数数量不匹配

### 2. 控制流异常

```ocaml
exception BreakException of value Environment.env
exception ContinueException of value Environment.env
exception ReturnException of int option
```

**设计目的：**
- **BreakException**: 实现 `break` 语句的跳出循环功能
- **ContinueException**: 实现 `continue` 语句的跳到循环开始
- **ReturnException**: 实现函数的 `return` 语句

**携带环境的原因：**
- 保证异常处理后环境状态的正确性
- 支持嵌套的控制流结构

## 核心功能模块

### 1. 表达式求值 (Expression Evaluation)

#### 主函数
```ocaml
eval_expr : expr -> value Environment.env -> func_env -> value
```

#### 支持的表达式类型

**基本表达式：**
- `Identifier`: 变量引用，从环境中查找值
- `Number`: 整数字面量，直接返回 `IntValue`

**一元运算：**
- `UnaryPlus`: 正号运算，对整数无影响
- `UnaryMinus`: 负号运算，计算相反数
- `LogicalNot`: 逻辑非运算，0为假，非0为真

**二元运算：**

| 运算符 | 类型 | 描述 | 特殊处理 |
|--------|------|------|----------|
| `+`, `-`, `*` | 算术 | 基本算术运算 | - |
| `/`, `%` | 算术 | 除法和取模 | 检查除零错误 |
| `==`, `!=` | 比较 | 相等性比较 | 支持不同类型比较 |
| `<`, `<=`, `>`, `>=` | 比较 | 大小比较 | 仅支持整数 |
| `&&` | 逻辑 | 逻辑与 | **短路求值** |
| `\|\|` | 逻辑 | 逻辑或 | **短路求值** |

**短路求值实现：**
```ocaml
| v1, LogicalAnd, v2 -> 
  if value_to_bool v1 then v2 else IntValue 0
| v1, LogicalOr, v2 -> 
  if value_to_bool v1 then v1 else v2
```

**函数调用：**
- 支持用户定义函数和内置函数
- 自动处理参数传递和作用域

### 2. 语句执行 (Statement Execution)

#### 主函数
```ocaml
exec_stmt : stmt -> value Environment.env -> func_env -> value Environment.env
```

#### 支持的语句类型

**基本语句：**
- `Block`: 语句块，按顺序执行内部语句
- `EmptyStmt`: 空语句，不执行任何操作
- `ExprStmt`: 表达式语句，求值表达式但忽略结果

**变量操作：**
- `VarDecl`: 变量声明，在环境中绑定新变量
- `Assignment`: 变量赋值，更新已存在变量的值

**控制流：**
- `IfStmt`: 条件语句，支持可选的 else 分支
- `WhileStmt`: 循环语句，支持 break/continue
- `BreakStmt`: 跳出循环
- `ContinueStmt`: 继续下一次循环迭代
- `ReturnStmt`: 函数返回

### 3. 函数调用机制

#### 内置函数

**putint(int)**
```ocaml
putint(42)  (* 输出: 42 *)
```
- 功能：输出整数到标准输出
- 参数：一个整数
- 返回：VoidValue

**getint()**
```ocaml
int x = getint()  (* 从标准输入读取整数 *)
```
- 功能：从标准输入读取整数
- 参数：无
- 返回：读取的整数值

#### 用户定义函数

**调用流程：**
1. 查找函数定义
2. 检查参数数量匹配
3. 创建新的局部环境
4. 绑定形参到实参值
5. 执行函数体
6. 处理返回值

**参数传递：**
- 采用值传递（call by value）
- 实参在调用前完全求值
- 形参在新环境中绑定

**返回值处理：**
```ocaml
try
  let _ = exec_stmt body new_env func_env in
  (* 隐式返回默认值 *)
  match ret_type with
  | Void -> VoidValue
  | Int -> IntValue 0
with
| ReturnException (Some i) -> IntValue i
| ReturnException None -> VoidValue
```

### 4. 循环控制实现

#### While 循环执行
```ocaml
and exec_while cond body env func_env =
  let rec loop current_env =
    let cond_value = eval_expr cond current_env func_env in
    if value_to_bool cond_value then
      try
        let new_env = exec_stmt body current_env func_env in
        loop new_env
      with
      | BreakException break_env -> break_env
      | ContinueException continue_env -> loop continue_env
    else
      current_env
  in
  loop env
```

**特点：**
- 支持条件求值
- 正确处理 break/continue 异常
- 保持环境状态的一致性

## 程序执行流程

### 1. 程序初始化

```ocaml
let interpret program =
  let func_env = build_func_env program in  (* 构建函数环境 *)
  match find_main_function func_env with   (* 查找 main 函数 *)
```

### 2. Main 函数验证

- 检查 main 函数是否存在
- 验证 main 函数无参数
- 确保函数名正确

### 3. 执行和退出码

**正常退出：**
- 函数执行完毕：退出码 0
- 显式 return：使用返回值作为退出码

**异常退出：**
- 运行时错误：退出码 1
- 控制流异常：退出码 1

## 错误处理策略

### 1. 类型检查

- 运行时动态类型检查
- 不兼容的操作会抛出 RuntimeError

### 2. 未定义引用

- 变量未定义：查找失败时抛出异常
- 函数未定义：调用时检查函数存在性

### 3. 算术异常

- 除零检查：除法和取模运算
- 溢出处理：依赖 OCaml 的整数处理

### 4. 控制流验证

- break/continue 只能在循环内使用
- return 只能在函数内使用

