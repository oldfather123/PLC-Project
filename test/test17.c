// int main () {
//     int x = 5;
//     while (x != 0) {
//         x = x - 1;
//     }
//     int y = 3;
//     x = y;
//     return x;
// }
int func () {
    int sum = 0;
    int i = 1;
    while (i <= 16) {
        if (i % 3 == 0) {
            sum = sum + i * i;
        }
        else if (i % 4 == 0) {
            sum = sum + i * i * i;
        }
        else {
            sum = sum + i;
        }
        i = i + 1;
    }
    int expr6 = 0;
    i = 1;
    while (i <= 7) {
        int j = 1;
        int term = 1;
        while (j <= i) {
            term = term * j;
            j = j + 1;
        }
        expr6 = expr6 + term;
        i = i + 1;
    }
    return expr6;
}
int main () {
    int b = func ();
    return b;
}