int main() {
    int x = 15;
    int y = 10;
    
    if (x > y) {
        putint(1);  // Should print 1
    } else {
        putint(0);
    }
    
    if (x == y) {
        putint(100);
    } else {
        putint(200); // Should print 200
    }
    
    if (x <= 10) {
        putint(300);
    } else {
        putint(400); // Should print 400
    }
    
    return 0;
}