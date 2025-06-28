int func (int x) {
    x = x - 1;
    if (x == 0) {
        x = x - 1;
    }
    else {
        x = x - 2;
    }
}
int main () {
    int x = 5;
    x = func(x);
    return x;
}
// int main () {
//     int x = 5;
//     x = x - 1;
//     if (x == 0) {
//         x = x - 1;
//     }
//     else {
//         x = x - 2;
//     }
//     return x;
// }