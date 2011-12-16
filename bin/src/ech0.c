#include <stdio.h>
#include <string.h>
#include <unistd.h>

/*
 * Print argv, preceded by argc in ascii and with a '\000' after each argv[i]
 * By running this, the args come out as one line. This is easy to parse.
 * By shelling args to this, we get the shell to parse the args for free.
 */

const int STDFD_OUT = 1;
int
main(
  int argc,
  const char* argv[])
{
  int i;
  char ascii_num_args[16];

  snprintf(ascii_num_args, sizeof(ascii_num_args)-1, "%d", argc);
  //fprintf(stderr, "%d\n", argc);
  write(STDFD_OUT, ascii_num_args, strlen(ascii_num_args)+1);
  for (i=0; i < argc; ++i) {
    //fprintf(stderr, ">%s<\n", argv[i]);
    write(STDFD_OUT, argv[i], strlen(argv[i])+1);
  }

  return 0;
}


