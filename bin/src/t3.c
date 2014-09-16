//#include "environ.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
Usage()
{
  fprintf(stderr, "Usage: [-G n] [-g n] [-hbrtanvf] [-s seed] file [offset] [src...]\n");
  fprintf(stderr, "Writes to offset in a file.\n"
   "Each src in [src...] is written with a separate write() call.\n"
   "Options:\n");
  fprintf(stderr, "\t-G n\t- gen n random integers at offset.\n");
  fprintf(stderr, "\t-g n\t- gen n random bytes at offset.\n");
  fprintf(stderr, "\t-h\t- interpret each src... as a string of hex bytes.\n");
  fprintf(stderr, "\t-b\t- interpret each src... as a byte w/C number conventions.\n");
  fprintf(stderr, "\t-b\t- interpret each src... as a file with previously set characteristics.\n");
  fprintf(stderr, "\t-r\t- generate random sequences.\n");
  fprintf(stderr, "\t-t\t- truncate file.\n");
  fprintf(stderr, "\t-a\t- append strings... Do not use offset.\n");
  fprintf(stderr, "\t-n\t- open file w/ O_NDELAY flag\n");
  fprintf(stderr, "\n");
  
  exit (1);
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
  int      fd,
  char     *buf,
  size_t   num)
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
  unsigned char  byt;
  char *p;
  
  while (optind < argc) {
    byt = strtoul(argv[optind++], &p, Base);
    if (Verbose)
      printf("%02x ", byt);
    if (Write(fd, &byt, 1) != strlen(argv[optind])) {
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
  char	*buf;
  int	i;
  
  if ((buf = malloc(num)) == NULL)
  {
    fprintf(stderr, "Cannot malloc(%lu)\n", num);
    exit(1);
  }
  
  if (Random)
    for (i = 0; i < num; i++)
    {
      buf[i] = rand();
      if (Verbose)
	printf("%02x ", buf[i]);
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

/*
***********************************************************************
*
*
*
***********************************************************************
*/
main(int argc, char *argv[])
{
  int fd;
  int i;
  unsigned long	l;
  unsigned long	bytesToGen = 0;
  unsigned long	intsToGen = 0;
  long offset;
  char *p;
  int option;
  int writeBytes = 0;
  int seed = 0;
  int openFlags = O_WRONLY | O_CREAT;
  
  extern int opterr;
  extern char *optarg;
  extern int optind;
  
  if (argc < 3)
    Usage();
  
  opterr = 1;
  
  while ((option = getopt(argc, argv, "vG:g:bhrs:tano:m")) != EOF)
  {
    switch (option)
    {
#ifdef   ENV_OS_AIX
      case 'm':
	MemMapWrite = 1;
	break;
#endif
	
      case 'v':
	Verbose = 1;
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
  
#if defined(ENV_OS_AIX)
  MemMapAddr = shmat(fd, NULL, SHM_MAP);
  if (MemMapAddr == (char *)-1) {
    perror("shmat failed");
    exit(1);
  }
#endif
  
  if (!(openFlags & O_APPEND))
  {
    offset = strtoul(argv[optind++], &p, 0);
    
    if (lseek(fd, offset, SEEK_SET) != offset)
    {
      perror("seek error");
      exit(1);
    }
  }
  
  if (bytesToGen) {
      GenBytes(fd, bytesToGen, offset);
  }

  if (intsToGen) {
      GenInts(fd, intsToGen, offset);
  }

  if (writeBytes) {
      WriteBytes(argc, argv, optind, fd);
  } else {
    for (i = optind; i < argc; i++) {
      if (Write(fd, argv[i], strlen(argv[i])) != strlen(argv[i])) {
	perror("Write error");
	exit(1);
      }
    }
  }
  
  close(fd);
  
  exit(0);
}
