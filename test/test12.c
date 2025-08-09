int func (int a) {
    int b = a;          // 复制传播: b = 3
    int c = b + 4;      // 常量传播: c = 3 + 4 -> c = 7
    c = c + 4;          // 常量传播: c = 7 + 4 -> c = 11
    int d = c;          // 复制传播: d = 11
    int e = d * 2;      // 常量传播: e = 11 * 2 -> e = 22
    int f = 100;        // 死代码消除: f 未被使用，应被删除
    int g = e;          // 复制传播: g = 22
    return g;
}
int main() {
    int a = 1 + 2;      // 常量折叠: a = 3
    int g = func(a);
    return g;           // 只用到了 g
}

/*
# function func
return 2 * (a + 4)

# function main
return 14
*/