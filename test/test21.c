int factorial(int n) {
    if (n <= 1) {
        return 1; // 基本情况：n <= 1 时返回 1
    }
    return n * factorial(n - 1); // 递归调用
}

int main() {
    int num = 5; // 测试输入
    int result = factorial(num);
    return result;
}