BEGIN { sum=0
}
{
    sum = strtonum($1) + sum
}
END { printf("%d\n", sum)
}

