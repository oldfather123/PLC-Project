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

/*
# function gcd
L0:
t0 = b_0 != 0
if t0 == 0 goto L1
t1 = b_0
t2 = a_0 % b_0
b_0 = t2
a_0 = t1
goto L0
L1:
return a_0

# function multiply
return a * b

# function loop_with_break_continue
L2:
t4 = i_0 < 10
if t4 == 0 goto L3
i_0 = i_0 + 1
t5 = i_0 == 3
if t5 goto L2
t6 = i_0 == 8
if t6 goto L3
goto L2
L3:
return i_0

# function factorial
t7 = n_0 <= 1
if t7 goto L4
t8 = n_0 - 1
t9 = call factorial, 1
t10 = call multiply, 2
return t10
L4:
return 1

# function is_prime
t11 = n_0 <= 1
if t11 goto L5
t12 = n_0 <= 3
if t12 goto L6
t13 = n_0 % 2
if t13 == 0 goto L7
i_0 = 3
L8:
t14 = i_0 * i_0
t15 = t14 <= n_0
if t15 == 0 goto L9
t16 = n_0 % i_0
if t16 == 0 goto L7
i_0 = i_0 + 2
goto L8
L9:
return 1
L7:
return 0
L6:
return 1
L5:
return 0

# function main
t17 = call gcd, 2
t18 = call loop_with_break_continue, 1
t19 = t18 / 2
t20 = call factorial, 1
t21 = t20 - 7
t22 = call is_prime, 1
return t22
*/