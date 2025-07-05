int func1() {
    return 1;
}

int func2() {
    return 0;
}

int main() {
    int x = 0;
    
    // 测试 && 短路
    if (func2() && func1()) {  // func2返回0，应该短路，不执行func1
        x = 1;
    }
    
    // 测试 || 短路
    if (func1() || func2()) {  // func1返回1，应该短路，不执行func2
        x = 2;
    }
    
    return x;  // 应该返回2
}