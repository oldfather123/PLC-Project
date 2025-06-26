int func (int a) {
    int b = a;          // 复制传播: b = 3
    int c = b + 4;      // 常量传播: c = 3 + 4 -> c = 7
    int d = c;          // 复制传播: d = 7
    int e = d * 2;      // 常量传播: e = 7 * 2 -> e = 14
    int f = 100;        // 死代码消除: f 未被使用，应被删除
    int g = e;          // 复制传播: g = 14
    return g;
}
int main() {
    int a = 1 + 2;      // 常量折叠: a = 3
    int g = func(a);
    return g;           // 只用到了 g
}