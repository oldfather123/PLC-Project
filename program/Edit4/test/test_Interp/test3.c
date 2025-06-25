int main() {
    int i = 1;
    int sum = 0;
    
    while (i <= 5) {
        sum = sum + i;
        putint(i);    // Should print 1, 2, 3, 4, 5
        i = i + 1;
    }
    
    putint(sum);      // Should print 15 (1+2+3+4+5)
    
    return 0;
}