// int func(int i, int sum) {
//     int y = 8;
//     // 外层循环
//     while(i < 10) {
//         i = i + 1;
//         if(i == 3) {
//             continue;
//         }
//         if(i == y) {
//             break;
//         }
//         sum = sum + i;
//     }
//     return sum;  // 预期结果：1 + 2 + 4 + 5 + 6 + 7 = 25
// }
// int main() {
//     int i = 0;
//     int sum = 0;
//     int result = func (i, sum);
//     return result;  // 应该返回25
// }
int process(int x, int y) {
    int sum = 0;
    int i = 0;
    
    // 外层循环
    while (i < 100) {
        i = i + 1;
        
        // 跳过小于x的数
        if (i < x) {
            continue;
        }
        
        // 判断是否需要break
        if (i > y) {
            break;
        }

        // 嵌套的if-else结构
        if (i % 3 == 0) {
            if (i % 2 == 0) {
                sum = sum + i * 2;
            } else {
                sum = sum + i;
            }
        } else if (i % 5 == 0) {
            sum = sum + i * 3;
        } else {
            // 内层循环
            int j = 0;
            while (j < i) {
                if (j % 2 == 0) {
                    sum = sum + 1;
                }
                if (j > 10) {
                    break;
                }
                j = j + 1;
            }
        }
    }
    return sum;
}

int main() {
    int result1 = process(5, 20);   // 从5到20的特殊求和
    int result2 = process(10, 30);  // 从10到30的特殊求和
    return result1 + result2; //707
}