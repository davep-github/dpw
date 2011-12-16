#include <stdio.h>

#define _BSD_SOURCE
#include <time.h>

main(
int	argc,
char	*argv[])
{
	time_t	tim;
	int		i;
	char		*p;

	for (i = 1; i < argc; i++)
	{
		tim = strtoul(argv[i], &p, 0);

		printf("%s", ctime(&tim));
	}

	exit(0);
}
