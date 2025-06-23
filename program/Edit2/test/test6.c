// 测试各种 return 语句
int return_immediate() {
    return 42;
}

void return_void() {
    return;
}

int conditional_return(int x) {
    if (x > 0) {
        return x + 1;
    } else {
        return x - 1;
    }
}

int multiple_returns(int n) {
    if (n < 0) {
        return -1;
    }
    
    if (n == 0) {
        return 0;
    }
    
    while (n > 10) {
        if (n > 100) {
            return 100;
        }
        n = n - 1;
    }
    
    return n;
}

void early_return(int flag) {
    if (flag) {
        return;
    }
    
    int x = 10;
    x = x + 1;
}