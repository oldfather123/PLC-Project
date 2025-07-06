int func(int i, int sum) {
    int y = 8;
    // 外层循环
    while(i < 10) {
        i = i + 1;
        if(i == 3) {
            continue;
        }
        if(i == y) {
            break;
        }
        sum = sum + i;
    }
    return sum;  // 预期结果：1 + 2 + 4 + 5 + 6 + 7 = 25
}
int main() {
    int i = 0;
    int sum = 0;
    int result = func (i, sum);
    return result;  // 应该返回25
}
// int main() {
//     int x = 1;        // x_Control_1_main (函数作用域)
//     {
//         int x = 2;    // x_Block_2_main  (嵌套块)
//         if (x > 0) {
//             int y = 3;  // y_Control_1_main (控制结构)
//         }
//     }
//     return x;
// }