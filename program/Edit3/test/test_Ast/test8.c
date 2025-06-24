// 测试边界情况
void single_statements() {
    ;  // 空语句
    1;  // 表达式语句
    !0;  // 一元表达式语句
}

int zero_and_numbers() {
    int zero = 0;
    int positive = 123;
    int operations = 1000000;
    
    return zero + positive + operations;
}

void minimal_function() {
    return;
}

int just_return() {
    return 1;
}

void complex_control_flow() {
    int i = 0;
    while (i < 10) {
        if (i == 0) {
            i = i + 1;
            continue;
        }
        
        if (i == 5) {
            break;
        }
        
        if (i % 2 == 0) {
            i = i + 1;
        } else {
            i = i + 2;
        }
    }
}