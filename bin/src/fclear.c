#include <stdio.h>
#include <fcntl.h>

main(
int	argc,
char	*argv[])
{
	unsigned long	offset;
	unsigned long	num;
	int				fd;
	char				*p;
	int				ret;

	if (argc < 4)
	{
		fprintf(stderr, "fclear: usage: fclear file offset len\n");
		exit(1);
	}

	if ((fd = open(argv[1], O_RDWR | O_CREAT, 0666)) == -1)
	{
		fprintf(stderr, "fclear: cannot open %s", argv[1]);
		perror(" ");
		exit(1);
	}

	offset = strtoul(argv[2], &p, 0);
	num    = strtoul(argv[3], &p, 0);

	if (lseek(fd, offset, SEEK_SET) != offset)
	{
		perror("fclear: lseek() failed\n");
		exit(1);
	}

	if ((ret = fclear(fd, num)) != num)

	{
		fprintf(stderr, "fclear: fclear() failed, ret: %d", ret);
		perror(" ");
		exit(1);
	}

	close(fd);

	exit(0);
}


