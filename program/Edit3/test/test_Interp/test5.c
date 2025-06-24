int main() {
    int a = 1;
    int b = 0;
    int c = 5;
    
    // 逻辑与运算
    if (a && c) {
        putint(1);  // Should print 1
    }
    
    if (b && c) {
        putint(2);
    } else {
        putint(3);  // Should print 3
    }
    
    // 逻辑或运算
    if (a || b) {
        putint(4);  // Should print 4
    }
    
    if (b || 0) {
        putint(5);
    } else {
        putint(6);  // Should print 6
    }
    
    // 逻辑非运算
    if (!b) {
        putint(7);  // Should print 7
    }
    
    if (!a) {
        putint(8);
    } else {
        putint(9);  // Should print 9
    }
    
    return 0;
}