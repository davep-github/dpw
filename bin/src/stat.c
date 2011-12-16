#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include "environ.h"

Usage()
{
    fprintf(stderr, "stat: Usage: stat [-t] file...\n");
    exit(1);
}


main(argc, argv)
    int	argc;
char	*argv[];
{
    struct stat	sBuf;
    int			urc;
    int			i;
    int			showTimeString = 0;
    int			octalPerms = 0;
    int			terseTime = 0;
    int			doLstat = 0;
    
    extern int	optind;
    extern int	opterr;
    extern char	*optarg;
    
    while ((i = getopt(argc, argv, "ltpT")) != EOF)
    {
        switch (i)
        {
            case 'l':
                doLstat = 1;
                break;
                
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
        if (doLstat)
            urc = lstat(argv[i], &sBuf);
        else
            urc = stat(argv[i], &sBuf);
        
        if (urc != 0)
        {
            if (errno != 0)
            {
                fprintf(stderr, "cannot %sstat: %s",
                        doLstat ? "l" : "", argv[i]);
                perror(" ");
                continue;
            }
            else
                fprintf(stderr, "errno == 0!\n");
        }
        
        if (octalPerms)
        {
            printf("%03o", sBuf.st_mode & 0777);
            continue;
        }
        
        if (terseTime)
        {
            printf("st_ctime: 0x%08x ", (unsigned long)sBuf.st_ctime);
            printf("st_mtime: 0x%08x ", (unsigned long)sBuf.st_mtime);
            printf("st_atime: 0x%08x", (unsigned long)sBuf.st_atime);
            continue;
        }
        
        
        if (!showTimeString)
        {
            printf("st_dev: 0x%08x\n", (unsigned long)sBuf.st_dev);
            printf("st_ino: 0x%08x\n", (unsigned long)sBuf.st_ino);
#ifdef	_NONSTD_TYPES
            printf("st_mode_ext: 0x%08x\n", (unsigned long)sBuf.st_mode_ext);
            printf("st_mode: 0x%08x\n", (unsigned long)sBuf.st_mode);
#else
            printf("st_mode: 0x%08x\n", (unsigned long)sBuf.st_mode);
#endif	/* _NONSTD_TYPES */
            printf("st_nlink: 0x%08x\n", (unsigned long)sBuf.st_nlink);
#ifdef	_NONSTD_TYPES
            /*printf("st_pad_to_word: 0x%08x\n", (unsigned long)sBuf.st_pad_to_word);*/
            printf("st_uid_ext: 0x%08x\n", (unsigned long)sBuf.st_uid_ext);
            printf("st_uid: 0x%08x\n", (unsigned long)sBuf.st_uid);
            printf("st_gid_ext: 0x%08x\n", (unsigned long)sBuf.st_gid_ext);
            printf("st_gid: 0x%08x\n", (unsigned long)sBuf.st_gid);
#else
            printf("st_uid: 0x%08x\n", (unsigned long)sBuf.st_uid);
            printf("st_gid: 0x%08x\n", (unsigned long)sBuf.st_gid);
#endif	/* _NONSTD_TYPES */
            printf("st_rdev: 0x%08x\n", (unsigned long)sBuf.st_rdev);
            printf("st_size: 0x%08x\n", (unsigned long)sBuf.st_size);
        }
        
        printf("st_atime: 0x%08x", (unsigned long)sBuf.st_atime);
        printf(", %s", ctime(&sBuf.st_atime));
        printf("st_spare1: 0x%08x\n", (unsigned long)sBuf.st_spare1);
        
        printf("st_mtime: 0x%08x", (unsigned long)sBuf.st_mtime);
        printf(", %s", ctime(&sBuf.st_mtime));
        printf("st_spare2: 0x%08x\n", (unsigned long)sBuf.st_spare2);
        
        printf("st_ctime: 0x%08x", (unsigned long)sBuf.st_ctime);
        printf(", %s", ctime(&sBuf.st_ctime));
        printf("st_spare3: 0x%08x\n", (unsigned long)sBuf.st_spare3);
        
        if (!showTimeString)
        {
            printf("st_blksize: 0x%08x\n", (unsigned long)sBuf.st_blksize);
            printf("st_blocks: 0x%08x\n", (unsigned long)sBuf.st_blocks);
            
#if   defined(ENV_OS_AIX)
            printf("st_vfstype: 0x%08x\n", (unsigned long)sBuf.st_vfstype);
            printf("st_vfs: 0x%08x\n", (unsigned long)sBuf.st_vfs);
            printf("st_type: 0x%08x\n", (unsigned long)sBuf.st_type);
            printf("st_gen: 0x%08x\n", (unsigned long)sBuf.st_gen);
            printf("st_flag: 0x%08x\n", (unsigned long)sBuf.st_flag);
            printf("st_access: 0x%08x\n", (unsigned long)sBuf.st_access);
#elif defined(ENV_OS_HPUX)
            printf("st_acl:1: 0x%x\n", sBuf.st_acl);
            printf("st_remote:1: 0x%x\n", sBuf.st_remote);
            printf("st_netdev: 0x%x\n", sBuf.st_netdev);
            printf("st_netino: 0x%x\n", sBuf.st_netino);
            printf("st_cnode: 0x%x\n", sBuf.st_cnode);
            printf("st_rcnode: 0x%x\n", sBuf.st_rcnode);
            printf("st_netsite: 0x%x\n", sBuf.st_netsite);
            printf("st_fstype: 0x%x\n", sBuf.st_fstype);
            printf("st_realdev: 0x%x\n", sBuf.st_realdev);
            printf("st_basemode: 0x%x\n", sBuf.st_basemode);
#endif
            /*printf("Reserved1: 0x%08x\n", (unsigned long)sBuf.Reserved1);*/
            /*printf("Reserved2: 0x%08x\n", (unsigned long)sBuf.Reserved2);*/
            
        }
    }
    
    exit (0);
}
