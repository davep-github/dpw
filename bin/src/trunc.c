#include <stdio.h>

main(
    int	argc,
    char	*argv[])
{
    long	to;
    char	*p;
    int	i;
    int	rc = 0;

    if (argc < 3) {
        fprintf(stderr, "Usage: length file [file...]\n");
        return 1;
    }
    
    to = strtoul(argv[1], &p, 0);

    for (i = 2; i < argc; i++)
    {
        if (truncate(argv[i], to) != 0)
        {
            fprintf(stderr, "trunc: cannot trunc: %s", argv[i]);
            perror(" ");
            return 1;
        }
    }

    return rc;
}
