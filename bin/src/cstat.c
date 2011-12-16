#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>

int
main(
  int	argc,
  char*	argv[])
{
  struct stat sbuf;
  int	      i;
  int	      rc;

  for (i = 1; i < argc; ++i) {
    rc = stat(argv[i], &sbuf);
    if (rc) {
      fprintf(stderr, "stat failed for >%s<\n", argv[i]);
      perror("");
      continue;
    }

    printf(">%s<, mode: 0x%x\n", argv[i], sbuf.st_mode);
  }

  return(0);
}
  
