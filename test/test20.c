int factorial(int n)
{
    int result = 1;
    while (n > 0)
    {
        result = result * n;
        n = n - 1;
    }
    return result;
}

// 计算组合数 C(n,k)
int combination(int n, int k)
{
    if (k > n)
    {
        return 0;
    }
    if (k == 0 || k == n)
    {
        return 1;
    }

    // 使用公式 C(n,k) = n!/(k!*(n-k)!)
    return factorial(n) / (factorial(k) * factorial(n - k));
}
int main()
{
    int result = 0;
    // int fib = fibonacci(12);
    // int gcd_result = gcd(22, 15);
    // int prime_check = isPrime(17);
    int fact = factorial(8);
    int comb = combination(7, 3);
    // int pow_result = power(3, 11);
    // int complex_result = complexFunction(3, 5, 1);
    // int short_circuit = shortCircuit(-5, 10);
    // int nested_loops_conds_result = nestedLoopsAndConditions(10);
    // int nested_calls_result = nestedCalls(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    return (fact + comb) % 256;
}