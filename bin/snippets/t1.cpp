// -*- mode: C++; c-file-style: "nvidia-c-style" -*-
#include <cstdio>
#include <iostream>
#include <iomanip>

#include "hexl.h"

int
main(
    int argc,
    char* argv[])
{
    for (int i = 1; i < argc; ++i) {
        long l = strtoul(argv[i], NULL, 0);
        int ii = l;
        char c = l;

#if 0                           /* 2014-06-06T19:29:04 by: dpanariti */
        std::cout << std::showbase
                  << std::setiosflags(std::ios::internal)
                  << std::setfill('0')
                  << std::setw(8)
                  << std::hex
                  << 10
                  << std::endl;
        std::cout << "l: "
                  << std::showbase
                  << std::setw(8)
                  << std::hex
                  << std::setfill('0')
                  << l
                  << std::endl;
#endif                    /* #if 0 */ /* 2014-06-06T19:29:04 by: dpanariti */
        
        std::cout << "l in original base: " << l
                  << " == in hex: "
                  << hexl(l)
                  << ", in original base: "
                  << l
                  << std::endl;
        std::cout << "ii in original base: " << ii
                  << " == in hex: "
                  << hexl(ii)
                  << ", in original base: "
                  << ii
                  << std::endl;
        std::cout << "c in original base: " << c
                  << " == in hex: "
                  << hexl(c)
                  << ", in original base: "
                  << c
                  << std::endl;
    }
}

