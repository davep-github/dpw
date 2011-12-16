#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>

Sleep(
uint  sleepTime)
{
   uint  timeSlept;

   printf("Sleeping for %u secs... ", sleepTime);
	fflush(stdout);
	if ((timeSlept = sleep(sleepTime)) != 0)
	{
		if (timeSlept == (uint)-1)
		{
			perror("sleep failed");
			return (-1);
		}

		printf("%s sec remains unslept()\n");
	}
   else
      printf("Done.\n");

   return (0);
}


PTimes(
char			*header,
struct stat	*sbp)
{
	time_t	now;

	time(&now);
	printf("%snow: %s", header, ctime(&now));

	printf("st_atime: 0x%08x", (unsigned long)sbp->st_atime);
	printf(", %s", ctime(&sbp->st_atime));
	printf("st_mtime: 0x%08x", (unsigned long)sbp->st_mtime);
	printf(", %s", ctime(&sbp->st_mtime));
	printf("st_ctime: 0x%08x", (unsigned long)sbp->st_ctime);
	printf(", %s", ctime(&sbp->st_ctime));
}

StatAndPTimes(
char  *header,
char  *file)
{
   struct stat sBuf;

	if (stat(file, &sBuf) != 0)
	{
		fprintf(stderr, "cktime: stat %s failed", file);
		return (-1);
	}

	PTimes(header, &sBuf);

   return (0);
}

FStatAndPTimes(
char  *header,
int   fd)
{
   struct stat sBuf;

	if (fstat(fd, &sBuf) != 0)
	{
		perror("cktime: fstat failed");
		return (-1);
	}

	PTimes(header, &sBuf);

   return (0);
}


int	SleepAndRead(
int	fd,
uint	sleepTime)
{
	char	buf[10];

   if (Sleep(sleepTime))
      return (-1);

	if (read(fd, buf, 1) != 1)
	{
		perror("cktime: error reading");
		return (-1);
	}

	return (0);
}

int	SleepAndWrite(
int	fd,
uint	sleepTime)
{
	char	buf[10];

   if (Sleep(sleepTime))
      return (-1);

	if (write(fd, buf, 1) != 1)
	{
		perror("cktime: error writing");
		return (-1);
	}

	return (0);
}

Usage()
{
	fprintf(stderr, "cktime: usage: cktime [-s] file...\n");
	exit(1);
}

main(
int	argc,
char	*argv[])
{
	int			fd;
	char			*file;
	int			opt;
	struct stat	sBuf;
	uint			sleepTime = 12;		/* seconds */
	uint			timeSlept;

	extern int	optind;
	extern int	opterr;
	extern char	*optarg;

	while ((opt = getopt(argc, argv, "s:")) != EOF)
	{
		switch (opt)
		{
			case 's':
				sleepTime = strtoul(optarg, &file, 0);
				break;

			default:
				Usage();
		}
	}

	for (; optind < argc; optind++)
	{
		file = argv[optind];

      if (StatAndPTimes("first stat\n", file))
         continue;

		if ((fd = open(file, O_WRONLY)) == -1)
		{
			fprintf(stderr, "cktime: open %s failed", file);
			perror(" ");
			continue;
		}

      if (FStatAndPTimes("fstat after open\n", fd))
      {
         close(fd);
         continue;
      }

      if (SleepAndWrite(fd, sleepTime))
      {
         close(fd);
         continue;
      }

      if (FStatAndPTimes("fstat after read\n", fd))
      {
         close(fd);
         continue;
      }

      if (SleepAndWrite(fd, sleepTime))
      {
         close(fd);
         continue;
      }

      if (FStatAndPTimes("fstat after 2nd read\n", fd))
      {
         close(fd);
         continue;
      }

		Sleep(sleepTime);

		close(fd);

      if (StatAndPTimes("stat after close\n", file))
         continue;
	}
}
