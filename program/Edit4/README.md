## Edit4：实现中间代码生成器（三地址码）
#### 核心模块：`ir_generator.ml`，测试模块：`test_ir.ml`，并用测试运行器统一管理
#### 增加 `interp` 和 `ir_gen` 和三地址码（`TAC`）的说明文档，位于doc目录下
#### 测试运行命令如下
```bash
    # 运行所有 AST 测试
    dune exec Edit4 test ast

    # 运行所有解释器测试  
    dune exec Edit4 test interp

    # 运行所有测试
    dune exec Edit4 test all

    # 测试单个文件（AST）
    dune exec Edit4 parse test/test_Ast/test1.c

    # 执行单个文件 (Interp)
    dune exec Edit4 run test/test_Interp/test1.c

    # 运行所有 IR 测试
    dune exec Edit4 test ir

    # 运行特定 IR 特性测试
    dune exec Edit4 test feature

    # 为单个文件生成三地址码
    dune exec Edit4 ir test/test_Ast/test1.c
```