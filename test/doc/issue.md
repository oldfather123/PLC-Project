## 问题1：if-else移进规约冲突
shift/reduce 冲突是经典的 "dangling else" 问题。问题出现在这两条规则：

```ocaml
| IF LPAREN expr RPAREN stmt { IfStmt ($3, $5, None) }
| IF LPAREN expr RPAREN stmt ELSE stmt { IfStmt ($3, $5, Some $7) }
```

### 问题分析

当解析器遇到这样的代码时：
```c
if (a) if (b) x = 1; else x = 2;
```

解析器不知道 `else` 应该匹配哪个 `if`：
1. 内层的 `if (b)`（shift）
2. 外层的 `if (a)`（reduce）

### 解决方案

只需要在 if 语句的第一条规则上添加 `%prec IF`：

```ocaml
// 修改 parser.mly 文件中的这一行：
| IF LPAREN expr RPAREN stmt %prec IF { IfStmt ($3, $5, None) }
```

完整的修改后的优先级部分：

```ocaml
// Precedence and associativity
%left OR
%left AND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left STAR DIV MOD
%right BANG UNARY_PLUS UNARY_MINUS
%nonassoc IF
%nonassoc ELSE
```

这样修改后，解析器会默认将 `else` 与最近的 `if` 匹配，这是C语言的标准行为。

---

## 问题2：规则匹配顺序冲突

`expr SEMICOLON` 规则过于宽泛，与其他具体语句规则产生冲突。

**例子**：
```c
return;  // 这行代码可以匹配两个规则：
```

- 规则1：`RETURN SEMICOLON { ReturnStmt None }`  ✓ 正确
- 规则2：`expr SEMICOLON { ExprStmt $1 }`       ✗ 冲突（如果 return 被当作表达式）

**解决**：将 `expr SEMICOLON` 移到所有具体语句规则之后，作为兜底规则。

**正确的规则顺序**：
```ocaml
stmt:
  | RETURN SEMICOLON { ReturnStmt None }  (* 具体规则优先 *)
  | IDENTIFIER ASSIGN expr SEMICOLON { Assignment ($1, $3) }
  | expr SEMICOLON { ExprStmt $1 }        (* 宽泛规则放最后 *)
```

**总结**：语法分析器按规则顺序匹配，**具体规则必须在通用规则之前**，否则通用规则会"吞掉"本应由具体规则处理的输入。