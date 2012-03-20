#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

// ECH<zero>. My current font sucks.


#if defined(COMPILING_AS_ECH0) && COMPILING_AS_ECH0
#include <stdio.h>
#include <string.h>
#include <unistd.h>

/*
 * Print argv, preceded by argc in ascii and with a '\000' after each argv[i]
 * By running this, the args come out as one line. This is easy to parse.
 * By shelling args to this, we get the shell to parse the args for free.
 * In the example, everything is ASCII e.g. except the \0
 * 4\0progname is irrelevant\0I am arg 1\0This is arg2\0Last arg am I\0
 */

//static const int STDOUT_FILENO = 1;

int
main(
    int argc,
    const char* argv[])
{
    int i;
    char ascii_num_args[16];

    snprintf(ascii_num_args, sizeof(ascii_num_args)-1, "%d", argc);
    //fprintf(stderr, "%d\n", argc);
    write(STDOUT_FILENO, ascii_num_args, strlen(ascii_num_args)+1);
    for (i=0; i < argc; ++i) {
        //fprintf(stderr, ">%s<\n", argv[i]);
        write(STDOUT_FILENO, argv[i], strlen(argv[i])+1);
    }

    return 0;
}

#else

#include "divers.h"

static const char* ECHO_CMD = "./ech0 ";

/*********************************************************************/
/*!
 * @brief Parse a command line by using the shell.
 *
 * Everything is allocated and can be changed freely.
 * 
 */
int
cheap_parse(
    const char* s,
    int* argcp,
    char*** argvp)
{
    const char* echo_cmd;
    if ((echo_cmd = getenv("CP_ECHO_CMD"))) {
        ECHO_CMD = echo_cmd;
    }

    char results[2048];
    size_t cmd_len = strlen(s) + strlen(ECHO_CMD) + 1;
    char* command = new char[cmd_len];
    strncpy(command, ECHO_CMD, cmd_len);
    strncat(command, s, cmd_len - strlen(command));
    // Run the ech0 command on our string.
    FILE* pop_fILE = popen(command, "r");
    int popfd = fileno(pop_fILE);
    delete [] command;

    char* p = results;
    ssize_t nread;
    ssize_t total_read = 0;
    ssize_t max_to_read = sizeof(results); // Could just use sizeof(results)
    while((nread = read(popfd, p, max_to_read)) > 0) {
        total_read += nread;
        max_to_read -= nread;
        p += nread;
    }
    if (nread < 0) {
        return nread;
    }

    // Parse the generated to be easy to parse results.
    // It looks like this:
    // <ascii_num_args>\0<argv[0]>\0<argv[1]\0... <argv[ascii_num_args-1]\0
    int num_args;
    sscanf(results, "%d", &num_args);
    // Allocate an argv
    char** local_argv;
    local_argv = new char* [num_args];
    // Move past the ascii_num_args and its \0
    p = results + strlen(results) + 1;
    int i;
    for (i=0; i < num_args; ++i) {
        local_argv[i] = cpp_strdup(p);
        // past the arg and its \0
        p += strlen(p) + 1;
    }

    *argcp = num_args;
    *argvp = local_argv;

    return 0;
}

#endif

#ifdef CHEAP_PARSER_TEST
int
main(
    int arg,
    const char* argv[])
{
    int nargc;
    char** nargv;
    int i;

    char buf[2048];

    while (fgets(buf, sizeof(buf), stdin) != NULL) {
        buf[strlen(buf)-1] = '\0';
        printf("buf>%s<\n", buf);
        if (cheap_parse(buf, &nargc, &nargv)) {
            err("cheap_parse failed: ");
            exit(1);
        }
        printf("nargc: %d\n", nargc);
        for (i = 0; i < nargc; ++i) {
            printf("%d>%s<\n", i, nargv[i]);
        }
    }
}
#endif

