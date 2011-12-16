#include <stdio.h>
#include <stdlib.h>

Usage()
{
	fprintf(stderr, "usage: rand [-s seed] maxPlusOne\n");
	exit(1);
}

main(
int	argc,
char	*argv[])
{
	int	opt;
	char	*p;
	int	seed = 0;
	int	seedSet = 0;
	uint	maxPlusOne = 1;
	ulong	tmp;

	while ((opt = getopt(argc, argv, "s:")) != EOF)
	{
		switch (opt)
		{
			case 's':
				seed = strtoul(optarg, &p, 0);
				seedSet = 1;
				break;

			default:
				Usage();
		}
	}

	if (optind >= argc)
		Usage();

	srand(seed);

	maxPlusOne = strtoul(argv[optind], &p, 0);

	tmp = (ulong)rand() * (ulong)rand();
	printf("%u", tmp % maxPlusOne);

	exit(0);
}
	
