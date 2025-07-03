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

/*
# function no_param
return 0

# function one_param
return x

# function two_params
return x + y

# function three_params
return x + y + z

# function many_params
return a + b + c + d + e

# function call_with_different_params
t8 = call no_param, 0
t9 = call one_param, 1
t10 = call two_params, 2
t11 = call three_params, 3
t12 = call many_params, 5
*/