#include <stdio.h>
#include <fcntl.h>
#include <malloc.h>

#define  READBufLen  (0x4000)

int   Verbose = 0;
/*
***********************************************************************
*
*
*
***********************************************************************
*/
Usage()
{
	fprintf(stderr, "Usage: [-f fill] [-l recLen] file\n");
   fprintf(stderr, "\n");

	exit (1);
}

main(argc, argv)
int	argc;
char	*argv[];
{
	int	fd;
   int   openFlags = O_RDWR | O_CREAT | O_TRUNC | O_APPEND;
   int   option;
   int   fillVal = 0;
   int   recLen = 13;
   char  *recBuf;
   char  *readBuf;
   long  offset;
   long  readOff;
   int   numRead;
   long  nLoops = 9999999;
   int   randMax = 0;
   char  *p;
   int   thisRecLen;

	extern int	opterr;
	extern char	*optarg;
	extern int	optind;

   opterr = 1;

	while ((option = getopt(argc, argv, "f:l:n:vr:")) != EOF)
	{
		switch (option)
		{
         case 'r':
            randMax = strtoul(optarg, &p, 0);
            break;

         case 'f':
            fillVal = strtoul(optarg, &p, 0);
            break;

         case 'l':
            recLen = strtoul(optarg, &p, 0);
            break;

         case 'n':
            nLoops = strtoul(optarg, &p, 0);
            break;

         case 'v':
            Verbose = 1;
            break;

			default:
				Usage();
		}
	}

   if ((recBuf = malloc(recLen + randMax)) == NULL)
   {
      fprintf(stderr, "cannot malloc() recBuf\n");
      exit (1);
   }

   if ((readBuf = malloc(READBufLen)) == NULL)
   {
      fprintf(stderr, "cannot malloc() readBuf\n");
      exit (1);
   }

	if ((fd = open(argv[optind++], openFlags, 0666)) < 0)
	{
		perror("canna open file");
		exit(1);
	}

   memset(recBuf, fillVal, recLen + randMax);
   offset = 0;

   while (nLoops--)
   {
      if (randMax != 0)
         thisRecLen = recLen + rand() % randMax;
      else
         thisRecLen = recLen;
      /* write a rec */

      if (Verbose)
         printf("write @ 0x%lx, recLen: %d\n", offset, thisRecLen);

      if (write(fd, recBuf, thisRecLen) != thisRecLen)
      {
         perror("write failed");
         exit (1);
      }

      offset += thisRecLen;

      readOff = 0;
      if (lseek(fd, 0L, SEEK_SET) != 0L)
      {
         perror("write failed");
         exit (1);
      }

      while ((numRead = read(fd, readBuf, READBufLen)) > 0)
      {
         int   i;
         char  *p;

         if (Verbose)
            printf("read from: 0x%lx\n", readOff);

         for (i = 0, p = readBuf; i < numRead; i++, p++)
         {
            if (*p != fillVal)
            {
               fprintf(stderr, "mismatch: off: 0x%lx, val: 0x%x\n",
                  readOff + (p - readBuf), *p);
					exit(3);
            }
         }

         readOff += numRead;
      }

      if (numRead < 0)
      {
         perror("read error");
         exit(2);
      }

      if (readOff != offset)
      {
         fprintf(stderr, "readOff(0x%lx) != offset(0x%lx)\n",
            readOff, offset);
         exit(2);
      }
   }


	close(fd);

	exit(0);
}


