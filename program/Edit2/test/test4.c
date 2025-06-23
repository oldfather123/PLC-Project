// 测试函数调用
int multiply(int a, int b) {
    return a * b;
}

int factorial(int n) {
    if (n <= 1) {
        return 1;
    } else {
        return multiply(n, factorial(n - 1));
    }
}

void test_calls() {
    int x = multiply(3, 4);
    int y = factorial(5);
    int z = multiply(multiply(2, 3), multiply(4, 5));
}

int complex_call_chain() {
    return multiply(
        multiply(2, 3),
        multiply(factorial(3), multiply(1, 2))
    );
}