#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>


main(
int   argc,
char  *argv[])
{
   int   fd;
   off_t start, tmp;
   long  len;
   int   i;


   i = 1;
   if ((fd = open(argv[i], O_RDWR)) == -1)
   {
      fprintf(stderr, "cannot open %s", argv[1]);
      perror(" ");
      exit(1);
   }

   start = strtol(argv[++i], NULL, 0);
   len   = strtol(argv[++i], NULL, 0);

   if ((tmp = lseek(fd, start, SEEK_SET)) != start)
   {
      fprintf(stderr, "cannot seek");
      perror(" ");
      exit(1);
   }

   if (lockf(fd, F_LOCK, len) < 0)
   {
      fprintf(stderr, "cannot lock");
      perror(" ");
      exit(1);
   }

   close(fd);
}
