#include <stdio.h>
#include <unistd.h>
#include <err.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

int
main(
  int	argc,
  char*	argv[])
{
  int	i;

  for (i = 1; i < argc; ++i) {
    int	fd = open(argv[i], O_RDONLY|O_NONBLOCK);
    if (fd > 0) {
      int rc = isatty(fd);
      char* msg;
      if (rc)
	msg = "OK";
      else
	msg = strerror(errno);
      
      printf("%s %s, rc: %s\n", argv[i], rc ? "y" : "n", msg);
      close(fd);
    }
    else
      warn("could not open `%s'", argv[i]);
  }

  return(0);
}

