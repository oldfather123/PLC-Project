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

/*
# function return_immediate
return 42

# function return_void
return

# function conditional_return
t0 = x_0 > 0
if t0 goto L0
t1 = x_0 - 1
return t1
L0:
t2 = x_0 + 1
return t2

# function multiple_returns
t3 = n_0 < 0
if t3 goto L1
t4 = n_0 == 0
if t4 goto L2
L3:
t5 = n_0 > 10
if t5 == 0 goto L4
t6 = n_0 > 100
if t6 goto L5
n_1 = n_0 - 1
n_0 = n_1
goto L3
L4:
return n_0
L5:
return 100
L2:
return 0
L1:
return -1

# function early_return
t7 = flag_0
if t7 goto L6
x_0 = 10
x_1 = x_0 + 1
L6:
return
*/