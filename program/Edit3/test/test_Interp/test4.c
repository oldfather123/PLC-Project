int add(int a, int b) {
    return a + b;
}

int factorial(int n) {
    if (n <= 1) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

int main() {
    int result1 = add(5, 3);
    putint(result1);  // Should print 8
    
    int result2 = factorial(5);
    putint(result2);  // Should print 120
    
    return 0;
}