#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdarg.h>

char* prog_name;

void
perrorf(
char* fmt,
...)
{
   va_list  ap;
   char     buf[1024];

   va_start(ap, fmt);
   vsprintf(buf, fmt, ap);
   fprintf(stderr, "%s: ", prog_name);
   perror(buf);
   va_end(ap);
}


int
main(
int   argc,
char* argv[])
{
   char  buf[1024];
   int   rc;

   if ((prog_name = strrchr(argv[0], '/')) == NULL)
       prog_name = argv[0];

   if (argc != 2)
   {
      fprintf(stderr, "usage: %s tty\n", prog_name);
      exit (1);
   }

   sprintf(buf, "/etc/nologin.%s", argv[1]);
   if (!strcmp(prog_name, "enable-mgetty-aa"))
   {
      if (access(buf, F_OK) == 0)
      {
         rc = unlink(buf);
         if (rc != 0)
         {
            perrorf("unlink of %s failed", buf);
            exit (2);
         }
      }
   }
   else if (!strcmp(prog_name, "disable-mgetty-aa"))
   {
      rc = creat(buf, 0644);
      if (rc < 0)
      {
         perrorf("creat of %s failed", buf);
         exit (3);
      }
      close(rc);
   }
   else
   {
      fprintf(stderr, "%s: unknown prog_name: %s\n", prog_name, prog_name);
      exit(1);
   }

   exit(0);
}

