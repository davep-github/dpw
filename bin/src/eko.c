#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//
// Use environment vars for options so the argv can remain pristine.

main(
    int	    argc,
    char*   argv[])
{
    const char* open_delim = ">";
    const char* close_delim =  "<";
    const char* line_delim = "\n";

    bool num_p = getenv("EKO_NO_NUM") == 0;
    
    if (getenv("EKO_NO_DELIM") || getenv("EKO_BARE")) {
        open_delim = close_delim = "";
        num_p = false;
    } else {
        // Can set to "" --> [0] == '\0' and we get one line for parsing.
        const char* env_line_delim = getenv("EKO_LINE_DELIM");
        line_delim =  env_line_delim ? env_line_delim : "\n";
        if (line_delim == '\0') {
            // What sense does this make?
            open_delim = close_delim = "";
        }
        // Line delim sets open and close to "" for convenience, but we can
        // override that here.
        const char* env_open_delim = getenv("EKO_OPEN_DELIM");
        if (env_open_delim) {
            open_delim = env_open_delim;
        }

        const char* env_close_delim = getenv("EKO_CLOSE_DELIM");
        if (env_close_delim) {
            close_delim = env_close_delim;
        }
    }
    
    int	i = 0;

    // Defecated.
    if (argc > 1 && strcmp(argv[1], "-d") == 0) {
        open_delim = "";
        close_delim = "";
        printf("%s%s%s%s", open_delim, argv[0], close_delim, line_delim);
        i = 2;
    }

    for (i; i < argc; i++) {
        if ((open_delim[0] != '\0') && num_p) {
            printf("%d", i);
        }

	printf("%s%s%s", open_delim, argv[i], close_delim);
        if ((close_delim[0] != '\0') && num_p) {
            printf("%d", i);
        }
        printf("%s", line_delim);
    }

    return (argc);
}
