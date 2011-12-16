#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <fcntl.h>
#include <errno.h>

int verbose = 1;

int
main(
  int	    argc,
  char*   argv[])
{
  int	    fd;
  int	    kq;
  int	    rc;
  struct kevent ev[2];
  struct timespec timeout;
  
  
  fd = open(argv[1], O_RDONLY);
  if (fd < 0) {
    err(1, "cannot open %s", argv[1]);
  }
  
  kq = kqueue();
  if (kq < 0)
    err(1, "kqueue");

  timeout.tv_sec = 60;
  timeout.tv_nsec = 0;
  
  EV_SET(&ev[0], fd, EVFILT_READ,
	 EV_ADD | EV_ENABLE | EV_CLEAR, 0, 0, 0);
  
  if (kevent(kq, ev, 1, NULL, 0, NULL) < 0) {
    close(kq);
    err(1, "kevent#1 failed");
  }
  if (verbose)
    fprintf(stderr, "did 1st kevent\n");
  
  if (lseek(fd, 0, SEEK_END) < 0) {
    err(1, "cannot seek to end of %s", argv[1]);
  }
  if (verbose)
    fprintf(stderr, "did seek to end\n");
  
  if (verbose)
    fprintf(stderr, "doing 2nd kevent\n");
  
  if ((rc = kevent(kq, NULL, 0, ev, 1, &timeout)) < 0) {
    close(kq);
    err(1, "kevent#2 failed");
  }
  
  if (rc == 0) {
    /* timeout */
    if (verbose)
      fprintf(stderr, "timeout\n");
    exit(1);
  }
  
  if (verbose)
    fprintf(stderr, "file changed, data: %d\n", ev[0].data);
  
  exit(0);
}
