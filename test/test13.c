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
    while (n > 1) {
        n = n - 1;
        if (n == 3) {
            n = 0;
            continue;
        }
    }
    return n;
}
int main () {
    int result = control_structures(5);
    result = result + 1;
    return result;
}

/*
# function control_structures
t0 = n > 0
if t0 goto L1
    t1 = n
    goto L2
L1:
    t1 = n + 1
L2:
t2 = t1 < 10
if t2 goto L3
    t3 = t1 / 2
    goto L4
L3:
    t3 = t1 * 2
L4:
t4 = t3 > 5
if t4 goto L5
    t5 = t3
    goto L8
L5:
t6 = t3 < 20
if t6 goto L6
    t7 = t3 - 5
    goto L7
L6:
    t7 = t3 + 5
L7:
    t5 = t7
L8:
return t5

# function main
return 17
*/