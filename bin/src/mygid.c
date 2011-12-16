#include <stdio.h>
#include <sys/types.h>

main(
int   argc,
char  *argv[])
{
   gid_t id;

   if (argc > 1 && strcmp(argv[1], "-e") == 0)
      id = getegid();
   else
      id = getgid();

   printf("%d\n", id);
}

