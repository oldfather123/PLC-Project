## Edit3：实现解释器
#### 将测试模块从main.ml中抽离出来，在test中组织不同的测试模块，`ast_test.ml`和`interpreter_test.ml`分别用于测试分析器和解释器，并用测试运行器统一管理，测试运行命令如下
```bash
    # 运行所有AST测试
    dune exec Edit3 test ast

    # 运行所有解释器测试  
    dune exec Edit3 test interp

    # 运行所有测试
    dune exec Edit3 test all

    # 测试单个文件（AST）
    dune exec Edit3 parse test/test_Ast/test1.c

    # 执行单个文件 (Interp)
    dune exec Edit3 run test/test_Interp/test1.c
```