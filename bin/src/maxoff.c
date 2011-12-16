#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>

main(
int	argc,
char	*argv[])
{
	int	fd;
	int	error;
	off_t	mid;
	off_t	lo;
	off_t	hi;
	char	buf[1];

	if ((fd = open(argv[1], O_TRUNC | O_CREAT, 0666)) == -1)
	{
		perror("opening file");
		exit (1);
	}

	lo = 0;
	hi = 0x7fffffff;

	while ((ulong)lo < (ulong)hi)
	{
		mid = (lo + hi) / 2;
		printf("lo: 0x%08x, hi: 0x%08x, mid: 0x%08x\n", lo, hi, mid);

		error = 0;

		if (lseek(fd, mid, SEEK_SET) == -1)
		{
			fprintf(stderr, "error seeking to 0x%08x\n", mid);
			error = 1;
		}
		else
		{
			if (write(fd, buf, 1) != 1)
			{
				fprintf(stderr, "error writing after seek to 0x%08x\n", mid);
				perror(" ");
				error = 1;
			}
		}

		if (error == 1)
			hi = mid - 1;
		else
			lo = mid + 1;
	}

	printf("mid: 0x%08x\n", mid);

	exit (0);
}


