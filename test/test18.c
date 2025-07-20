int factorial(int n)
{
    if (n <= 1)
    {
        return 1;
    }
    else if (n == 2) {
        return 2;
    }
    return n * factorial(n - 1);
}
int main () {
    int x = 2;
    int z = factorial(x);
    return z;
}