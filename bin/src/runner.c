#include <stdio.h>

/*
 * run a program that exists somewhere in one's PATH.
 * This is intended for running scripts when the
 * interpreter can be in various locations
 * (but always in the path)
 */

main(
    int	argc,
    char	*argv[])
{
    int	i;

    execvp(argv[1], &argv[1]);

    /* we only get here if exec failed. */
    fprintf(stderr, "runner: ");
    for (i = 1; i < argc; i++)
    {
	fprintf(stderr, "%s ", argv[i]);
    }
    perror("failed");
    exit (1);
}
