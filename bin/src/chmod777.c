#include <stdio.h>

main(
int	argc,
char	*argv[])
{
   int   i;
   char  buf[128];
   int	errcount = 0;

   if (argc == 1)
   {
   	if (chmod("/rd", 0777) != 0)
   	{
   		fprintf(stderr, "chmod777: chmod() /rd failed");
   		perror(" ");
   		exit(1);
   	}
   }
   else
   {
      for (i = 1; i < argc; i++)
      {
         sprintf(buf, "/rd%s", argv[i]);
   
      	if (chmod(buf, 0777) != 0)
      	{
      		fprintf(stderr, "chmod777: chmod() %s failed", buf);
      		perror(" ");
		errcount++;
      		continue;
      	}
      }
   }

   exit (errcount != 0);
}
