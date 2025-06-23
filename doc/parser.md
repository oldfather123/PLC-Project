# Parser.mly 说明文档

## 概述

这是一个基于 OCamlyacc 的 C 语言子集语法分析器，实现了 C 语言的核心语法结构，包括变量声明、函数定义、控制结构和表达式等。

## Token 定义

### 字面量 Token
```ocaml
%token <int> INTEGER_CONSTANT     (* 整数常量，如: 42, 0, -123 *)
%token <char> CHARACTER_CONSTANT  (* 字符常量，如: 'a', '\n', '\'' *)
%token <string> STRING_CONSTANT   (* 字符串常量，如: "hello", "world\n" *)
%token <string> IDENTIFIER        (* 标识符，如: main, variable, func *)
```

### 关键字 Token
```ocaml
%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM
%token EXTERN FLOAT FOR GOTO IF INT LONG REGISTER RETURN SHORT SIGNED
%token SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE
```

**主要使用的关键字：**
- `INT`, `CHAR`, `VOID`: 基本数据类型
- `IF`, `ELSE`: 条件语句
- `WHILE`, `FOR`: 循环语句
- `RETURN`, `BREAK`, `CONTINUE`: 跳转语句

### 运算符 Token
```ocaml
(* 算术运算符 *)
%token PLUS MINUS STAR DIV MOD        (* +, -, *, /, % *)

(* 比较运算符 *)
%token EQ NE LT LE GT GE              (* ==, !=, <, <=, >, >= *)

(* 逻辑和位运算符 *)
%token AND OR AMPERSAND PIPE HAT      (* &&, ||, &, |, ^ *)
%token LSHIFT RSHIFT                  (* <<, >> *)
%token BANG TILDE                     (* !, ~ *)

(* 自增自减运算符 *)
%token INCR DECR                      (* ++, -- *)

(* 赋值运算符 *)
%token ASSIGN                         (* = *)
%token PLUS_ASSIGN MINUS_ASSIGN       (* +=, -= *)
%token STAR_ASSIGN DIV_ASSIGN MOD_ASSIGN (* *=, /=, %= *)
%token AND_ASSIGN OR_ASSIGN XOR_ASSIGN   (* &=, |=, ^= *)
%token LSHIFT_ASSIGN RSHIFT_ASSIGN    (* <<=, >>= *)
```

### 分隔符 Token
```ocaml
%token LPAREN RPAREN                  (* (, ) *)
%token LBRACKET RBRACKET              (* [, ] *)
%token LBRACE RBRACE                  (* {, } *)
%token SEMICOLON COMMA                (* ;, , *)
%token DOT ARROW                      (* ., -> *)
%token QUESTION COLON                 (* ?, : *)
```

## 运算符优先级和结合性

```ocaml
(* 从低到高的优先级顺序 *)
%right ASSIGN PLUS_ASSIGN ...         (* 赋值运算符，右结合 *)
%right QUESTION COLON                 (* 三元运算符，右结合 *)
%left OR                              (* 逻辑或 *)
%left AND                             (* 逻辑与 *)
%left PIPE                            (* 按位或 *)
%left HAT                             (* 按位异或 *)
%left AMPERSAND                       (* 按位与 *)
%left EQ NE                           (* 相等性比较 *)
%left LT LE GT GE                     (* 关系比较 *)
%left LSHIFT RSHIFT                   (* 位移运算 *)
%left PLUS MINUS                      (* 加减运算 *)
%left STAR DIV MOD                    (* 乘除模运算 *)
%right BANG TILDE INCR DECR UNARY_PLUS UNARY_MINUS  (* 一元运算符，右结合 *)
%left LBRACKET RBRACKET LPAREN RPAREN DOT ARROW     (* 后缀运算符 *)
```

## 主要语法规则说明

### 1. 程序结构

#### translation_unit (程序单元)
```ocaml
translation_unit:
  | external_declaration_list EOF { $1 }
```
- **功能**: 程序的顶层结构，由外部声明列表组成
- **返回**: `external_declaration list`

#### external_declaration (外部声明)
```ocaml
external_declaration:
  | function_definition { FuncDef $1 }
  | declaration { Decl $1 }
```
- **功能**: 可以是函数定义或变量声明
- **返回**: `FuncDef of function_definition | Decl of declaration`

### 2. 函数定义

#### function_definition
```ocaml
function_definition:
  | type_specifier declarator declaration_list compound_statement 
    { FunctionDef ($1, $2, $3, $4) }
  | type_specifier declarator compound_statement 
    { FunctionDef ($1, $2, [], $3) }
```
- **功能**: 定义函数，包含返回类型、函数名、参数、局部声明和函数体
- **支持**: 带或不带局部变量声明的函数定义
- **示例**: `int main() { return 0; }`

### 3. 声明系统

#### declaration (声明)
```ocaml
declaration:
  | type_specifier init_declarator_list SEMICOLON { Declaration ($1, $2) }
```
- **功能**: 变量或函数声明
- **支持**: 多个变量同时声明

#### type_specifier (类型说明符)
```ocaml
type_specifier:
  | VOID { Void }
  | CHAR { Char }
  | INT { Int }
```
- **支持的基本类型**: `void`, `char`, `int`

#### declarator (声明符)
```ocaml
declarator:
  | pointer direct_declarator { $1 $2 }
  | direct_declarator { $1 }

direct_declarator:
  | IDENTIFIER { DirectDeclarator $1 }
  | LPAREN declarator RPAREN { $2 }
  | direct_declarator LBRACKET constant_expression RBRACKET 
    { ArrayDeclarator ($1, Some $3) }
  | direct_declarator LBRACKET RBRACKET 
    { ArrayDeclarator ($1, None) }
  | direct_declarator LPAREN parameter_type_list RPAREN 
    { FunctionDeclarator ($1, $3) }
  | direct_declarator LPAREN RPAREN 
    { FunctionDeclarator ($1, []) }
```
- **支持**: 普通变量、指针、数组、函数声明
- **示例**: `int *ptr`, `int arr[10]`, `int func(int x)`

### 4. 语句结构

#### statement (语句)
```ocaml
statement:
  | expression_statement { $1 }
  | compound_statement { $1 }
  | selection_statement { $1 }
  | iteration_statement { $1 }
  | jump_statement { $1 }
```

#### compound_statement (复合语句)
```ocaml
compound_statement:
  | LBRACE RBRACE { CompoundStmt [] }
  | LBRACE statement_list RBRACE { CompoundStmt $2 }
  | LBRACE declaration_list RBRACE 
    { CompoundStmt (List.map (fun d -> DeclarationStmt d) $2) }
  | LBRACE declaration_list statement_list RBRACE 
    { CompoundStmt ((List.map (fun d -> DeclarationStmt d) $2) @ $3) }
```
- **功能**: 用花括号包围的语句块
- **支持**: 只有声明、只有语句、或声明和语句混合

#### selection_statement (选择语句)
```ocaml
selection_statement:
  | IF LPAREN expression RPAREN statement 
    { IfStmt ($3, $5, None) }
  | IF LPAREN expression RPAREN statement ELSE statement 
    { IfStmt ($3, $5, Some $7) }
```
- **支持**: `if` 和 `if-else` 语句

#### iteration_statement (循环语句)
```ocaml
iteration_statement:
  | WHILE LPAREN expression RPAREN statement 
    { WhileStmt ($3, $5) }
  | FOR LPAREN expression_opt SEMICOLON expression_opt SEMICOLON expression_opt RPAREN statement 
    { ForStmt ($3, $5, $7, $9) }
```
- **支持**: `while` 和 `for` 循环
- **特点**: `for` 循环的三个部分都是可选的

#### jump_statement (跳转语句)
```ocaml
jump_statement:
  | CONTINUE SEMICOLON { ContinueStmt }
  | BREAK SEMICOLON { BreakStmt }
  | RETURN SEMICOLON { ReturnStmt None }
  | RETURN expression SEMICOLON { ReturnStmt (Some $2) }
```

### 5. 表达式系统

表达式系统按照 C 语言的运算符优先级构建，从低到高包括：

#### assignment_expression (赋值表达式)
```ocaml
assignment_expression:
  | conditional_expression { $1 }
  | unary_expression ASSIGN assignment_expression { Assignment ($1, $3) }
```
- **特点**: 右结合
- **示例**: `a = b = c`

#### conditional_expression (条件表达式)
```ocaml
conditional_expression:
  | logical_or_expression { $1 }
  | logical_or_expression QUESTION expression COLON conditional_expression 
    { ConditionalExpr ($1, $3, $5) }
```
- **功能**: 三元运算符 `? :`
- **示例**: `a > b ? a : b`

#### 二元运算表达式层次
1. **logical_or_expression**: 逻辑或 `||`
2. **logical_and_expression**: 逻辑与 `&&`
3. **inclusive_or_expression**: 按位或 `|`
4. **exclusive_or_expression**: 按位异或 `^`
5. **and_expression**: 按位与 `&`
6. **equality_expression**: 相等比较 `==`, `!=`
7. **relational_expression**: 关系比较 `<`, `<=`, `>`, `>=`
8. **shift_expression**: 位移 `<<`, `>>`
9. **additive_expression**: 加减 `+`, `-`
10. **multiplicative_expression**: 乘除模 `*`, `/`, `%`

#### unary_expression (一元表达式)
```ocaml
unary_expression:
  | postfix_expression { $1 }
  | INCR unary_expression { PreIncrement $2 }
  | DECR unary_expression { PreDecrement $2 }
  | PLUS unary_expression %prec UNARY_PLUS { UnaryOp (UnaryPlus, $2) }
  | MINUS unary_expression %prec UNARY_MINUS { UnaryOp (UnaryMinus, $2) }
  | BANG unary_expression { UnaryOp (LogicalNot, $2) }
  | TILDE unary_expression { UnaryOp (BitwiseNot, $2) }
```
- **支持**: 前缀自增/自减、一元加减、逻辑非、按位取反

#### postfix_expression (后缀表达式)
```ocaml
postfix_expression:
  | primary_expression { $1 }
  | postfix_expression LBRACKET expression RBRACKET 
    { ArrayAccess ($1, $3) }
  | postfix_expression LPAREN RPAREN 
    { match $1 with 
      | Identifier id -> FunctionCall (id, [])
      | _ -> failwith "Invalid function call" }
  | postfix_expression LPAREN argument_expression_list RPAREN 
    { match $1 with 
      | Identifier id -> FunctionCall (id, $3)
      | _ -> failwith "Invalid function call" }
  | postfix_expression INCR { PostIncrement $1 }
  | postfix_expression DECR { PostDecrement $1 }
```
- **支持**: 数组访问、函数调用、后缀自增/自减

#### primary_expression (基本表达式)
```ocaml
primary_expression:
  | IDENTIFIER { Identifier $1 }
  | constant { Constant $1 }
  | LPAREN expression RPAREN { $2 }
```

## 辅助规则

### expression_opt (可选表达式)
```ocaml
expression_opt:
  | /* empty */ { None }
  | expression { Some $1 }
```
- **用途**: 在 `for` 循环中使用，允许省略某些表达式

### constant (常量)
```ocaml
constant:
  | INTEGER_CONSTANT { IntConst $1 }
  | CHARACTER_CONSTANT { CharConst $1 }
  | STRING_CONSTANT { StringConst $1 }
```

## 语法特性

1. **完整的运算符优先级**: 严格按照 C 语言标准实现
2. **左递归消除**: 所有左递归都正确处理
3. **二义性解决**: 通过优先级和结合性声明解决
4. **错误恢复**: 基本的语法错误检测
5. **AST 构建**: 每个规则都构建相应的 AST 节点

## 使用示例

该语法分析器可以正确解析如下 C 代码：

```c
int factorial(int n) {
    int result;
    if (n <= 1) {
        return 1;
    } else {
        result = 1;
        while (n > 1) {
            result = result * n;
            n = n - 1;
        }
        return result;
    }
}

int main() {
    int x;
    x = factorial(5);
    return x;
}
```

---


## pointer 规则解析

```ocaml
pointer:
  | STAR { fun d -> PointerDeclarator d }
  | STAR pointer { fun d -> PointerDeclarator ($2 d) }
```

这个规则使用了**高阶函数**的概念，返回的是一个函数，而不是直接的AST节点。

### 第一条规则：`STAR { fun d -> PointerDeclarator d }`

- **匹配**: 单个 `*`
- **返回**: 一个函数 `fun d -> PointerDeclarator d`
- **含义**: 这个函数接受一个声明符 `d`，然后返回 `PointerDeclarator d`

### 第二条规则：`STAR pointer { fun d -> PointerDeclarator ($2 d) }`

- **匹配**: `*` 后面跟着另一个 `pointer`
- **返回**: 一个函数 `fun d -> PointerDeclarator ($2 d)`
- **含义**: `$2` 是递归得到的 `pointer`（也是一个函数），`$2 d` 先调用这个函数，然后外层再包装一个 `PointerDeclarator`

## 工作原理示例

### 例子1：`int *x`
1. 遇到一个 `*`，匹配第一条规则
2. 返回函数：`fun d -> PointerDeclarator d`
3. 在 `declarator` 规则中：`pointer direct_declarator { $1 $2 }`
4. `$1` 是函数 `fun d -> PointerDeclarator d`
5. `$2` 是 `DirectDeclarator "x"`
6. 结果：`$1 $2` = `(fun d -> PointerDeclarator d) (DirectDeclarator "x")` = `PointerDeclarator (DirectDeclarator "x")`

### 例子2：`int **x` （指向指针的指针）
1. 第一个 `*` 匹配第二条规则，需要一个 `pointer`
2. 第二个 `*` 匹配第一条规则，返回 `fun d -> PointerDeclarator d`
3. 第一个 `*` 的规则变成：`fun d -> PointerDeclarator ((fun d -> PointerDeclarator d) d)`
4. 简化为：`fun d -> PointerDeclarator (PointerDeclarator d)`
5. 最终应用到 `DirectDeclarator "x"`：
   - `PointerDeclarator (PointerDeclarator (DirectDeclarator "x"))`

## 为什么这样设计？

这种设计解决了**右结合性**的问题：

```c
int ***x;  // 从右往左读：x是指向指向指针的指针的指针
```

传统的左递归写法会导致解析困难，而使用函数的方式可以：
1. **自然处理多级指针**
2. **保持正确的结合顺序**
3. **避免左递归问题**

## 等价的直观理解

你可以把它理解为构建一个"包装器链"：

```ocaml
(* 对于 int **x *)
let wrapper1 = fun d -> PointerDeclarator d          (* 内层* *)
let wrapper2 = fun d -> PointerDeclarator (wrapper1 d)  (* 外层* *)
let result = wrapper2 (DirectDeclarator "x")
(* 结果: PointerDeclarator (PointerDeclarator (DirectDeclarator "x")) *)
```

这样设计确保了多级指针的正确嵌套结构，从最内层的标识符开始，逐层包装指针声明符。