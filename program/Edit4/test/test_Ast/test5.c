// 测试语句块和嵌套
void nested_blocks() {
    int a = 1;
    {
        int b = 2;
        {
            int c = 3;
            a = b + c;
        }
        a = a + b;
    }
    
    if (a > 0) {
        {
            int x = a;
            while (x > 0) {
                {
                    int y = x;
                    x = y - 1;
                }
            }
        }
    }
}

void empty_blocks() {
    {
    }
    
    if (1) {
    }
    
    while (0) {
    }
}