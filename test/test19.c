int main() {
    int x = 1;
    {
        int x = 2;  // 遮蔽外层的x
        {
            int x = 3;  // 遮蔽中层的x
            x = x + 1;  // 应该操作最内层的x
        }
        x = x + 2;  // 应该操作中层的x
    }
    return x;  // 应该返回外层的x，值为1
}