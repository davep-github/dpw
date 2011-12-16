#include <stdio.h>
#include <fcntl.h>

char  ProgName[1024];

/*
***********************************************************************
*
*
*
***********************************************************************
*/
void  Usage(char *p)
{
   fprintf(stderr, "%s: usage: %s [-f flags] [-m mode] fileName\n",
      ProgName, ProgName);

   exit(1);
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
char  *basename(char *name, char *out)
{
	char	*p;

	for (p = name + strlen(name) - 1; p >= name; p--)
		if (*p == '/')
			break;
	p++;

   if (out != NULL)
   {
   	strcpy(out, p);
   	p = out;
   }

   return (p);
}

/*
***********************************************************************
*
*
*
***********************************************************************
*/
main(
int   argc,
char  *argv[])
{
   int            flags, mode;
   int            fd;
   int            option;
   char           *dummy;
   char           *options = "f:m:i:";
   char           buf[32];
   int            doIO = 0;

   extern int     optind;
   extern int     opterr;
   extern char    *optarg;

   opterr = 1;

   basename(argv[0], ProgName);

	if (argc == 1)
		Usage(ProgName);

   mode = 0444;
   flags = O_CREAT | O_RDWR;

   while ((option = getopt(argc, argv, options)) != EOF)
   {
      switch (option)
      {
         case 'i':
            doIO = 1;
            break;

         case 'f':
            flags = strtol(optarg, &dummy, 0);
            break;

         case 'm':
            mode = strtol(optarg, &dummy, 0);
            break;

         default:
            Usage(ProgName);
      }
   }

   if ((fd = open(argv[optind], flags, mode)) < 0)
   {
      fprintf(stderr, "%s: open(%s, 0x%x, 0x%x) failed", ProgName,
         argv[optind], flags, mode);

      perror(" ");
      exit (1);
   }

   if (doIO)
   {
	   if (write(fd, "hi", 2) != 2)
	   {
	      fprintf(stderr, "%s: write() to %s failed",
		 ProgName,  argv[optind]);
	      perror(" ");
	      exit (1);
	   }

	   if (lseek(fd, 0, SEEK_SET) != 0L)
	   {
	      fprintf(stderr, "%s: seek() in %s failed",
		 ProgName,  argv[optind]);
	      perror(" ");
	      exit (1);
	   }

	   if (read(fd, buf, 2) != 2)
	   {
	      fprintf(stderr, "%s: read() from %s failed",
		 ProgName,  argv[optind]);
	      perror(" ");
	      exit (1);
	   }
   }

   close(fd);

   return(0);
}
