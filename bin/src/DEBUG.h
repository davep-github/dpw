// -*- mode: C++; c-file-style: "skaion-c-style" -*-
#include <cstdio>

#ifdef DEBUG_ON
#define DEBUG printf
#else
#define DEBUG 0 &&
#endif

int main(
    int argc,
    char* argv[])
{
    DEBUG("%s%s %s\n", "Hello", ",", "world.");

    return 0;
}
