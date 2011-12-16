#include "environ.h"
#include <stdio.h>
#include <sys/types.h>
#if   !defined(ENV_OS_HPUX)
#include "sysdep/vfs.h"
#include "sysdep/statfs.h"
#else
#include <sys/vfs.h>
#endif

Usage()
{
	fprintf(stderr, "stat: Usage: statfs file...\n");
	exit(1);
}
	

main(argc, argv)
int	argc;
char	*argv[];
{
	struct statfs  sBuf;
	int			urc;
	int			i;
	int			showTimeString = 0;
	int			octalPerms = 0;
	int			terseTime = 0;

	extern int	optind;
	extern int	opterr;
	extern char	*optarg;

	while ((i = getopt(argc, argv, "tpT")) != EOF)
	{
		switch (i)
		{
			case 't':
				showTimeString = 1;
				break;

			case 'p':
				octalPerms = 1;
				break;

			case 'T':
				terseTime = 1;
				break;

			default:
				Usage();
		}
	}

	for (i = optind; i < argc; i++)
	{
		if (statfs(argv[i], &sBuf) != 0)
		{
			fprintf(stderr, "cannot stat: %s", argv[1]);
			perror(" ");
			continue;
		}
#if   defined(ENV_OS_AIX)
	   printf("f_version: 0x%x\n", sBuf.f_version);		/* version/type of statfs, 0 for now */
#endif
	   printf("f_type: 0x%x\n", sBuf.f_type);		/* type of info, zero for now */
	   printf("f_bsize: 0x%x\n", sBuf.f_bsize);		/* fundamental file system block size */
	   printf("f_blocks: 0x%x\n", sBuf.f_blocks);		/* total data blocks in file system */
	   printf("f_bfree: 0x%x\n", sBuf.f_bfree);		/* free block in fs */
	   printf("f_bavail: 0x%x\n", sBuf.f_bavail);		/* free blocks avail to non-superuser */
	   printf("f_files: 0x%x\n", sBuf.f_files);		/* total file nodes in file system */
	   printf("f_ffree: 0x%x\n", sBuf.f_ffree);		/* free file nodes in fs */

#if   !defined(ENV_OS_HPUX)
      printf("f_fsid.fsid_type: 0x%x\n", sBuf.f_fsid.fsid_type);
      printf("f_fsid.fsid_dev: 0x%x\n", sBuf.f_fsid.fsid_dev);
#else
      printf("f_fsid.fsid_type: 0x%x\n", sBuf.f_fsid[1]);
      printf("f_fsid.fsid_dev: 0x%x\n", sBuf.f_fsid[0]);
#endif      

#if   defined(ENV_OS_AIX)
	   printf("f_vfstype: 0x%x\n", sBuf.f_vfstype);		/* what type of vfs this is */
	   printf("f_nlsdirtype: 0x%x\n", sBuf.f_nlsdirtype);	/* reserved for NLS dirs later, set to 0 now! */
	   printf("f_vfsnumber: 0x%x\n", sBuf.f_vfsnumber);	/* vfs indentifier number */
	   printf("f_vfsoff: 0x%x\n", sBuf.f_vfsoff);		/* reserved, for vfs specific data offset */
	   printf("f_vfslen: 0x%x\n", sBuf.f_vfslen);		/* reserved, for len of vfs specific data */
	   printf("f_vfsvers: 0x%x\n", sBuf.f_vfsvers);		/* reserved, for vers of vfs specific data */

      printf("f_fname >%s<\n", sBuf.f_fname);
      printf("f_fpack >%s<\n", sBuf.f_fpack);

	   printf("f_name_max: 0x%x\n", sBuf.f_name_max);	/* maximum component name length for posix */
#endif

#if	defined(ENV_OS_HPUX)
	printf("f_magic: 0x%x\n", sBuf.f_magic);
	printf("f_featurebits: 0x%x\n", sBuf.f_featurebits);
	printf("f_cnode: 0x%x\n", sBuf.f_cnode);
#endif
   }


	exit (0);
}
