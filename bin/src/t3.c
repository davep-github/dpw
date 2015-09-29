//#include "environ.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <getopt.h>
#if defined(ENV_OS_AIX)
#include <sys/mode.h>
#endif
#if !defined(ENV_OS_HPUX)
#include <limits.h>
#else
#include <sys/types.h>
#define  O_NDELAY 000004
typedef unsigned short  u_short;
#endif
#include <fcntl.h>
#include <unistd.h>

/* #include "sysdep/mode.h" */
#include "sys/stat.h"

int Base = 0;
int Random = 0;
int Verbose = 0;
int Debug = 0;

#if defined(ENV_OS_AIX)
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/shm.h>
#include <unistd.h>
int MemMapWrite = 0;
char *MemMapAddr = NULL;
#endif

/*
***********************************************************************
*
*
*
***********************************************************************
*/
void Usage(void)
{
    fprintf(stderr, "Usage: [-G n] [-g n] [-hbrtanvfd] [-s seed] file [offset] [src...]\n");
    fprintf(stderr, "Writes to offset in a file.\n"
            "Each src in [src...] is written with a separate write() call.\n"
            "Options:\n");
    fprintf(stderr, "\t-G n\t- gen n random integers at offset.\n");
    fprintf(stderr, "\t-g n\t- gen n random bytes at offset.\n");
    fprintf(stderr, "\t-h\t- interpret each src... as a string of hex bytes.\n");
    fprintf(stderr, "\t-b\t- interpret each src... as a byte w/C number conventions.\n");
    fprintf(stderr, "\t-f\t- interpret each src... as a file with previously set characteristics.\n");
    fprintf(stderr, "\t-r\t- generate random sequences.\n");
    fprintf(stderr, "\t-t\t- O_TRUNC file.\n");
    fprintf(stderr, "\t-a\t- append strings... Do not use offset.\n");
    fprintf(stderr, "\t-n\t- open file w/ O_NDELAY flag\n");
    fprintf(stderr, "\t-v\t- Add verbosity\n");
    fprintf(stderr, "\t-d\t- Add debugging\n");
    fprintf(stderr, "\n");

    exit (1);
}

long filelength(
    int fd)
{
    struct stat     sBuf;
    int                     rc;
  
    if ((rc = fstat(fd, &sBuf)) != 0)
    {
        perror("cannot stat");
        exit(1);
    }
  
    return (sBuf.st_size);
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
void GenInts(int fd, unsigned long num, unsigned long offset)
{
    int *buf;
    int i;
    unsigned long numBytes;

    numBytes = num * sizeof (int);

    if ((buf = (int *)malloc(numBytes)) == NULL) {
        fprintf(stderr, "Cannot malloc(%lu)\n", num);
        exit(1);
    }

    if (Random) {
        for (i = 0; i < num; i++)
            buf[i] = rand() * rand();
    } else {
        for (i = 0; i < num; i++)
            buf[i] = i + offset;
    }

    if (write(fd, buf, numBytes) != numBytes) {
        perror("GenInts() write failed");
        exit(1);
    }

    free(buf);
    close(fd);

    exit(0);
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
int
Write(
    int fd,
    const char *buf,
    size_t num)
{
#if defined(ENV_OS_AIX)
    if (MemMapWrite) {
        off_t off;

        off = lseek(fd, 0, SEEK_CUR);

        memcpy(MemMapAddr + off, buf, num);
        return (num);
    }
    else
#endif
    {
        return (write(fd, buf, num));
    }
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
void  WriteBytes(
    int   argc,
    char  *argv[],
    int   optind,
    int	fd)
{
    char  byt;
    char *p;

    while (optind < argc) {
        byt = strtoul(argv[optind++], &p, Base);
        if (Verbose)
            printf("%02x ", byt);
        if (Write(fd, &byt, 1) != 1) {
            perror("Write error");
            exit(1);
        }
    }
}

/*
***********************************************************************
*
*
*
***********************************************************************
*/
void GenBytes(int fd, unsigned long num, unsigned long offset)
{
    char *buf;
    int	i;

    if ((buf = (char*)malloc(num)) == NULL)
    {
        fprintf(stderr, "Cannot malloc(%lu)\n", num);
        exit(1);
    }

    if (Random) {
        for (i = 0; i < num; i++)
        {
            buf[i] = rand();
            if (Verbose)
                printf("%02x ", buf[i]);
        }
    } else {
        for (i = 0; i < num; i++) {
            buf[i] = i + offset;
            if (Verbose)
                printf("%02x ", buf[i]);
        }
    }

    if (Write(fd, buf, num) != num) {
        perror("GenBytes() Write failed");
        exit(1);
    }

    free(buf);
    close(fd);

    exit(0);
}

int write_file_contents(
    int fd,
    const char* input_file_name)
{
    // if name is "", then stdin is read.
    // otherwise, the file name is opened.
    // lines are like: xx xx xx xx\n
    FILE* infile;
    int close_p;
    if (!input_file_name[0]) {
        infile = stdin;
        close_p = 0;
    } else {
        infile = fopen(input_file_name, "r");
        if (infile == NULL) {
            fprintf(stderr, "open of @ file >%s< failed: ",
                    input_file_name);
            perror("");
            exit(1);
        }
        close_p = 1;
    }

    char* line = NULL;
    size_t n = 0;
    ssize_t num_read;
    char byt;
    unsigned int i;
    while (fscanf(infile, "%2x", &i) == 1) {
        if (Verbose) {
            printf("%02x ", i);
        }
        byt = (char)i;
        if (Write(fd, &byt, 1) != 1) {
            perror("Write error");
            exit(1);
        }
    }

    if (Verbose) {
        printf("\n");
    }
    
    if (close_p) {
        fclose(infile);
    }
    return 0;
}
        
        
/*
***********************************************************************
*
*
*
***********************************************************************
*/
main(
    int argc,
    char *argv[])
{
    int fd;
    int i;
    unsigned long l;
    unsigned long bytesToGen = 0;
    unsigned long intsToGen = 0;
    long offset = 0;
    char *p;
    int option;
    int writeBytes = 0;
    int seed = 0;
    int openFlags = O_WRONLY | O_CREAT;
    size_t num_iterations = 1;

    extern int opterr;
    extern char *optarg;
    extern int optind;

    if (argc < 3)
        Usage();

    opterr = 1;

    if (getenv("T3_DEBUG")) {
        int j;
        for (j = 0; j < argc; ++j) {
            printf("argv[%d]>%s<\n", j, argv[j]);
        }
    }
    
    while ((option = getopt(argc, argv, "vdG:g:bhrs:tano:mi:")) != EOF)
    {
        switch (option)
        {
#ifdef   ENV_OS_AIX
            case 'm':
                MemMapWrite = 1;
                break;
#endif

            case 'v':
                ++Verbose;
                break;

            case 'd':
                ++Debug;
                break;

            case 'o':
                openFlags = strtoul(optarg, &p, 0);
                break;

            case 'n':
                openFlags |= O_NDELAY;
                break;

            case 'a':
                openFlags |= O_APPEND;
                break;

            case 't':
                openFlags |= O_TRUNC;
                break;

            case 'r':
                Random = 1;
                break;

            case 's':
                seed = strtoul(optarg, &p, 0);
                break;

            case 'h':
                Base = 16;
                writeBytes = 1;
                break;

            case 'b':
                Base = 0;
                writeBytes = 1;
                break;

            case 'g':
                bytesToGen = strtoul(optarg, &p, 0);
                break;

            case 'G':
                intsToGen = strtoul(optarg, &p, 0);
                break;

            case 'i':
                num_iterations = strtoul(optarg, &p, 0);
                break;

            default:
                Usage();
        }
    }

    srand(seed);

    if ((fd = open(argv[optind++], openFlags,
                   S_IRUSR | S_IWUSR | S_IRGRP |
                   S_IWGRP | S_IROTH | S_IWOTH)) == -1) {
        perror("canna open file");
        exit(1);
    }

    if (openFlags & O_APPEND) {
        offset = filelength(fd);
    } else {
        offset = strtoul(argv[optind++], &p, 0);
    }

    if (lseek(fd, offset, SEEK_SET) != offset)
    {
        perror("seek error");
        exit(1);
    }

#if defined(ENV_OS_AIX)
    MemMapAddr = shmat(fd, NULL, SHM_MAP);
    if (MemMapAddr == (char *)-1) {
        perror("shmat failed");
        exit(1);
    }
#endif

    while (num_iterations--) {

        if (bytesToGen) {
            GenBytes(fd, bytesToGen, offset);
        }

        if (intsToGen) {
            GenInts(fd, intsToGen, offset);
        }

        if (writeBytes) {
            WriteBytes(argc, argv, optind, fd);
        } else {
            int rc = -1;
            i = optind;
            if (Debug) {
                // bs gdb doesn't seem to increment this.
                printf("4, optind: %d, i: %d, argc: %d\n", optind, i, argc);
            }

            for (; i < argc; i++) {
                const char* argp = argv[i];
                if (argp[0] == '@') {
                    rc = write_file_contents(fd, argp + 1);
                } else {
                    rc = Write(fd, argp, strlen(argv[i])) != strlen(argp);
                }
                if (rc) {
                    fprintf(stderr, "write(s) failed.\n");
                    return 1;
                }
            }
        }
    }

    close(fd);

    exit(0);
}
