#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>




char buf[14000] = { 0 };

main(int argc, char **argv)
{

	int fd;
	char *file;

	file = (argc == 1) ? "n:/abc" : argv[1];
	fd = open(file, O_CREAT | O_TRUNC | O_RDWR, 0666);
	if ( fd == -1 ) {
		perror("open");
		return(1);
	}

	if ( lseek(fd, 0x4412, SEEK_SET) == -1L ) {
		perror("lseek(1)");
		return(2);
	}

	if ( write(fd, buf, 1) != 1 ) {
		perror("write(1)");
		return(3);
	}

	if ( lseek(fd, 0L, SEEK_SET) == -1L ) {
		perror("lseek(2)");
		return(4);
	}

	if ( write(fd, buf, 5120) != 5120 ) {
		perror("write(2)");
		return(5);
	}

	if ( write(fd, buf, 12307) != 12307 ) {
		perror("write(3)");
		return(7);
	}

	close(fd);

	return(0);
}
