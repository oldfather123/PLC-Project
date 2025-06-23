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