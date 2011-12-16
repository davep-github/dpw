#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>

#define BLK_SIZE	(4096)

void
perrorf(
	char*	fmt,
	...)
{
	va_list	ap;

	va_start(ap, fmt);

	vfprintf(stderr, fmt, ap);
	perror(" ");
}

main(
	int	argc,
	char*	argv[])
{
	char*	options = "s:n:";
	long	offset;
	int	option;
	int	fd;
	unsigned long	num = (unsigned long)-1;
	unsigned long	nblks;
	int	num_read;
	char	buf[BLK_SIZE];

	extern char*	optarg;
	extern int	opterr;
	extern int	optind;

	opterr = 1;

	while ((option = getopt(argc, argv, options)) != EOF) {
		switch (option) {
			case 's':
				offset = strtoul(optarg, NULL, 0);
				break;

			case 'n':
				num = strtoul(optarg, NULL, 0);
				break;
		}
	}

	if ((fd = open(argv[optind], O_RDONLY)) < 0) {
		perrorf("cannot open %s", argv[optind]);
		exit(1);
		
	}

	if (lseek(fd, offset, SEEK_SET) != offset) {
		perrorf("cannot seek %s", argv[optind]);
		exit(2);
	}

	nblks = num / BLK_SIZE;

	while (nblks--) {
		if ((num_read = read(fd, buf, BLK_SIZE)) < 0) {
			perrorf("cannot read %s", argv[optind]);
			exit(1);
		}
		if (num_read == 0)
			break;
		
		write(1, buf, num_read);
		num -= num_read;
	}

	if (num) {
		if ((num_read = read(fd, buf, num)) < 0) {
			perrorf("cannot read %s", argv[optind]);
			exit(1);
		}
		write(1, buf, num_read);
	}

	close(fd);
	exit(0);
}

	
		
	

				
			

	
