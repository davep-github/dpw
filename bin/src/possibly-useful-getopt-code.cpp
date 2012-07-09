// -*- mode: C++; c-file-style: "intel-c-style" -*- 

#include <cstdio>
#include <iostream>
#include <sstream>
#include <string>
#include <string.h>
#include <getopt.h>


bool mono_char_string_p(
    const char* s)
{
    if (!s) {
        return false;
    }
    if (!*s) {
        return true;
    }

    char mono = *s;
    ++s;
    while (*s == mono) {
        ++s;
    }

    return *s == 0;
}

main(
    int argc,
    char* argv[])
{
    int c;
    int option_index = 0;
    static struct option long_options[] = {
        {"n", no_argument, 0, 'n'},
        {"r", required_argument, 0, 'r'},
        {"ixnay", no_argument, 0, 'x'},
        {"yeah", required_argument, 0, 'y'},

        {0, 0, 0, 0}
    };

    bool continue_outer_p = true;
    while (continue_outer_p) {
        while (true) {
            c = getopt_long(argc, argv, "+nr:xy:",
                            long_options, &option_index);
            std::cout << "optind: " << optind << std::endl;
            if (c == -1) {
                break;
            }
            switch (c) {
                case 'n':
                    std::cout << "n, no argument required." << std::endl;
                    break;
                case 'x':
                    std::cout << "x, no argument required." << std::endl;
                    break;

                case 'r':
                    std::cout << "r, argument required>" << optarg << "<"
                              << std::endl;
                    break;

                case 'y':
                    std::cout << "y, argument required>" << optarg << "<"
                              << std::endl;
                    break;

                default:
                    std::cerr << "Unsupported option: " << (char)c << std::endl;
                    break;
            }
        }
        continue_outer_p = false;
        std::cout << "Arguments:" << std::endl;
        for (int i = optind; i < argc; ++i) {
            if (0 == strcmp(argv[i], "--")) {
                std::cout << "== More args coming..." << std::endl;
                // "--" will take the place of argv[0]
                optind = 1;
                argc -= i;
                argv += i;
                continue_outer_p = true;
            }

            int n = i - optind;
            std::cout << "arg[" << n << "]>" << argv[i] << "<" << std::endl;
        }
    }

    return 0;
}

