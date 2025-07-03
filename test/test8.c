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

/*
# function single_statements

# function zero_and_numbers
return 1000123

# function minimal_function
return

# function just_return
return 1

# function complex_control_flow
i_0 = 0
L0:
t0 = i_0 < 10
if t0 == 0 goto L1
t1 = i_0 == 0
if t1 goto L2
t2 = i_0 == 5
if t2 goto L1
t3 = i_0 % 2
if t3 == 0 goto L3
i_0 = i_0 + 2
goto L0
L3:
i_0 = i_0 + 1
goto L0
L2:
i_0 = i_0 + 1
goto L0
L1:
return
*/