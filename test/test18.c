int main() {
    int i = 0;
    int sum = 0;
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