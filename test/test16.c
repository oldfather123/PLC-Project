int is_prime(int n)
{
    if (n <= 1)
    {
        return 0;
    }
    if (n <= 3)
    {
        return 1;
    }
    if (n % 2 == 0 || n % 3 == 0)
    {
        return 0;
    }

    int i = 5;
    while (i * i <= n)
    {
        if (n % i == 0 || n % (i + 2) == 0)
        {
            return 0;
        }
        i = i + 6;
    }
    return 1;
}

int main() {
    int n1 = 12603;
    int n2 = 32569;
    int n3 = 30883;

    int expr7 = 0;
    if (is_prime(n1)) {
        if (is_prime(n2)) {
            expr7 = n1 * n2;
        } else if (is_prime(n3)) {
            expr7 = n1 * n3;
        } else {
            expr7 = n1;
        }
    } else if (is_prime(n2)) {
        if (is_prime(n3)) {
            expr7 = n2 * n3;
        } else {
            expr7 = n2;
        }
    } else if (is_prime(n3)) {
        expr7 = n3;
    } else {
        expr7 = n1 + n2 + n3;
    }

    return expr7;
}