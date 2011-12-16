#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

main(
	int	argc,
	char	*argv[])
{
	printf("uid: %d, euid: %d\n", 
		getuid(),
		geteuid());
	exit(0);
}
