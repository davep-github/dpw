#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <err.h>

/*
 * Print argv, preceded by argc in ascii and with a '\000' after each argv[i]
 * By running this, the args come out as one line. This is easy to parse.
 * By shelling args to this, we get the shell to parse the args for free.
 * E.g. argv: "hello" "world"
 * --> "3"\0`parse_cmd'\0"hello"\0"world"\0
 */

const int STDFD_OUT = 1;
int
main(
  int argc,
  const char* argv[])
{
  int i;
  char ascii_num_args[16];

  snprintf(ascii_num_args, sizeof(ascii_num_args) - 1, "%d", argc);
  write(STDFD_OUT, ascii_num_args, strlen(ascii_num_args) + 1);
  for (i = 0; i < argc; ++i) {
    write(STDFD_OUT, argv[i], strlen(argv[i]) + 1);
  }

#if 0                           /* 2020-04-14T16:51:05 by: davep */
  /* If we ever want to use a different output fd. */
  int rc = close(STDFD_OUT);
  if (rc != 0) {
      errx(1, "close(%d) failed.", STDFD_OUT);
  }
#endif                        /* #if 0 */ /* 2020-04-14T16:51:05 by: davep */

  return 0;
}


