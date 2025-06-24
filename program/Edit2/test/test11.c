int gcd(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}
int multiply(int a, int b) {
    return a * b;
}

int loop_with_break_continue( int i) {
    while (i < 10) {
        i = i + 1;
        if (i == 3) {
            continue;
        }
        if (i == 8) {
            break;
        }
    }
	return i;
}

int factorial(int n) {
    if (n <= 1) {
        return 1;
    } else {
        return multiply(n, factorial(n - 1));
    }
}

int is_prime(int n) {
    if (n <= 1) {
        return 0;
    }
    
    if (n <= 3) {
        return 1;
    }
    
    if (n % 2 == 0) {
        return 0;
    }
    
    int i = 3;
    while (i * i <= n) {
        if (n % i == 0) {
            return 0;
        }
        i = i + 2;
    }
    
    return 1;
}

int main() {
	int x=gcd(10,25);
	int y = loop_with_break_continue(x);
	y=y/2;
	int z = factorial(y);
	x = z - 7;
	z = is_prime(x);
	return z;
}