int sum8(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8)
{
    return a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8;
}
int sum16(int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8, int a9, int a10, int a11, int a12, int a13, int a14, int a15, int a16)
{
    return a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 +
           a9 + a10 + a11 + a12 + a13 + a14 + a15 + a16;
}
int main()
{
    int v1 = 1;
    int v2 = 2;
    int v3 = 3;
    int v4 = 4;
    int v5 = 5;
    int v6 = 6;
    int v7 = 7;
    int v8 = 8;
    int v9 = 9;
    int v10 = 10;
    int v11 = 11;
    int v12 = 12;
    int v13 = 13;
    int v14 = 14;
    int v15 = 15;
    int v16 = 16;
    int result1 = sum8(v1, 1, v3, 2, v5, 3, v7, 4);
    int num = 26;
    // int result2 = sum16(v1, v2, v3, v4, v5, v6, v7, v8,
    //                     1, 2, 3, 4, result1 + v13, result1 + v14, result1 + v15, result1 + v16);
    //  int result2 = sum16(v1, v2, v3, v4, v5, v6, v7, v8,
    //                      1, 2, 3, 4, 26 + v13, 26 + v14, 26 + v15, 26 + v16);
    int result2 = sum16(v1, v2, v3, v4, v5, v6, v7, v8,
                          1, 2, 3, 4, num + v13, num + v14, num + v15, num + v16);
    
    return result2 % 256; // Return the sum of all variables
}