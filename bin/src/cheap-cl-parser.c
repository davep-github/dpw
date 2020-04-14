#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <err.h>

const char* ECHO_CMD = "./ech0 ";
int
cheap_cl_parse(
    const char* s,
    int* argcp,
    char*** argvp)
{
    char results[2048];
    size_t cmd_len = strlen(s) + strlen(ECHO_CMD) + 1;
    char* command = (char*)malloc(cmd_len);
    strncpy(command, ECHO_CMD, cmd_len);
    strncat(command, s, cmd_len - strlen(command));
    // Run the ech0 command on our string.
    FILE* popFILE = popen(command, "r");
    int popfd = fileno(popFILE);

    char* p = results;
    ssize_t nread;
    ssize_t totalRead = 0;
    ssize_t maxToRead = sizeof(results); // Could just use sizeof(results)
    while((nread = read(popfd, p, maxToRead)) > 0) {
        totalRead += nread;
        maxToRead -= nread;
        p += nread;
    }
    if (nread < 0) {
        return nread;
    }

    // Parse the easily pars-able results.
    // It looks like this:
    // <ascii_num_args>\0<argv[0]>\0<argv[1]\0... <argv[ascii_num_args-1]\0
    int numArgs;
    sscanf(results, "%d", &numArgs);
    // Allocate an argv
    char** localArgv;
    localArgv = (char**)malloc(numArgs * sizeof(localArgv[0]));
    // Move past the ascii_num_args and its \0
    p = results + strlen(results) + 1;
    int i;
    for (i=0; i < numArgs; ++i) {
        localArgv[i] = strdup(p);
        // past the arg and its \0
        p += strlen(p) + 1;
    }

    *argcp = numArgs;
    *argvp = localArgv;

    return 0;
}

#if defined(TEST_MODE) && TEST_MODE
int
main(
    int arg,
    const char* argv[])
{
    int nargc;
    char** nargv;
    int i;

    char buf[2048];

    fprintf(stderr, "Enter command line> ");
    while (fgets(buf, sizeof(buf), stdin) != NULL) {
        fflush(stderr);         /* Not strictly necessary. */
        buf[strlen(buf)-1] = '\0';
        printf("buf>%s<\n", buf);
        if (cheap_cl_parse(buf, &nargc, &nargv)) {
            err(1, " failed: ");
        }
        printf("nargc: %d\n", nargc);
        for (i = 0; i < nargc; ++i) {
            printf("%d>%s<\n", i, nargv[i]);
        }
        fprintf(stderr, "Enter command line> ");
    }
}
#endif
