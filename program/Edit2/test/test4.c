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

/*
# function multiply
return a * b

# function factorial
t1 = n_0 <= 1
if t1 goto L0
t2 = n_0 - 1
t3 = call factorial, 1
t4 = call multiply, 2
return t4
L0:
return 1

# function test_calls
return 120

# function complex_call_chain
return 72
*/