#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

const char* ECHO_CMD = "./ech0 ";
int
cheapParse(
    const char* s,
    int* argcp,
    char*** argvp)
{
    char results[2048];
    size_t cmd_len = strlen(s) + strlen(ECHO_CMD) + 1;
    char* command = malloc(cmd_len);
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

    if (argcp) {
        *argcp = numArgs;
    }
    if (argvp) {
        *argvp = localArgv;
    }
    return 0;
}

void cheapParseCleanup(
    int nargc,
    char** nargv)
{
    for (int i = 0; i < nargc; ++i) {
        free(argv[i]);
    }
    free(nargv);
}

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
        if (cheapParse(buf, &nargc, &nargv)) {
            err("cheapParse failed: ");
            exit(1);
        }
        printf("nargc: %d\n", nargc);
        for (i = 0; i < nargc; ++i) {
            printf("%d>%s<\n", i, nargv[i]);
        }
        cheapParseCleanup(nargc, nargv);
    }
}

