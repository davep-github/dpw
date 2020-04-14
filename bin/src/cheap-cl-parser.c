#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <err.h>

const char* PARSE_CMD = "ech0 ";
int
cheap_cl_parse(
    const char* s,
    int* argcp,
    char*** argvp,
    const char* parse_cmd)
{
    char results[2048];         /* !<@todo XXX Use Konstant */
    size_t cmd_len = strlen(s) + strlen(PARSE_CMD) + 1;
    char* command = (char*)malloc(cmd_len);
    if (!parse_cmd) {
        parse_cmd = PARSE_CMD;
    }
    strncpy(command, parse_cmd, cmd_len);
    strncat(command, s, cmd_len - strlen(command));
    // Run the ech0 command on our string.
    FILE* pop_FILE = popen(command, "r");
    int popfd = fileno(pop_FILE);

    char* p = results;
    ssize_t nread;
    ssize_t total_read = 0;
    ssize_t max_to_read = sizeof(results);
    while((nread = read(popfd, p, max_to_read)) > 0) {
        total_read += nread;
        max_to_read -= nread;
        p += nread;
    }
    if (nread < 0) {
        return nread;
    }

    // Parse the easily pars-able results.
    // It looks like this:
    // <ascii_num_args>\0<argv[0]>\0<argv[1]\0... <argv[ascii_num_args-1]\0
    int num_args;
    sscanf(results, "%d", &num_args);
    // Allocate an argv
    char** local_argv;
    local_argv = (char**)malloc(num_args * sizeof(local_argv[0]));
    // Move past the ascii_num_args and its \0
    p = results + strlen(results) + 1;
    int i;
    for (i=0; i < num_args; ++i) {
        local_argv[i] = strdup(p);
        // past the arg and its \0
        p += strlen(p) + 1;
    }

    *argcp = num_args;
    *argvp = local_argv;

    return 0;
}

#if defined(TEST_MODE) && TEST_MODE

/*
 * Test and example code.
 */

int
main(
    int arg,
    const char* argv[])
{
    int nargc;
    char** nargv;

    /* !<@todo XXX Use Konstant */
    char buf[2048];

    /* Make first_arg an argument. */
    size_t first_arg = 0;

    fprintf(stderr, "Enter command line> ");
    while (fgets(buf, sizeof(buf), stdin) != NULL) {
        fflush(stderr);         /* Not strictly necessary. */
        buf[strlen(buf)-1] = '\0';
        printf("buf>%s<\n", buf);
        /* !<@todo XXX Make parse_cmd an argument. */
        if (cheap_cl_parse(buf, &nargc, &nargv, NULL)) {
            err(1, " failed: ");
        }
        printf("nargc: %d\n", nargc);

        for (size_t i = first_arg; i < nargc; ++i) {
            printf("%zd>%s<\n", i, nargv[i]);
        }
        fprintf(stderr, "Enter command line> ");
    }
    fprintf(stderr, "Exiting.\n");
}
#endif
