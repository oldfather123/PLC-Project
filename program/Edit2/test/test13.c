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
    // while (n > 1) {
    //     n = n - 1;
    //     if (n == 3) {
    //         n = 0;
    //         continue;
    //     }
    // }
    return n;
}
int main () {
    int result = control_structures(5);
    result = result + 1;
    return result;
}