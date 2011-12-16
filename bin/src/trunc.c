#include <stdio.h>

main(
int	argc,
char	*argv[])
{
	long	to;
	char	*p;
	int	i;
	int	rc = 0;

	to = strtoul(argv[1], &p, 0);

	for (i = 2; i < argc; i++)
	{
		if (truncate(argv[i], to) != 0)
		{
			fprintf(stderr, "trunc: cannot trunc: %s", argv[i]);
			perror(" ");
			rc = 1;
		}
	}

	exit(rc);
}
