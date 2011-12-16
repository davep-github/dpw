#include <stdio.h>

extern char *mktemp();

main(
int   argc,
char  *argv[])
{
   int   i;
   char  *tmp, tmpBuf[128];

   for (i = 1; i < argc; i++)
   {
      sprintf(tmpBuf, "%sXXXXXX", argv[i]);
      if ((tmp = mktemp(tmpBuf)) == NULL ||
           tmpBuf[0] == '\0')
      {
         perror("cannot mktemp()");
         continue;
      }

      printf("%s\n", tmpBuf);
   }

   exit (0);
}

