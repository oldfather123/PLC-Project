// 一个完整的程序示例
int gcd(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

int fibonacci(int n) {
    if (n <= 1) {
        return n;
    }
    
    int a = 0;
    int b = 1;
    int i = 2;
    
    while (i <= n) {
        int temp = a + b;
        a = b;
        b = temp;
        i = i + 1;
    }
    
    return b;
}

int is_prime(int n) {
    if (n <= 1) {
        return 0;
    }
    
    if (n <= 3) {
        return 1;
    }
    
    if (n % 2 == 0) {
        return 0;
    }
    
    int i = 3;
    while (i * i <= n) {
        if (n % i == 0) {
            return 0;
        }
        i = i + 2;
    }
    
    return 1;
}

void main() {
    int a = 48;
    int b = 18;
    int result_gcd = gcd(a, b);
    
    int fib_10 = fibonacci(10);
    
    int prime_check = is_prime(17);
    
    if (prime_check && fib_10 > 50) {
        result_gcd = result_gcd + 1;
    }
}

/*
# function gcd
L0:
t0 = b_0 != 0
if t0 == 0 goto L1
t1 = b_0
t2 = a_0 % b_0
b_0 = t2
a_0 = t1
goto L0
L1:
return a_0

# function fibonacci
t3 = n_0 <= 1
if t3 goto L2
a_0 = 0
b_0 = 1
i_0 = 2
L3:
t4 = i_0 <= n_0
if t4 == 0 goto L4
t5 = a_0 + b_0
a_0 = b_0
b_0 = t5
i_0 = i_0 + 1
goto L3
L4:
return b_0
L2:
return n_0

# function is_prime
t6 = n_0 <= 1
if t6 goto L5
t7 = n_0 <= 3
if t7 goto L6
t8 = n_0 % 2
if t8 == 0 goto L7
i_0 = 3
L8:
t9 = i_0 * i_0
t10 = t9 <= n_0
if t10 == 0 goto L9
t11 = n_0 % i_0
if t11 == 0 goto L7
i_0 = i_0 + 2
goto L8
L9:
return 1
L7:
return 0
L6:
return 1
L5:
return 0

# function main
return gcd(48, 18)
*/