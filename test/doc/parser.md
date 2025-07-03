# ToyC 语言语法分析器

## 概述

这是一个基于 OCaml Menhir 的 ToyC 语言语法分析器，实现了 C 语言的核心语法子集。ToyC 支持函数定义、基本语句、表达式和控制流结构。

## 语言特性

### 支持的语法成分

- **函数定义**：支持 `int` 和 `void` 返回类型
- **变量声明**：支持整型变量声明和初始化
- **控制结构**：if-else、while 循环
- **表达式**：算术、逻辑、关系运算
- **函数调用**：支持带参数的函数调用
- **跳转语句**：break、continue、return

### 不支持的特性

- 数组、指针、结构体
- 字符和字符串类型
- 多维数组
- 复杂的类型系统
- 预处理指令

## 文法定义

### 编译单元
```
CompUnit → FuncDef+
```

### 函数定义
```
FuncDef → ("int" | "void") ID "(" (Param ("," Param)*)? ")" Block
Param → "int" ID
```

### 语句
```
Stmt → Block 
     | ";" 
     | Expr ";" 
     | ID "=" Expr ";"
     | "int" ID "=" Expr ";"
     | "if" "(" Expr ")" Stmt ("else" Stmt)?
     | "while" "(" Expr ")" Stmt
     | "break" ";" 
     | "continue" ";" 
     | "return" ";"
     | "return" Expr ";"

Block → "{" Stmt* "}"
```

### 表达式
```
Expr → LOrExpr
LOrExpr → LAndExpr | LOrExpr "||" LAndExpr
LAndExpr → RelExpr | LAndExpr "&&" RelExpr
RelExpr → AddExpr | RelExpr ("<"|">"|"<="|">="|"=="|"!=") AddExpr
AddExpr → MulExpr | AddExpr ("+"|"-") MulExpr
MulExpr → UnaryExpr | MulExpr ("*"|"/"|"%") UnaryExpr
UnaryExpr → PrimaryExpr | ("+"|"-"|"!") UnaryExpr
PrimaryExpr → ID | NUMBER | "(" Expr ")" | ID "(" (Expr ("," Expr)*)? ")"
```

## 语法分析器实现

### Token 定义

#### 字面量 Token
```ocaml
%token <int> NUMBER           (* 整数常量 *)
%token <string> IDENTIFIER    (* 标识符 *)
```

#### 关键字 Token
```ocaml
%token BREAK CONTINUE ELSE IF INT RETURN VOID WHILE
```

#### 运算符 Token
```ocaml
%token PLUS MINUS STAR DIV MOD     (* +, -, *, /, % *)
%token EQ NE LT LE GT GE           (* ==, !=, <, <=, >, >= *)
%token AND OR BANG                 (* &&, ||, ! *)
%token ASSIGN                      (* = *)
```

#### 分隔符 Token
```ocaml
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA
```

### 运算符优先级

```ocaml
%left OR                    (* || - 最低优先级 *)
%left AND                   (* && *)
%left EQ NE                 (* ==, != *)
%left LT LE GT GE          (* <, <=, >, >= *)
%left PLUS MINUS           (* +, - *)
%left STAR DIV MOD         (* *, /, % *)
%right BANG UNARY_PLUS UNARY_MINUS  (* !, 一元+, 一元- - 最高优先级 *)
%nonassoc IF               (* 解决 dangling else 问题 *)
%nonassoc ELSE
```

### AST 数据结构

#### 基本类型
```ocaml
type identifier = string

type unary_operator =
  | UnaryPlus    (* + *)
  | UnaryMinus   (* - *)
  | LogicalNot   (* ! *)

type binary_operator =
  | Add | Sub | Mul | Div | Mod                    (* 算术运算 *)
  | Equal | NotEqual                               (* 相等比较 *)
  | Less | LessEqual | Greater | GreaterEqual      (* 关系比较 *)
  | LogicalAnd | LogicalOr                         (* 逻辑运算 *)
```

#### 表达式
```ocaml
type expression =
  | Identifier of identifier                        (* 变量名 *)
  | Number of int                                   (* 整数常量 *)
  | UnaryOp of unary_operator * expression         (* 一元运算 *)
  | BinaryOp of expression * binary_operator * expression  (* 二元运算 *)
  | FunctionCall of identifier * expression list   (* 函数调用 *)
```

#### 语句
```ocaml
type statement =
  | Block of statement list                         (* 语句块 *)
  | EmptyStmt                                       (* 空语句 *)
  | ExprStmt of expression                          (* 表达式语句 *)
  | Assignment of identifier * expression          (* 赋值语句 *)
  | VarDecl of identifier * expression             (* 变量声明 *)
  | IfStmt of expression * statement * statement option  (* if-else *)
  | WhileStmt of expression * statement            (* while 循环 *)
  | BreakStmt | ContinueStmt                       (* 跳转语句 *)
  | ReturnStmt of expression option                (* return 语句 *)
```

#### 函数和程序
```ocaml
type type_specifier = Int | Void
type param = Param of identifier
type func_def = FuncDef of type_specifier * identifier * param list * statement
type comp_unit = func_def list
```

## 关键设计决策

### 1. Dangling Else 问题解决

**问题**：
```c
if (a) if (b) x = 1; else x = 2;
```

**解决方案**：使用优先级声明
```ocaml
%nonassoc IF
%nonassoc ELSE

stmt:
  | IF LPAREN expr RPAREN stmt %prec IF { IfStmt ($3, $5, None) }
  | IF LPAREN expr RPAREN stmt ELSE stmt { IfStmt ($3, $5, Some $7) }
```

### 2. 语句规则冲突解决

**问题**：`expr SEMICOLON` 规则过于宽泛，与具体语句冲突

**解决方案**：将通用规则放在最后
```ocaml
stmt:
  | RETURN SEMICOLON { ReturnStmt None }           (* 具体规则优先 *)
  | IDENTIFIER ASSIGN expr SEMICOLON { Assignment ($1, $3) }
  | INT IDENTIFIER ASSIGN expr SEMICOLON { VarDecl ($2, $4) }
  | expr SEMICOLON { ExprStmt $1 }                 (* 通用规则最后 *)
```

### 3. 左递归处理

所有二元运算符都使用左递归实现左结合性：
```ocaml
add_expr:
  | mul_expr { $1 }
  | add_expr PLUS mul_expr { BinaryOp ($1, Add, $3) }   (* 左递归 *)
```

--- 