int factorial(int n) {
    int result;
    int i;
    
    if (n <= 1) {
        return 1;
    } else {
        result = 1;
        for (i = 2; i <= n; i++) {
            result = result * i;
        }
        return result;
    }
}

int main() {
    int n = 1;
    int fact;
    
    fact = factorial(n);
    
    while (n > 0) {
        n = n - 1;
    }
    
    return fact;
}