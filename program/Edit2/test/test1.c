// 测试基本函数定义、变量声明、赋值
int add(int x, int y) {
    return x + y;
}

void simple() {
    int a = 5;
    int b = 10;
    a = b;
    b = a + b;
}

int no_params() {
    return 42;
}

void no_params_void() {
    int x = 1;
}

int main() {
    int x = 1;
    int y = 2;
    int z = add(x, y);  // 调用 add 函数
    simple();           // 调用 simple 函数
    int result = no_params() + z;  // 调用无参数函数
    no_params_void();  // 调用无参数 void 函数
    return result;     // 返回结果
}