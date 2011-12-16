#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/ioccom.h>
#include <net/if_tun.h>

main(
    int	    argc,
    char*   argv[])
{
    char*   devname;
    int	    debug_val;
    int	    fd;
    int	    rc;
    
    /*
     * itndebug dev value
     */

    if (argc < 3) {
	fprintf(stderr, "usage: itndebug dev debug_val\n");
	exit(1);
    }
    
    devname = argv[1];
    debug_val = strtol(argv[2], NULL, 0);

    if ((fd = open(devname, O_RDWR)) < 0) {
	fprintf(stderr, "%s: cannot open %s: %s\n",
		argv[0], devname, strerror(errno));
	exit(1);
    }

    rc = ioctl(fd, TUNSDEBUG, &debug_val);
    if (rc < 0) {
	fprintf(stderr, "%s: ioctl TUNSDEBUG failed: %s\n",
		argv[0], strerror(errno));
	exit(1);
    }

    exit(1);
}

	

    
