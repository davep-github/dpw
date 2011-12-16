#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

/****************************************************************************/
static int dumpWaitStatus(FILE* op, int status)
{
  do {
    if (WIFEXITED(status)) {
      fprintf(op, "exited, status=%d.\n", WEXITSTATUS(status));
    } else if (WIFSIGNALED(status)) {
      fprintf(op, "killed by signal %d.\n", WTERMSIG(status));
    } else if (WIFSTOPPED(status)) {
      fprintf(op, "stopped by signal %d.\n", WSTOPSIG(status));
    } else if (WIFCONTINUED(status)) {
      fprintf(op, "continued.\n");
    }
  } while (!WIFEXITED(status) && !WIFSIGNALED(status));

  return status;
}

int
main(int argc, char *argv[])
{
 pid_t cpid, w;
 int status;

 if (argc < 2) {
   fprintf(stderr, "You need to specify an error code oct|dec|hex.");
   return 2;
 }
 status = strtol(argv[1], NULL, 0);
 dumpWaitStatus(stderr, status);
   
 return EXIT_SUCCESS;
}


