// 测试所有运算符和表达式
int expression_test() {
    // 算术运算
    int a = 1 + 2 * 3 / 4 - 5 % 2;
    
    // 关系运算
    int b = a < 10;
    int c = a > 5;
    int d = a <= 15;
    int e = a >= 0;
    int f = a == 7;
    int g = a != 8;
    
    // 逻辑运算
    int h = b && c;
    int i = d || e;
    int j = !f;
    
    // 一元运算
    int k = +a;
    int l = -b;
    int m = !g;
    
    // 复杂表达式
    int result = (a + b) * (c - d) / (e + f);
    
    return result;
}
