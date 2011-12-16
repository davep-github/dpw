#include <stdio.h>
#include <sys/types.h>
#if	defined(ENV_OS_HPUX)
#include <sys/uid.h>
#endif

main(
int   argc,
char  *argv[])
{
   uid_t id;

   if (argc > 1 && strcmp(argv[1], "-e") == 0)
      id = geteuid();
   else
      id = getuid();

   printf("%d\n", id);
}
