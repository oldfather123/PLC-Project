// 测试不同数量的参数
int no_param() {
    return 0;
}

int one_param(int x) {
    return x;
}

int two_params(int x, int y) {
    return x + y;
}

int three_params(int x, int y, int z) {
    return x + y + z;
}

int many_params(int a, int b, int c, int d, int e) {
    return a + b + c + d + e;
}

void call_with_different_params() {
    int a = no_param();
    int b = one_param(5);
    int c = two_params(1, 2);
    int d = three_params(1, 2, 3);
    int e = many_params(1, 2, 3, 4, 5);
}