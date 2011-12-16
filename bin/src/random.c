#include <stdio.h>
#include <stdlib.h>

extern char *setstate();

Usage()
{
	fprintf(stderr, 
           "usage: random [-s seed] -r range states... \n"
           " Generate a random number 0.. range-1, given the input states.\n"
           " Prints the random number to the stdout followed by state\n"
           " information sufficient to continue generating numbers in\n"
           " the sequence.  Pass the state information to successive\n"
           " invocations of this program.\n");
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
	unsigned int	range = (unsigned int)-1;
	unsigned long	tmp;
	int	numStates = 0;
	long	stateBuf[265 / sizeof (long)];
	long	stateBuf2[265 / sizeof (long)];
   char  *states = (char *)stateBuf;
	char	*states2 = (char *)stateBuf2;
	int	i;

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
   {
		states[numStates] = strtol(argv[optind], &p, 0);
      printf("states[%d]: %d, optind: %d\n", 
             numStates,
             states[numStates],
             optind);
   }
   
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

	tmp = random();
	printf("%u %u", tmp % range, seed);

	for (i = 0; i < numStates; i++)
		printf(" %u", states2[i]);

	p = setstate(states);

	do
	{
		printf(" %u", *p++ & 0xff);
	}
	while (--numStates);

}
	
