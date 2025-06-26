// 测试复杂的表达式组合
int complex_expressions() {
    // 测试运算符优先级
    int a = 1 + 2 * 3;  // 应该是 7，不是 9
    int b = (1 + 2) * 3;  // 应该是 9
    
    // 测试逻辑运算符优先级
    int c = 1 || 0 && 0;  // 应该是 1
    int d = (1 || 0) && 0;  // 应该是 0
    
    // 测试关系运算符
    int e = 1 < 2 && 3 > 2;  // 应该是 1
    int f = 1 > 2 || 3 < 4;  // 应该是 1
    
    // 测试一元运算符
    int g = !0;  // 应该是 1
    int h = !!1;  // 应该是 1
    int i = -(-5);  // 应该是 5
    
    return a + b + c + d + e + f + g + h + i;
}

int deeply_nested() {
    return ((1 + 2) * (3 + 4)) - ((5 - 2) * (8 / 2));
}

/*
# function complex_expressions
return 26

# function deeply_nested
return 9
*/