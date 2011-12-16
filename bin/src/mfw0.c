#include "environ.h"
#include <stdio.h>
#include <malloc.h>
#include <errno.h>
#ifdef ENV_OS_NOVELL
#include <io.h>
#endif
#include <math.h>
#include <string.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <ctype.h>
#include <signal.h>
#include <assert.h>
#include <sys/time.h>
#include <sys/uio.h>

#include "types.h"

#ifdef   min
#undef min
#endif

#define  min(a, b)   ((a) < (b) ? (a) : (b))

#ifdef ENV_OS_NOVELL
#include <direct.h>
#endif
#if   defined(ENV_OS_AIX) || defined(ENV_OS_SOLARIS) || defined(ENV_OS_HPUX)
#include <dirent.h>
#endif

#if   defined(ENV_OS_HPUX)
typedef unsigned int uint;
#endif

#include "timestuf.h"

#ifndef  PATH_MAX
#if   !defined(ENV_OS_HPUX)
#include <limits.h>
#define  PATH_MAX    _POSIX_PATH_MAX
#else
#include <sys/param.h>
#define  PATH_MAX    MAXPATHLEN
#endif
#endif

#ifndef  SIGMAX
#if   defined(ENV_OS_HPUX)
#define  SIGMAX  (_NSIG - 1)
#else
#define  SIGMAX   (NSIG - 1)
#endif
#endif

#define  BLOCKSize      (512)
#define  MAXTotalErrors (0x7fffffff)

#if	defined (ENV_OS_NOVELL) || defined (ENV_OS_AIX) || defined(ENV_OS_SOLARIS)
#define  Rand32()    ((uint32)rand())
#else
#define  Rand32()    ((uint32)((uint32)rand() * (uint32)rand()))
#endif

#define  Rand32Range(num)  (Rand32() % (num))

#define  FillValue() (Initial + blockNum * Increment)

#define  FUNCRead          (0)
#define  FUNCWrite         (1)
#define  FUNCRandRead      (2)
#define  FUNCWriteThenRead (3)

#ifdef ENV_OS_NOVELL
extern uint32  NDirtyBlocks;
extern uint32  DiskIOsPending;
#endif

FILE  *logFile;

long  MaxErrors = 1;
long  Verbose = 0;

char  *BigBuf;
char  *BigBufp;
int   BigBufSize = 16384;
int   BytesInBigBuf = 0;
int   IdentifyBlocks = 0;
int   BreakOnMismatch = 0;
int	Verbosish = 0;
int	FillNumeric = 0;

time_t	WriteStartTime;

#if   !defined(ENV_OS_HPUX)
#define  MAXIOVs  (4)
int   NumIOVs;
struct iovec   IOVs[MAXIOVs];
int   IOVScramble[MAXIOVs] = {2, 0, 1, 3};
#endif

int   WriteV = 0;

char	ProgName[PATH_MAX + 2];

uint32   RandomSleepChance = 0;     /* in percent */
uint32   RandomSleepTime;           /* in mSec */

int      LogFlag = 0;

uint32	TotalErrors = 0;

unsigned long  Initial;
unsigned long  Increment;

#if   defined(ENV_OS_AIX) || defined(ENV_OS_SOLARIS) || defined(ENV_OS_HPUX)
#define	MkDir(p, mode)	mkdir(p, mode)
#endif

#ifdef ENV_OS_NOVELL
#define  MkDir(p, mode)		mkdir(p)
#define	BufSet(a, b, c)	memset(a, b, c)
#define	SECSPer				(18)
#endif

#ifndef ENV_OS_NOVELL

#define	GetCurrentTime()	time(NULL)
#define	SECSPer				(1)

/*
***********************************************************************
*
*
*
***********************************************************************
*/
void	BufSet(dst, src, numBytes)
long		*src;
long		*dst;
size_t	numBytes;
{
	size_t	numLongs;

	for (numLongs = numBytes / sizeof(long); numLongs; numLongs--, dst++)
		*dst = *src;
}

/*
***********************************************************************
*
*
*
***********************************************************************
*/
char  *strend(char *s)
{
   while (*s)
      s++;

   return (s);
}

/*
***********************************************************************
*
*
*
***********************************************************************
*/
FillBlock(
char		*buf,
uint32	blockNum)
{
   long  *p;
   long  val;
   int   i;

	if (FillNumeric)
	{
		p = (long *)buf;
		val = blockNum * (BLOCKSize / sizeof(long));

		for (i = BLOCKSize / sizeof(long); i; i--)
		{
			*p++ = val++;
		}
	}
	else
	{
		*((long *)buf) = FillValue();
		BufSet(buf + sizeof(long), buf, BLOCKSize - sizeof(long));
	}
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
FillIDBlock(
char     *id,
uint32   blockNum,
char		*file)
{
   int   tmp, i;
   char  *p, *q;
   int   num;
   char  buf[BLOCKSize];
   int   len;

   p = id;
   q = id + BLOCKSize;
   num = 0;

   while (p < q)
   {
      sprintf(buf, "[\n%dBlk: 0x%08x", num, blockNum);
      sprintf(strend(buf), "\n%s", file);
		sprintf(strend(buf), "\n%s%d]", ctime(&WriteStartTime), num);

      tmp = strlen(buf);
      len = min(tmp, q - p);

      memcpy(p, buf, len);

      p += len;
         
      num++;
   }

}

/*
***********************************************************************
*
*
*
***********************************************************************
*/
char	*basename(
char	*name,
char	*out)
{
	char	*p;

	for (p = name + strlen(name) - 1; p >= name; p--)
		if (*p == '/')
			break;
	p++;
	strcpy(out, p);
	return (out);
}
	
/*
***********************************************************************
*
*
*
***********************************************************************
*/
long	filelength(fd)
int	fd;
{
	struct stat	sBuf;

	if (fstat(fd, &sBuf) != 0)
		return (-1);

	return (sBuf.st_size);
}

static char EnterMsg[] = "Press <Enter> to Continue...";
/*
***********************************************************************
*
*
*
***********************************************************************
*/
void  PressAnyKeyToContinue()
{
   int   fd;

   if ((fd = open("/dev/tty", O_WRONLY)) < 0)
      return;

   write(fd, EnterMsg, sizeof(EnterMsg));
   close(fd);

   getchar();
}

/*
***********************************************************************
*
*
*
***********************************************************************
*/
void  delay(mSec)
uint32   mSec;
{
   while (mSec--)
      ;
}
#endif
#ifdef ENV_OS_NOVELL
/*
***********************************************************************
*
*
*
***********************************************************************
*/
void  FWUnload(void)
{
   fcloseall();

   if (BigBuf)
   {
      free(BigBuf);
      BigBuf = NULL;
   }
}
#endif

/*
***********************************************************************
*
*
*
***********************************************************************
*/
void  SigHandler (int sig)
{
	time_t	now;

	time(&now);

	fprintf(logFile, "\nmfw(%u): signal %d received on\n%s", getpid(), sig,
		ctime(&now));

	if (TotalErrors)
		fprintf(logFile, "mfw(%u):\n******Total errors: %ld.\n",
				getpid(), TotalErrors);

   exit(1);
}


/*
***********************************************************************
*
* GenInitialAndInc
*
***********************************************************************
*/
GenInitialAndInc(void)
{
   Initial = Rand32();

   do
   {

      Increment = Rand32();
   }
   while (Increment < 2);
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
LogMismatch(
char  *file, 
long  blockNum,
int   index,
long  fileDatum,
long  fillDatum)
{
   time_t   tim;

   time(&tim);
   fprintf(logFile, "***%s: mismatch on %s\n"
   	"***time: %s"
      "***blockNum: 0x%08lx, index: 0x%04x, "
		"fileDatum: 0x%08lx, fillDatum: 0x%08lx\n", ProgName,
      file, ctime(&tim), blockNum, index, fileDatum, fillDatum);

	fprintf(logFile, "***Initial: %d (0x%x), Increment: %d (0x%x)\n",
		Initial, Initial, Increment, Increment);


#ifdef ENV_OS_NOVELL
   Breakpoint(BreakOnMismatch);
#endif
}


#if  !defined(ENV_OS_HPUX)
/*
***********************************************************************
*
* 
*
***********************************************************************
*/
void  IOVInit(void)
{
   int   len;
   int   i;
   int   iovNum;
   char  *tmp;
   long  numToAlloc;

   len = BigBufSize / MAXIOVs;

   numToAlloc = BigBufSize;

   /* free any previous vectors */
   for (i = 0; i < MAXIOVs; i ++)
   {
		if (IOVs[i].iov_base != 0)
			free(IOVs[i].iov_base);
   }

   tmp = malloc(((rand() % 211) + 1) * 64);

   NumIOVs = 0;
   for (i = 0; i < MAXIOVs && numToAlloc != 0; i ++)
   {
      iovNum = IOVScramble[i];

      if (i == MAXIOVs - 1)
      {
         len = numToAlloc;
      }
      else
         len = (rand() % numToAlloc) + 1;

      if ((IOVs[iovNum].iov_base = malloc(len)) == NULL)
      {
         fprintf(stderr, "%s: cannot malloc(%d) for IOVs[%d]\n", ProgName,
            len, iovNum);
         exit(1);
      }
      IOVs[iovNum].iov_len = len;

      numToAlloc -= len;

      NumIOVs++;
   }

   free(tmp);

#if 0
   for (i = 0; i < NumIOVs; i ++)
   {
      printf("IOVs[%d].iov_base: 0x%08x, .iov_len: %d\n",
         i, IOVs[i].iov_base, IOVs[i].iov_len);
   }
#endif

}
#endif

/*
***********************************************************************
*
* 
*
***********************************************************************
*/
Usage(
int multi)
{
	if (multi)
		fprintf(stderr, "%s [-options] basePath fileSizeIn512ByteBlocks\n", ProgName);
	else
		fprintf(stderr, "%s [-options] fileSizeIn512ByteBlocks file... \n", ProgName);


	fprintf(stderr, "Compiled under ");
#if	defined (ENV_OS_3_2)
	fprintf(stderr, "AIX 3.2");
#elif defined (ENV_OS_3_1)
	fprintf(stderr, "AIX 3.1");
#else
	fprintf(stderr, "Unknown!!!");
#endif

	fprintf(stderr, "\n");

#ifdef ENV_OS_NOVELL
   fprintf(stderr, "B\tBreakpoint on mismatch.\n");
#endif
   fprintf(stderr, "w\tWrite file%s.\n", multi ? "s" : "");
   fprintf(stderr, "W\tWrite %sfile%s, then read to verify.\n",
		multi ? "all " : "", multi ? "s" : "");
   fprintf(stderr, "r\tRandom read.\n");
   fprintf(stderr, "e n\tMax errors per file before continuing [%ld].\n",
		MaxErrors);
   fprintf(stderr, "{ao} file\tappend/overwrite stderr to file.\n");
   fprintf(stderr, "b n\tSet buffer size [16384].\n");
   fprintf(stderr, "s n\tSet random generator seed to n [0].\n");

	if (multi)
	{
		fprintf(stderr, "n n\tSubdir depth, >= 1 [1].\n");
		fprintf(stderr, "f n\tNumber of files to create in each subdir, "
			">= 1 [1].\n");
		fprintf(stderr, "d n\tNumber of subdirs, >=1 [1].\n");
	}
   fprintf(stderr, "v\tVerbose.\n");
   fprintf(stderr, "j n\tjump to block n.\n");
   fprintf(stderr, 
		"l\tlog times. Waits until no pending I/Os and no dirty cache blocks.\n");
   fprintf(stderr, "p\tWait for any key before running.\n");
   fprintf(stderr,
		"D p\tPrefix p to directory names (so >1 procs can be run) [""].\n");
   fprintf(stderr,
		"F p\tPrefix p to file names (so >1 procs can be run per dir) [""].\n");
   fprintf(stderr, "I\tLoop forever.\n");
   fprintf(stderr, "i\tPattern is block number.\n");
   fprintf(stderr, "R\tuse random numbers in ranges specified by -{nfd} and fileSize.\n");
   fprintf(stderr, "N\tfill longs in file with ascending sequence.\n");
   fprintf(stderr, "x\tuse random iovs to read/write file.\n");
   fprintf(stderr, "V\tverbosish output... less than -v.\n");
   fprintf(stderr, "T n\tmax Total errors allowed before exit [%ld].\n",
      MAXTotalErrors);
   fprintf(stderr, "X\tunbuffer stdout.\n");
   fprintf(stderr, "c n\tset random sleep chance in %% to n [%lu].\n",
      RandomSleepChance);
   fprintf(stderr, "t n\tset max random sleep time in mSec to n [%lu].\n",
      RandomSleepTime);
   if (multi)
      fprintf(stderr, "q\tRead file immediately after writing.\n");

   fprintf(stderr, "\nDefault is to read sequentially.\n");

   exit(1);
}

#if  !defined(ENV_OS_HPUX)
/*
***********************************************************************
*
* 
*
***********************************************************************
*/
int   DoWriteV(
int   fd,
char  *buf,
int   num)
{
   int   i;
   struct iovec   *iov;

	IOVInit();

   iov = IOVs;
   for (i = 0; i < NumIOVs; i++, iov++)
   {
      memcpy(iov->iov_base, buf, iov->iov_len);
      buf += iov->iov_len;
   }

   return (writev(fd, IOVs, NumIOVs));
}
#endif

#if  !defined(ENV_OS_HPUX)
/*
***********************************************************************
*
* 
*
***********************************************************************
*/
int   DoReadV(
int   fd,
char  *buf,
int   num)
{
   int   numRead;
   int   numToMove;
   int   i;
   struct iovec   *iov;
   int   len;

	IOVInit();

   numRead = readv(fd, IOVs, NumIOVs);

   if (numRead < 0)
      return (numRead);

   iov = IOVs;
   numToMove = numRead;
   for (i = 0; numToMove && i < NumIOVs; i++, iov++)
   {
      if (iov->iov_len > numToMove)
         len = numToMove;
      else
         len = iov->iov_len;


      memcpy(buf, iov->iov_base, len);

      buf += iov->iov_len;
   
      numToMove -= len;
   }

   return (numRead - numToMove);
}
#endif


/*
***********************************************************************
*
* 
*
***********************************************************************
*/
void  FlushBuf(
int   fd)
{
   int         rc;

   if (BytesInBigBuf)
   {
      if (!WriteV)
      {
         if ((rc = write(fd, BigBuf, BytesInBigBuf)) != BytesInBigBuf)
         {
            fprintf(logFile, "%s: write failed in FlushBuf() :", ProgName);
            perror("");
            exit(1);
         }
      }
#if  !defined(ENV_OS_HPUX)
      else
      {
         if ((rc = DoWriteV(fd, BigBuf, BytesInBigBuf)) != BytesInBigBuf)
         {
            fprintf(logFile, "%s: DoWriteV failed in FlushBuf() :", ProgName);
            perror("");
            exit(1);
         }
      }
#endif
   }

   BytesInBigBuf = 0;
   BigBufp = BigBuf;
}

/*********************************************************************\
*
*
*
\*********************************************************************/
void  WriteBlock(
int   fd,
long  blockNum,
char  *data)
{
   long  *p;
   long  value;
   int   i;

   if (BigBufp >= BigBuf + BigBufSize)
   {
      if (Verbose)
         printf("blockNum: %ld\r", blockNum);

      FlushBuf(fd);
   }

   memcpy(BigBufp, data, BLOCKSize);


   BytesInBigBuf += BLOCKSize;
   BigBufp += BLOCKSize;
}



/*********************************************************************\
*
*
*
\*********************************************************************/
void  FillAndWriteBlock(
int      fd,
uint32   blockNum,
char     *file)
{
   char  id[BLOCKSize];

   if (IdentifyBlocks)
      FillIDBlock(id, blockNum, file);
   else
		FillBlock(id, blockNum);

   WriteBlock(fd, blockNum, id);
}


/*********************************************************************\
*
*
*
\*********************************************************************/
FunctionalWrite(
char  *file,
long  size)
{
   FILE        *fp;
   int         fd;
   long        blockNum;
   long        value;
   char        id[BLOCKSize];
   TimeThing   wrStartTime;
   TimeThing   wrEndTime;
   double      secs;



   if ((fp = fopen(file, "wb")) == NULL)
   {
      fprintf(logFile, "cannot open %s to write:", file);
      perror("");
      exit(1);
   }
   fd = fileno(fp);

   if (LogFlag == 2)
   {
   	TimeInit(&wrStartTime);
   	TimeInit(&wrEndTime);
      (void)GetTime(&wrStartTime);
   }

   for (blockNum = 0; blockNum < size; blockNum++)
   {
      FillAndWriteBlock(fd, blockNum, file);
      if (RandomSleepChance && ((Rand32() % 100) + 1) < RandomSleepChance)
         delay((Rand32() % RandomSleepTime) + 1);
   }

   FlushBuf(fd);

   if (LogFlag == 2)
   {
      (void)GetTime(&wrEndTime);
		ElapsedTime(wrEndTime, wrStartTime, secs);
      if (secs != 0.0)
         printf("Wr: %s, time: %f, KB/s: %f\n",
            file, secs, (size / 1024) / secs);
      else
         printf("Wr: %s, time: %f, KB/s: cannotCompute\n", file, secs);
   }


   if (Verbose)
      printf("\n");

   fclose (fp);
}

/*
***********************************************************************
*
* 
*
***********************************************************************
*/
ReadBuf(
int   fd,
long  blockNum)
{
   long        offset;

   if (lseek(fd, offset = blockNum * BLOCKSize, SEEK_SET) != offset)
   {
      fprintf(logFile, "%s: cannot lseek(): ", ProgName);
      perror("");
      exit(1);
   }

   if (!WriteV)
   {
      if ((BytesInBigBuf = read(fd, BigBuf, BigBufSize)) < 0)
      {
         fprintf(logFile, "%s: cannot read(): ", ProgName);
         perror("");
         exit(1);
      }
   }
#if  !defined(ENV_OS_HPUX)
   else
   {
      if ((BytesInBigBuf = DoReadV(fd, BigBuf, BigBufSize)) < 0)
      {
         fprintf(logFile, "%s: cannot DoReadV(): ", ProgName);
         perror("");
         exit(1);
      }
   }
#endif

   BigBufp = BigBuf;

   return (BytesInBigBuf);
}

/*********************************************************************\
*
*
*
\*********************************************************************/
long  CompareBuf(
uint32   blockNum,
char     *file)
{
   long     *p, *idp;
   int      i, j, k, l;
   char     id[BLOCKSize];
   long     errors = 0;
   
   p = (long *)BigBuf;
   for (i = BytesInBigBuf/BLOCKSize; i; i--, blockNum++)
   {
      if (IdentifyBlocks)
      {
         FillIDBlock(id, blockNum, file);
      }
      else
         FillBlock(id, blockNum);

      for (j = 0, idp = (long *)id; j < BLOCKSize/sizeof(long); j++, p++, idp++)
      {
         if (*p != *idp)
         {
            LogMismatch(file, blockNum, j, *p, *idp);
            if (++errors >= MaxErrors)
               goto out;
         }
      }
   }

out:

   return (errors);
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
SequentialFunctionalRead(
char  *file,
long  size,
long  blockNum)
{
   int         fd, i, j;
   long        value;
   long        *p;
   long        errors = 0;
   FILE        *fp;
   TimeThing   rdStartTime;
   TimeThing   rdEndTime;
   double      secs;

   if ((fp = fopen(file, "rb")) == NULL)
   {
      fprintf(logFile, "cannot open %s to read:", file);
      perror("");
      exit(1);
   }
   fd = fileno(fp);

   if (lseek(fd, blockNum * BLOCKSize, SEEK_SET) != blockNum * BLOCKSize)
   {
      fprintf(logFile, "cannot seek in %s to read:", file);
      perror("");
      exit(1);
   }

   if (LogFlag == 2)
   {
   	TimeInit(&rdStartTime);
   	TimeInit(&rdEndTime);
      (void)GetTime(&rdStartTime);
   }

   while (blockNum < size)
   {
      if (Verbose)
         printf("blockNum: %ld\r", blockNum);

      if (ReadBuf(fd, blockNum) == 0)
      {
         fprintf(logFile, "%s: EOF reached on %s.\n", ProgName, file);
         exit(1);
      }

      if ((errors = CompareBuf(blockNum, file)) > MaxErrors)
         goto out;

      if (RandomSleepChance && RandomSleepChance < ((Rand32() % 100) + 1))
         delay((Rand32() % RandomSleepTime) + 1);

      blockNum += BytesInBigBuf / BLOCKSize;
   }

   if (LogFlag == 2)
   {
      (void)GetTime(&rdEndTime);
		ElapsedTime(rdEndTime, rdStartTime, secs);
      if (secs != 0.0)
         printf("Rd: %s, time: %f, KB/s: %f\n",
            file, secs, (size / 1024) / secs);
      else
         printf("Rd: %s, time: %f, KB/s: cannotCompute\n", file, secs);
   }

out:

   if (Verbose)
      printf("\n");

   if (errors)
	{
      fprintf(logFile, "\n%d mismatch%s\n", errors, (errors != 1) ? "es" : "");
		TotalErrors++;
	}

   fclose (fp);
}

/*********************************************************************\
*
*
*
\*********************************************************************/
FunctionalWriteThenRead(
char  *file,
long  size)
{
   FILE  *fp;
   int   fd;
   long  blockNum;
   long  value;
   char  id[BLOCKSize];
	long	*p;
	uint	i, j, errors = 0;
	long	tBlockNum;

#if 0
   if ((fp = fopen(file, "w+")) == NULL)
   {
      fprintf(logFile, "cannot open %s to write:", file);
      perror("");
      exit(1);
   }
   fd = fileno(fp);
#endif

	if ((fd = open(file, O_CREAT | O_TRUNC | O_RDWR, 0666)) == -1)
   {
      fprintf(logFile, "cannot open %s to write:", file);
      perror("");
      exit(1);
   }

   for (blockNum = 0; blockNum < size; blockNum++)
   {
      FillAndWriteBlock(fd, blockNum, file);

      if (RandomSleepChance && ((Rand32() % 100) + 1) < RandomSleepChance)
         delay((Rand32() % RandomSleepTime) + 1);
   
      FlushBuf(fd);

      if (ReadBuf(fd, blockNum) == 0)
      {
         fprintf(logFile, "%s: EOF reached on %s.\n", ProgName, file);
         exit(1);
      }

      if ((errors = CompareBuf(blockNum, file)) > MaxErrors)
         goto out;

      if (RandomSleepChance && RandomSleepChance < ((Rand32() % 100) + 1))
         delay((Rand32() % RandomSleepTime) + 1);
   }

out:

   if (Verbose)
      printf("\n");

   if (errors)
	{
      fprintf(logFile, "\n%d mismatch%s\n", errors, (errors != 1) ? "es" : "");
		TotalErrors++;
	}

   close(fd);
}

/*
***********************************************************************
*
*
*
***********************************************************************
*/
RandomFunctionalRead(
char  *file,
long  num)
{
   int   fd, j;
   long  blockNum;
   long  value, tmp;
   long  errors = 0;
   long  fileSize;
   long  numBlocks;
   long  *p;
   FILE  *fp;

   if ((fp = fopen(file, "r+b")) == NULL)
   {
      fprintf(logFile, "cannot open %s to read:", file);
      perror("");
      exit(1);
   }
   fd = fileno(fp);

   if ((fileSize = filelength(fd)) <= 0)
   {
      fprintf(logFile, "fileSize of %s is 0x%08lx:", file, fileSize);
      exit(1);
   }

   numBlocks = fileSize / BLOCKSize;
   BigBufSize = BLOCKSize;
   
   while (num-- > 0)
   {
      do
      {
         blockNum = Rand32() % numBlocks;
      }
      while (blockNum < 0 || blockNum >= fileSize);

      if (Verbose)
         printf("blockNum: 0x%08lx, remaining: %ld \r", blockNum, num);

      ReadBuf(fd, blockNum);

      errors = CompareBuf(blockNum, file);

      if (errors > MaxErrors)
         break;
   }

   if (Verbose)
      printf("\n");

   if (errors)
	{
		TotalErrors++;
      fprintf(logFile, "\n%d mismatches\n", errors);
	}

   fclose (fp);
}

/*
***********************************************************************
*
* 
*
***********************************************************************
*/
void	FWrite(
int	readWriteFlag,
char	*file,
long	size,
long	blockNum,
long	count)
{
	BytesInBigBuf = 0;
	BigBufp = BigBuf;
	GenInitialAndInc();

	switch (readWriteFlag)
	{
		case FUNCWriteThenRead:
			if (Verbose || Verbosish)
				printf("wr/rd: file: %s, count: %u, pid: %d\n",
					file, count, getpid());
                                       /*	FunctionalWriteThenRead(file, size);*/
			FunctionalWrite(file, size);

#if 1

			if (Verbose || Verbosish)
				printf("rd: file: %s, count: %u, pid: %d\n",
					file, count, getpid());
			SequentialFunctionalRead(file, size, blockNum);
#endif

			break;

		case FUNCRead:
			if (Verbose || Verbosish)
				printf("rd: file: %s, count: %u, pid: %d\n",
					file, count, getpid());
			SequentialFunctionalRead(file, size, blockNum);
			break;

		case FUNCWrite:
			if (Verbose || Verbosish)
				printf("wr: file: %s, count: %u, pid: %d\n",
					file, count, getpid());
			FunctionalWrite(file, size);
			break;

		case FUNCRandRead:
			if (Verbose || Verbosish)
				printf("rrd: file: %s, count: %u, pid: %d\n",
					file, count, getpid());
			RandomFunctionalRead(file, size);
			break;
	}
}

/*
***********************************************************************
*
* 
*
***********************************************************************
*/
void	BufInit(void)
{
   if (BigBufSize % BLOCKSize)
   {
      fprintf(stderr, "%s: bufSize: %d not a multiple of %d\n", ProgName,
			BigBufSize, BLOCKSize);
      exit(1);
   }

   if ((BigBufp = BigBuf = malloc(BigBufSize)) == NULL)
   {
      fprintf(logFile, "%s: cannot malloc(&d) BigBuf\n", ProgName, 
			BigBufSize);
      exit (1);
   }
}
/*
***********************************************************************
*
* 
*
***********************************************************************
*/
void	SigInit(void)
{
	int	i;

   for (i = 1; i <= SIGMAX; i++)
	{
		/* skip siggies we canna catch */
		if (i == SIGKILL || i == SIGSTOP || i == SIGCONT || i == SIGTSTP)
			continue;

		if (signal (i, SigHandler) == SIG_ERR)
		{
			fprintf (stderr, "Trap of signal %d failed", i);
			perror (" ");
			exit (1);
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
   int         option;
   int         readWriteFlag = FUNCRead, savedRWF;
   char        basePath[PATH_MAX], path[PATH_MAX + 128], *openMode;
   char        file[PATH_MAX + 128];
   long        size, origSize;
   TimeThing   wrStartTime, wrEndTime;
   TimeThing   rdStartTime, rdEndTime;
   TimeThing   elapsedTime;
   TimeThing   tmpTimer;
   double      Kb, secs;
   extern int  optind;
   extern int  opterr;
   extern char *optarg;
   long        blockNum = 0;
   long        depth, curDepth;
   long        numDirs, dirNum;
   long        numFiles, fileNum;
   long        origDepth = 1;
   long        origNumDirs = 1;
   long        origNumFiles = 1;
   int         originalSeed = 0, seed;
   int         cc;
   DIR         *dir;
   int         verifyAfterWrite = 0;
   int         pause = 0;
   int         infinite = 0;
   uint32      count = 0;
   char        dirPrefix[9];
   char        filePrefix[9];
	int			i;
	long			maxTotalErrors = MAXTotalErrors;
	int			multi = 1;
	char			*options;
   int         randomNums = 0;

   logFile = stderr;

   dirPrefix[0] = filePrefix[0] = '\0';

	basename(argv[0], ProgName);
	multi = !strcmp(ProgName, "mfw");

   options = multi ?
      "VD:F:XrWwa:o:e:s:vb:hlj:d:f:n:piIBqc:t:T:xNRL:" :
      "VD:F:XrWwa:o:e:s:vb:hlj:piIBc:t:T:xNRL:";

   while ((option = getopt(argc, argv, options)) != EOF)
   {
      switch (option)
      {
         case 'R':
            randomNums = 1;
            break;

			case 'N':
				FillNumeric = 1;
				break;

         case 'x':
            WriteV = 1;
            break;

			case 'V':
				Verbosish = 1;
				break;

         case 'D':
            strncpy(dirPrefix, optarg, sizeof(dirPrefix) - 1);
            break;

			case 'F':
				strncpy(filePrefix, optarg, sizeof(filePrefix - 1));
				break;

			case 'T':
				maxTotalErrors = strtol(optarg, &openMode, 0);
				break;

			case 'X':
				if (setvbuf(stdout, NULL, _IONBF, 20))
				{
					printf("rwrt: cannot setvbuf() %s.\n", "stdout");
					exit(1);
				}
				break;

         case 'c':
            RandomSleepChance = strtol(optarg, &openMode, 0);
            break;

         case 't':
            RandomSleepTime = strtol(optarg, &openMode, 0);
            break;

         case 'q':
            readWriteFlag = FUNCWriteThenRead;
            break;

#ifdef ENV_OS_NOVELL
         case 'B':
            BreakOnMismatch = 1;
            break;
#endif

         case 'W':      /* write, then verify w/read */
            verifyAfterWrite = 1;

         case 'w':
            readWriteFlag = FUNCWrite;
            break;

         case 'r':
            readWriteFlag = FUNCRandRead;
            break;

         case 'e':
            MaxErrors = atol(optarg);
            break;

         case 'a': case 'o':
            openMode = (tolower(option) == 'o') ? "w" : "a";
            if ((logFile = freopen(optarg, openMode, stderr)) == NULL)
            {
               printf("rwrt: cannot fopen() %s in mode %s\n",
                  optarg, openMode);
               exit(1);
            }

            if (setvbuf(logFile, NULL, _IONBF, 20))
            {
               printf("rwrt: cannot setvbuf() on %s\n", optarg);
               exit(1);
            }
            break;

         case 'b':
            BigBufSize = strtol(optarg, &openMode, 0);
            break;

         case 's':
            originalSeed = atoi(optarg);
            break;

         case 'v':
            Verbose = 1;
            break;

			case 'L':
				LogFlag = strtol(optarg, &openMode, 0);
				break;

         case 'l':
            LogFlag = 1;
            break;

         case 'j':
            blockNum = strtol(optarg, &openMode, 0);
            break;

         case 'd':
            origNumDirs = strtol(optarg, &openMode, 0);
            break;

         case 'f':
            origNumFiles = strtol(optarg, &openMode, 0);
            break;

         case 'n':
            origDepth = strtol(optarg, &openMode, 0);
            break;

         case 'p':
            pause = 1;
            break;

         case 'i':
            IdentifyBlocks = 1;
            break;

         case 'I':
            infinite = 1;
            break;

         case 'h':
         default:
            Usage(multi);
      }
   }

   if (argc - optind < 2)
   {
      fprintf(stderr, "%s: not enough args\n", ProgName);
      Usage(multi);
   }

	BufInit();

	SigInit();

	TimeInit(&rdStartTime);
	TimeInit(&wrStartTime);
	TimeInit(&rdEndTime);
	TimeInit(&wrEndTime);

#ifdef ENV_OS_NOVELL
   AtUnload(FWUnload);
   atexit(FWUnload);
#endif

   if (multi)
   {
      strcpy(basePath, argv[optind]);
      origSize = strtol(argv[optind + 1], &openMode, 0);
   }
   else
      origSize = strtol(argv[optind++], &openMode, 0);

   if (origSize < blockNum)
   {
      fprintf(stderr, "%s: cannot jump to block num > size.\n", ProgName);
      exit(1);
   }

   if (pause)
      PressAnyKeyToContinue();

   savedRWF = readWriteFlag;

iLoop:

   while (1)
   {
		if (readWriteFlag == FUNCWrite)
			time(&WriteStartTime);

      if (LogFlag == 1)
      {
         if (readWriteFlag == FUNCWrite)
            (void)GetTime(&wrStartTime);
         else
            (void)GetTime(&rdStartTime);
      }

      seed = originalSeed;
      srand(seed++);

		if (multi)
		{
         numDirs = (randomNums) ? Rand32Range(origNumDirs) + 1 : origNumDirs;

			for (dirNum = 0; dirNum < numDirs; dirNum++)
			{
				sprintf(path, "%s", basePath);

            depth = (randomNums) ? Rand32Range(origDepth) + 1 : origDepth;

				for (curDepth = 0; curDepth < depth; curDepth++)
				{
					sprintf(path + strlen(path), "/%s%d-%d.dir",
						dirPrefix, dirNum, curDepth);

					if (strlen(path) > PATH_MAX)
					{
						fprintf(stderr, "%s: path too long\n", ProgName);
						exit(1);
					}

					if (readWriteFlag == FUNCWrite ||
						readWriteFlag == FUNCWriteThenRead)
					{
						if (dir = opendir(path))
							closedir(dir);
						else if (cc = MkDir(path, 0777))
						{
							if (errno != EEXIST)
							{
								fprintf(stderr, "%s: cannot mkdir(%s), cc: 0x%08x",
									ProgName, path, cc);
								perror(" ");
								exit(1);
							}
						}
					}

               numFiles = (randomNums) ? Rand32Range(origNumFiles) + 1 :
                  origNumFiles;

					for (fileNum = 0; fileNum < numFiles; fileNum++)
					{
						sprintf(file, "%s/%s%d-%d-%d.fil",
								path, filePrefix, dirNum, curDepth, fileNum);

						if (strlen(file) > PATH_MAX)
						{
							fprintf(stderr, "%s: path too long\n", ProgName);
							exit(1);
						}

						srand(seed++);

                  size = (randomNums) ? Rand32Range(origSize) + 1 : origSize;

						FWrite(readWriteFlag, file, size, blockNum, count);

                  if (TotalErrors >= maxTotalErrors)
                     goto maxedOut;


					}  /* fileNum */
				}     /* curDepth */
			}        /* dirNum */
		}
		else
		{
         for (fileNum = optind; fileNum < argc; fileNum++)
         {
			   srand(seed++);

            size = (randomNums) ? Rand32Range(size) + 1 : origSize;

			   FWrite(readWriteFlag, argv[fileNum], size, blockNum, count);
         }
		}
   
      if (LogFlag == 1)
      {
#ifdef ENV_OS_NOVELL
         while (NDirtyBlocks || DiskIOsPending)
            delay(100);
#endif

         if (readWriteFlag == FUNCWrite)
            (void)GetTime(&wrEndTime);
         else
            (void)GetTime(&rdEndTime);
      }

      if (!verifyAfterWrite || readWriteFlag != FUNCWrite)
         break;

      readWriteFlag = FUNCRead;
   }

   if (LogFlag == 1)
   {
      Kb = ((double)origSize * (double)origNumDirs * (double)origNumFiles *
			(double)origDepth * (double)BLOCKSize) / (double)1024;

      printf("Files: %d, dirs: %d, depth: %d, origSize: %d, ",
         origNumFiles, origNumDirs, origDepth, origSize);
      printf("bufferSize: %lu\n", BigBufSize);

		ElapsedTime(wrEndTime, wrStartTime, secs);
      printf("Write: Kb: %f, secs: %f, Kb/s: %f\n", Kb, secs,
			secs != (double)0 ? Kb / secs : (double)0);

		ElapsedTime(rdEndTime, rdStartTime, secs);
      printf("Read : Kb: %f, secs: %f, Kb/s: %f\n", Kb, secs, 
			secs != (double)0 ? Kb / secs : (double)0);
   }

   count++;

   if (infinite && (TotalErrors < maxTotalErrors))
	{
		readWriteFlag = savedRWF;
      originalSeed++;
      goto iLoop;
	}

maxedOut:

	if (TotalErrors)
		fprintf(logFile, "\n******Total errors: %ld.\n", TotalErrors);

   exit(TotalErrors != 0);
}
