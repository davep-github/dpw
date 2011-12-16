#include <stdio.h>

main(
    int	    argc,
    char*   argv[])
{
    int	i = 0;
    const char* open_del = ">";
    const char* close_del = "<";

    if (argc > 1 && strcmp(argv[1], "-d") == 0) {
        open_del = "";
        close_del = "";
        i = 2;
    }

    for (i; i < argc; i++) {
        if (open_del[0] != '\0')
            printf("%d", i);
	printf("%s%s%s\n", open_del, argv[i], close_del);
    }

    return (argc);
}
