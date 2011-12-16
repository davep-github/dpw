#include <stdio.h>
#include <sys/ioctl.h>

main()
{
	char	buf[256];

	if (ioctl(1, TXTTYNAME, buf))
	{
		perror("ioctl failed");
		exit(1);
	}

	printf("buf>%s<\n", buf);

	exit(0);
}
