#include <stdio.h>
#include <sys/types.h>
#include <sys/errno.h>


main(
int   argc,
char  *argv[])
{
   if (geteuid() != 201)
      exit(EPERM);

#if 0
   if (setuid(0) != 0)
   {
      fprintf(stderr, "sucmd: setuid() failed");
      perror (" ");
      exit(1);
   }
#endif
   
   if (execvp(argv[1], argv + 1) < 0)
   {
      fprintf(stderr, "sucmd: execvp() failed");
      perror (" ");
      exit(1);
   }

   exit(0);
}
