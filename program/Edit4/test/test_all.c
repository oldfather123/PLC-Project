// 综合测试 ToyC 语言的所有语法特性
// 包括：函数定义、变量声明、算术运算、逻辑运算、控制流、函数调用等

// 测试基本算术运算的函数
int arithmetic_test(int a, int b) {
    int sum = a + b;
    int diff = a - b;
    int product = a * b;
    int quotient = a / b;
    int remainder = a % b;
    
    // 测试一元运算符
    int neg_a = -a;
    int pos_b = +b;
    
    return sum + diff + product + quotient + remainder + neg_a + pos_b;
}

// 测试比较运算的函数
int comparison_test(int x, int y) {
    int result = 0;
    
    if (x == y) {
        result = result + 1;
    }
    
    if (x != y) {
        result = result + 2;
    }
    
    if (x < y) {
        result = result + 4;
    }
    
    if (x <= y) {
        result = result + 8;
    }
    
    if (x > y) {
        result = result + 16;
    }
    
    if (x >= y) {
        result = result + 32;
    }
    
    return result;
}

// 测试逻辑运算（短路求值）
int logical_test(int a, int b) {
    int result = 0;
    
    // 测试逻辑与（短路求值）
    if (a > 0 && b > 0) {
        result = result + 1;
    }
    
    // 测试逻辑或（短路求值）
    if (a > 10 || b > 10) {
        result = result + 2;
    }
    
    // 测试逻辑非
    if (!a) {
        result = result + 4;
    }
    
    if (!(a && b)) {
        result = result + 8;
    }
    
    return result;
}

// 测试控制流 - if-else 嵌套
int control_flow_test(int value) {
    int result = 0;
    
    if (value > 0) {
        if (value > 10) {
            if (value > 20) {
                result = 3;
            } else {
                result = 2;
            }
        } else {
            result = 1;
        }
    } else {
        if (value < -10) {
            result = -2;
        } else {
            result = -1;
        }
    }
    
    return result;
}

// 测试循环 - while 循环
int loop_test(int n) {
    int sum = 0;
    int i = 1;
    
    while (i <= n) {
        sum = sum + i;
        i = i + 1;
    }
    
    return sum;
}

// 测试 break 和 continue
int break_continue_test(int limit) {
    int sum = 0;
    int i = 0;
    
    while (i < limit) {
        i = i + 1;
        
        // 跳过偶数
        if (i % 2 == 0) {
            continue;
        }
        
        // 大于 10 就退出
        if (i > 10) {
            break;
        }
        
        sum = sum + i;
    }
    
    return sum;
}

// 测试复杂表达式
int complex_expression_test(int a, int b, int c) {
    int result = (a + b) * c - (a - b) / (c + 1);
    int boolean_expr = (a > b && b > c) || (c > a && a != 0);
    
    if (boolean_expr) {
        result = result + 100;
    }
    
    return result;
}

// 测试递归函数 - 计算阶乘
int factorial(int n) {
    if (n <= 1) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

// 测试递归函数 - 斐波那契数列
int fibonacci(int n) {
    if (n <= 0) {
        return 0;
    }
    if (n == 1) {
        return 1;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

// 测试多参数函数
int multi_param_test(int a, int b, int c, int d, int e) {
    return a + b * c - d / e;
}

// 测试无参数函数
int no_param_test() {
    int local_var = 42;
    return local_var * 2;
}

// 测试 void 函数
void void_function_test() {
    int temp = 123;
    temp = temp + 456;
}

// 测试 void 函数带参数
void void_with_params(int x, int y) {
    int result = x + y;
}

// 主函数 - 测试入口
int main() {
    // 测试变量声明和赋值
    int test_var = 10;
    int another_var = 20;
    
    // 重新赋值
    test_var = 15;
    another_var = test_var + 5;
    
    // 测试算术运算
    int arith_result = arithmetic_test(10, 3);
    
    // 测试比较运算
    int comp_result = comparison_test(5, 7);
    
    // 测试逻辑运算
    int logic_result = logical_test(5, 15);
    
    // 测试控制流
    int control_result = control_flow_test(25);
    
    // 测试循环
    int loop_result = loop_test(10);
    
    // 测试 break 和 continue
    int break_cont_result = break_continue_test(20);
    
    // 测试复杂表达式
    int complex_result = complex_expression_test(10, 5, 3);
    
    // 测试递归
    int fact_result = factorial(5);
    int fib_result = fibonacci(7);
    
    // 测试多参数函数
    int multi_result = multi_param_test(1, 2, 3, 4, 1);
    
    // 测试无参数函数
    int no_param_result = no_param_test();
    
    // 测试 void 函数调用
    void_function_test();
    void_with_params(10, 20);
    
    // 测试复杂的嵌套表达式
    int final_result = (arith_result + comp_result) * 
                      (logic_result - control_result) + 
                      loop_result / (break_cont_result + 1);
    
    // 测试条件表达式中的函数调用
    if (factorial(3) == 6 && fibonacci(5) == 5) {
        final_result = final_result + 1000;
    }
    
    // 测试 while 循环中的复杂条件
    int counter = 0;
    while (counter < 3 && final_result > 0) {
        final_result = final_result - 100;
        counter = counter + 1;
        
        if (counter == 2) {
            continue;
        }
        
        if (final_result < 500) {
            break;
        }
    }
    
    // 最终的复杂计算
    int ultimate_result = final_result + 
                         fact_result * fib_result + 
                         multi_result - no_param_result;
    
    return ultimate_result;
}