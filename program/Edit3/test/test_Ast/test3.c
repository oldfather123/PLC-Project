// 测试 if-else 和 while 循环
int control_structures(int n) {
    // 简单 if
    if (n > 0) {
        n = n + 1;
    }
    
    // if-else
    if (n < 10) {
        n = n * 2;
    } else {
        n = n / 2;
    }
    
    // 嵌套 if-else (测试 dangling else)
    if (n > 5) {
        if (n < 20) {
            n = n + 5;
        } else {
            n = n - 5;
        }
    }
    
    // while 循环
    while (n > 1) {
        n = n - 1;
    }
    
    return n;
}

void loop_with_break_continue() {
    int i = 0;
    while (i < 10) {
        i = i + 1;
        if (i == 3) {
            continue;
        }
        if (i == 8) {
            break;
        }
    }
}