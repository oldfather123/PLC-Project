int func (int a) {
    if (a > 5) {
        a = a + 1;
    }
    else {
        a = a - 1;
    }
    int b = 0;
    int c = 0;
    while (b < a){
        b = b + 1;
        if (b == 3){
            continue;
        }
        c = c + 1;
    }
    return c;
}
int main () {
    int a = 6;
    int b = func(a);
    return b;
}