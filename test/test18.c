int abs(int x)
{
    if (x < 0)
    {
        return -x;
    }
    else
    {
        return x;
    }
}
int main () {
    int x = -1;
    int z = abs(x);
    return z;
}