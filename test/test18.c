int factorial(int n)
{
    if (n <= 1)
    {
        return 1;
    }
    return n * factorial(n - 1);
}
int main () {
    int x = 5;
    int z = factorial(x);
    return z;
}