#include <stdio.h>

main(
int	argc,
char	*argv[])
{
	int	i;

	if (argc < 2)
	{
		fprintf(stderr, "utime: usage: utime file...\n");
		exit (1);
	}

	for (i = 1; i < argc; i++)
	{
		if (utime(argv[i], NULL))
		{
			fprintf(stderr, "utime: utime() failed on %s", argv[i]);
			perror(" ");
		}
	}

	exit(0);
}
