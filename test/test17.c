// int main () {
//     int x = 5;
//     while (x != 0) {
//         x = x - 1;
//     }
//     int y = 3;
//     x = y;
//     return x;
// }
int func (int a, int b, int c) {
    if (a == 1) {
       a = 2; 
    }
    a = c + 1;
    b = b + a;
    return b;
}
int main () {
    int a = 1;
    int b = 2;
    int c = 3;
    b = func (a, b, c);
    return b;
}