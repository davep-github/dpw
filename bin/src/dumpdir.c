#include "environ.h"
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>

#if   defined(ENV_OS_SOLARIS)
#define  dd_curoff   dd_off
#define  d_offset    d_off
#endif

int	Verbose = 0;
int	DumpBuf = 0;

DoDumpBuf(DIR *dir)
{
#if	defined(ENV_OS_HPUX)
	printf("DoDumpBuf not supported.\n");
#else
	printf("dd_buf: 0x%08x, dd_size: 0x%08x\n", dir->dd_buf, dir->dd_size);
	HexDump(dir->dd_buf, dir->dd_size);
#endif
}

Usage()
{
	fprintf(stderr, "usage: dumpdir [-vb] dir\n");
	exit(1);
}

main(
int argc, /* number of args */
char *argv[])
{
	DIR				*dir;
	struct dirent	*de;
	int				opt;

	extern int		opterr;
	extern int		optind;
	extern char		*optarg;

	while ((opt = getopt(argc, argv, "vb")) != EOF)
	{
		switch (opt)
		{
			case 'v':
				Verbose = 1;
				break;

			case 'b':
				DumpBuf = 1;
				break;

			default:
				Usage();
		}
	}


	if ((dir = opendir(argv[optind])) == NULL)
	{
		fprintf(stderr, "cannot open %s", argv[optind]);
		perror(" ");
		exit(1);
	}

	if (Verbose)
#if	defined(ENV_OS_HPUX)
		;
#else
		printf("dd_loc: 0x%x, dd_curoff: 0x%x\n", dir->dd_loc, dir->dd_curoff);
#endif

	if (DumpBuf)
		DoDumpBuf(dir);

	for (de = readdir(dir); de; de = readdir(dir))
	{
		if (Verbose)
#if	defined(ENV_OS_HPUX)
			;
#else
			printf("dd_loc: 0x%x, dd_curoff: 0x%x\n", dir->dd_loc, dir->dd_curoff);
#endif

		if (DumpBuf)
			DoDumpBuf(dir);

#if	defined(ENV_OS_HPUX)
		printf("d_name>%s<,  d_ino: 0x%x, d_reclen: 0x%x\n",
			de->d_name, de->d_ino, de->d_reclen);
#else
		printf("d_name>%s<, d_offset: 0x%x, d_ino: 0x%x, d_reclen: 0x%x\n",
			de->d_name, de->d_offset, de->d_ino, de->d_reclen);
#endif
	}

	closedir(dir);

	exit(0);
}
