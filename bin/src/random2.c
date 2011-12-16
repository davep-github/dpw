#include <stdio.h>
#include <stdlib.h>

#include "types.h"
#if !defined(ENV_OS_AIX)
typedef unsigned int uint;
#endif
extern char *setstate();

Usage()
{
	fprintf(stderr, "usage: rand [-s seed] -r range states... \n");
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
	uint	range = (uint)-1;
	ulong	tmp;
	int	numStates = 0;
	long	stateBuf[265 / sizeof (long)];
	long	stateBuf2[265 / sizeof (long)];
   char  *states = (char *)stateBuf;
	char	*states2 = (char *)stateBuf2;
	int	i;

   extern int  optind;
   extern int  opterr;
   extern char *optarg;

   opterr = 1;

	while ((opt = getopt(argc, argv, "s:r:")) != EOF)
	{
		switch (opt)
		{
			case 's':
				seed = strtoul(optarg, &p, 0);
				seedSet = 1;
				break;
			
			case 'r':
				range = strtoul(optarg, &p, 0);
				break;

			default:
				Usage();
		}
	}

	if (optind >= argc)
		Usage();

	if (!seedSet)
		seed = strtoul(argv[optind++], &p, 0);

	for (; optind < argc && numStates < 256; optind++, numStates++)
		states[numStates] = strtol(argv[optind], &p, 0);

	if (numStates < 8 || numStates > 256)
	{
		fprintf(stderr, "random: numStates must be 8... 256, NOT: %d\n",
         numStates);
		exit(1);
	}

	if (!seedSet)
		numStates >>= 1;

	memcpy(states2, states, numStates);

	initstate(seed, states, numStates);
	if (!seedSet)
		setstate(states + numStates);

	for (i = 0; i < 10; i++)
	{
		tmp = random();
		printf("tmp: %u, range: %u", tmp, range);
		printf(", out: %u\n", tmp % range);
	}

	for (i = 0; i < numStates; i++)
		printf(" %u", states2[i]);

	p = setstate(states);

	do
	{
		printf(" %u", *p++ & 0xff);
	}
	while (--numStates);

}
	
