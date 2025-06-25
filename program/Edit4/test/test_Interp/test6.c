int main() {
    int i = 0;
    
    // 测试 continue
    while (i < 10) {
        i = i + 1;
        if (i == 3 || i == 7) {
            continue;
        }
        if (i > 8) {
            break;
        }
        putint(i);  // Should print 1, 2, 4, 5, 6, 8
    }
    
    putint(999);    // Should print 999
    
    return 0;
}