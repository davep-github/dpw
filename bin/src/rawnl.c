#include <stdio.h>
#include <fcntl.h>

main()
{
	int	fd;

	if ((fd = open("/dev/tty", O_WRONLY)) < 0)
		exit(1);

	write(fd, "\n", 1);

	close(fd);

	exit(0);
}
