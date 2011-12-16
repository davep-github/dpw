#include <stdio.h>
#include <stdlib.h>
#ifdef MSC
#include <io.h>
#else
#define O_BINARY        (0)
#endif
#include <ctype.h>
#include <fcntl.h>

#include "environ.h"

#define MIN(a, b) ((a) < (b) ? (a) : (b))

int   Verbose = 1;

#ifndef MSC
#include <sys/types.h>
#include <sys/stat.h>
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
#endif

/*
***********************************************************************
*
* 
*
***********************************************************************
*/
void  Dump(
  FILE    *fp,
  char  *file,
  long  start,
  long  num)
{
  int fd;
  int c;
  int i;
  unsigned char  buf[16];
  int skip;
  int rc;
  long oldNum;
  long len;
#if     !defined(ENV_OS_HPUX)
  long           ftell(), fseek();
#endif
  
  fd = fileno(fp);
  
  if (Verbose)
    skip = start % 16;
  else
    skip = 0;
  
  if (isatty(fd))
  {
    fprintf(stderr, "hd: cannot dump a tty\n");
    exit(1);
  }
  
  len = filelength(fd);
  num = MIN(num, len - start);
  
  if (Verbose)
    printf("\nhd: %s: %lu (0x%lX) bytes\n", file, len, len);
  
  if (fseek(fp, start, SEEK_SET) != 0)
  {
    fprintf(stderr, "hd: cannot seek %s", file);
    perror(" ");
    return;
  }
  
  while (num)
  {
    if (Verbose)
      printf("%08lx: ", ftell(fp) - skip);
    
    oldNum = num;
    
    for (i = 0; i < skip; i++)
      printf("   ");
    
    for (; i < 16 && num; i++, num--)
    {
      if ((c = getc(fp)) == EOF)
        break;
      
      buf[i] = c;
      
      printf("%02x%c", buf[i] & 0xff, ((i == 7) && Verbose) ? '-' : ' ');
    }
    
    if (c == EOF && num)
    {
      if (feof(fp))
        fprintf(stderr, "hd: EOF encountered.\n");
      else
      {
        fprintf(stderr, "hd: ");
        perror("error reading file");
      }
      break;
    }
    
    if (Verbose)
      for (; i < 16; i++)
        printf("   ");
    
    if (Verbose)
      printf("| ");
    
    for (i = 0; skip; i++, skip--)
      printf(" ");
    
    if (Verbose)
    {
      for (; i < 16 && oldNum; i++, oldNum--)
        printf("%c", isprint(buf[i]) ? buf[i] : '.');
      
      for (; i < 16; i++)
        printf(" ");
      
      printf("\n");
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
main(
  int   argc,
  char  *argv[])
{
  extern int  optind;
  extern char *optarg;
  extern int  opterr;
  
  int          option;
  long         start;
  long         num;
  char         *p;
  size_t  bufSize;
  char            *buf;
  
  start = 0;
  num   = 0x7fffffff;
  buf = NULL;
  
  while ((option = getopt(argc, argv, "s:n:qB:b:k:")) != EOF)
  {
    switch (option)
    {
      case 's':
        start = strtoul(optarg, &p, 0);
        break;
        
      case 'b':
        start = strtoul(optarg, &p, 0) * 512;
        break;
        
      case 'k':
        start = strtoul(optarg, &p, 0) * 1024;
        break;
        
      case 'n':
        num = strtoul(optarg, &p, 0);
        break;
        
      case 'q':
        Verbose = 0;
        break;
        
      case 'B':
        bufSize = strtoul(optarg, &p, 0);
        if ((buf = malloc(bufSize)) == NULL)
        {
          fprintf(stderr, "hd: cannot malloc() buf\n");
          exit(1);
        }
        break;
        
      default:
        exit(1);
    }
  }
  
  if (optind < argc)
  {
    for (; optind < argc; optind++)
    {
      FILE   *fp;
      
      if ((fp = fopen(argv[optind], "r")) == NULL)
      {
        fprintf(stderr, "hd: cannot open %s", argv[optind]);
        perror(" ");
        continue;
      }
      
      if (buf != NULL)
      {
        if (setvbuf(fp, buf, _IOFBF, bufSize) != 0)
        {
          fprintf(stderr, "hd: setvbuf() failed on %s", argv[optind]);
          perror(" ");
          fclose(fp);
          continue;
        }
      }
      
      Dump(fp, argv[optind], start, num);
      printf("\n--\n");
      
      fclose(fp);
    }
  }
  else
    Dump(stdin, "stdin", start, num);
  
  exit(0);
}


