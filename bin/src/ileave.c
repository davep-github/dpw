#include <stdio.h>
#include <errno.h>

char	*Prog = "ileave";

main(
int	argc,
char	*argv[])
{
	FILE	**fps;
	int	*eofs;
	int	numActiveFiles;
	int	i;
	char	line[1024];

	if ((fps = (FILE **)malloc(argc * sizeof (FILE *))) == NULL)
	{
		fprintf(stderr, "%s: cannot malloc() fds.\n", Prog);
		exit(1);
	}

	if ((eofs = (int *)malloc(argc * sizeof (int))) == NULL)
	{
		fprintf(stderr, "%s: cannot malloc() eofs.\n", Prog);
		exit(1);
	}

	for (i = 0; i < argc - 1; i++)
	{
		if ((fps[i] = fopen(argv[i + 1], "r")) == NULL)
		{
			fprintf(stderr, "%s: cannot open %s", Prog, argv[i + 1]);
			perror(" ");
			exit(2);
		}

		eofs[i] = 0;
	}

	numActiveFiles = argc - 1;

	while (numActiveFiles)
	{
		for (i = 0; i < argc - 1; i ++)
		{
			if (eofs[i])
				continue;

			if (fgets(line, sizeof(line) - 2, fps[i]) == NULL)
			{
				if (errno != 0)
				{
					fprintf(stderr, "%s: error reading %s", Prog, argv[i + 1]);
					perror(" ");
					exit(3);
				}

				eofs[i] = 1;
				numActiveFiles--;
				fclose(fps[i]);
			}
			else
				printf("%s", line);
		}
	}	

	exit(0);
}

