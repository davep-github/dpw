#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>



main(
int	argc,
char	*argv[])
{
   off_t          truncLen = -1;
   off_t          start, len;
   int            option;
   int            quit;
   char           *dummy;
   char           cmdStr[80], rwStr[80];
   struct flock   fLock;

   extern int  optind;
   extern int  opterr;
   extern char *optarg;

   while ((option = getopt(argc, argv, "t:")) != EOF)
   {
      switch (option)
      {
         case 't':
            truncLen = strtol(optarg, &dummy, 0);
            break;

         default:
            Usage();
      }
   }

   if (optind != argc - 1)
      Usage();

   /*           Cmd RW start len */
   for (quit = 0; !quit;)
   {
      if (scanf("%s %s %ld %ld", cmdStr, rwStr, &start, &len) == EOF)
         break;

      switch (cmdStr[0])
      {
         case 'q':
            quit = 1;
            break;

         case 's':   /* set a lock */


         case 'c':   /* clear a lock */


         case 'q':   /* query a lock */

      }
   }


}

