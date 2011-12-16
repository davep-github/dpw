#include <stdio.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/types.h>
#include <time.h>
#include <errno.h>
#if   defined(ENV_OS_AIX)
#include <sys/flock.h>
#endif
#include <unistd.h>
#include "environ.h"

typedef unsigned long   uint32;
typedef unsigned char   byte;

#define  MAX_OFFS       (100)
#define  MAX_LOOPS      (100)
#define  MAX_FILE       (800000)
#define  abs(x)         ((x) < 0 ? (-x) : (x))
#define  nneg(x)        ((x) & 0x7fffffffL)
#define  eprintf(err,str)   { fprintf(LogFile, "rwrt: %s", str); if (err) exit(err); }
#define  MaxFilesInc    (1);

#ifdef ENV_OS_NOVELL
#define  getpid()       GetThreadID()
extern uint32  NDirtyBlocks;
extern uint32  DiskIOsPending;
#endif

#if   defined(ENV_OS_AIX)
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/shm.h>
#include <unistd.h>

byte  **MemMapAddr;
int   MemMapWrite;
#endif

#if   defined(ENV_OS_AIX)
#define  LockFunc lockfx
#elif defined(ENV_OS_HPUX)
#define  LockFunc fcntl
#else
#error   !!! define locking function for your OS !!!
#endif

extern long lseek();

int   Pause = 0;
int   MaxFiles = 2;
int   MaxOffs  = MAX_OFFS;
long  MaxFile  = MAX_FILE;
int   MaxLoops = MAX_LOOPS;
int   Echo = 0;
int   EchoLots = 0;
int   LogTime = 1;
int   Interleave = 0;
char  **FileNames;
FILE  *LogFile;
FILE  **fp;
int   *fd;
long  *Offs;
int   *Data;
int   errors = 0;
long  NumPerFile = 1;
long  IthFile = 0;
long  Offset = 0;
int   OnlyRead = 0;
char  *ProgName = "rwrt";

#ifdef ENV_OS_NOVELL
RWRTUnload()
{
   if (errors)
   {
      printf("errors: %d\n\r", errors);
      errors = 0;
   }

   fcloseall();

   if (Data)
   {
      free(Data);
      Data = NULL;
   }

   if (Offs)
   {
      free(Offs);
      Offs = NULL;
   }

   if (fd)
   {
      free(fd);
      fd = NULL;
   }

   if (fp)
   {
      free(fp);
      fp = NULL;
   }

   if (FileNames)
   {
      free(FileNames);
      FileNames = NULL;
   }
}
#endif

#ifndef  ENV_OS_NOVELL

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

   if (sig == SIGUSR1)
   {
      if (signal (SIGUSR1, SigHandler) == SIG_ERR)
      {
         fprintf (stderr, "SIGINT re-Trap failed.\n");
         exit (1);
      }

      Pause = 1;
      return;
   }

	time(&now);

	fprintf(LogFile, "\nrwrt(%u): signal %d received on\n%s", getpid(), sig,
		ctime(&now));

   if (errors)
      fprintf(LogFile, "(%u)errors: %u\n\r", getpid(), errors);

   exit(1);
}

/*
***********************************************************************
*
*
*
***********************************************************************
*/
DoWrite(
int   fdno,
int   dataIndex,
long  off,
int   *data)
{
   if (EchoLots == 1)
      printf("%3d:%08d @ %08lx\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b",
         fdno, dataIndex, off);
   else if (EchoLots == 2)
      printf("%3d:%08d @ %08lx\n", fdno, dataIndex, off);

   if (!fdno)
      data[dataIndex] = rand();

	if (OnlyRead)
		return;

   if (lseek(fd[fdno], off, 0) != off)
   {
      PError("\n\rerror seeking to write");
      exit(1);
   }

   if (MemMapWrite)
   {
#if   defined(ENV_OS_AIX)
      memcpy(MemMapAddr[fdno] + off, (char *)&data[dataIndex],
         sizeof (int));

      if (fsync(fd[fdno]) != 0)
      {
         perror("fsync failed");
         exit(1);
      }
#else
      eprintf(1, "MemMapWrite is not supported in this environment.\n");
#endif

   }
   else if (write(fd[fdno], (char *)&data[dataIndex], sizeof (int)) != sizeof (int))
   {
      PError("\n\rwrite error");
      exit(1);
   }
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
DoRead(
int   fdno,
int   dataIndex,
long  off,
int   data)
{
   int         tmp;
   time_t      tim;

   if (EchoLots == 1)
      printf("%3d:%08d @ %08lx\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b",
         fdno, dataIndex, off);
   else if (EchoLots == 2)
      printf("%3d:%08d @ %08lx\n", 
         fdno, dataIndex, off);

   if (lseek(fd[fdno], off, 0) != off)
   {
      PError("\n\rerror seeking to read");
      exit(1);
   }

   if (read(fd[fdno], (char *)&tmp, sizeof(int)) != sizeof(int))
   {
      PError("\n\rread error");
      exit(1);
   }

   if (tmp != data)
   {
      time(&tim);
      fprintf(LogFile, "%sfile:%s,offset:0x%lx,file:0x%x,data:0x%x\n",
            ctime(&tim), FileNames[fdno],
         off, tmp, data);

      if (++errors > 5)
      {
         fprintf(LogFile, "\n\raborted due to errors\n");
         exit(-1);
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
NovellInit()
{
   return (0);
}
/*
***********************************************************************
*
*
*
***********************************************************************
*/
main(argc, argv)
int   argc;
char  *argv[];
{
   long        ltmp;
   int         j, tmp, k, l, nofds, fdno;
   unsigned    seed;
   int         pid, opt;
   extern int  optind;
   extern char *optarg;
   extern int  opterr;
   char        *optString = "rN:I:S:yXEes:l:L:f:o:O:a:A:d:n:qQipwkhHm";
   time_t      startTime, endTime, tim;
   char        *tmps, *openMode = NULL;
   int         key;
   int         waitForZeroPendings = 0, doRegionLocking = 0;
   struct flock   sentFlock;

   sentFlock.l_type = F_WRLCK;
   sentFlock.l_whence = SEEK_SET;
   sentFlock.l_len = sizeof(int);
#if   defined(ENV_OS_AIX)
   sentFlock.l_sysid = sentFlock.l_vfs =
#endif
   sentFlock.l_pid = 0;

   if (signal (SIGINT, SigHandler) == SIG_ERR)
   {
      fprintf (stderr, "SIGINT Trap failed.\n");
      exit (1);
   }

   if (signal (SIGUSR1, SigHandler) == SIG_ERR)
   {
      fprintf (stderr, "SIGUSR1 Trap failed.\n");
      exit (1);
   }

   LogFile = stderr;

   if ((Offs = (long *)calloc(MaxOffs, sizeof(long))) == NULL)
      eprintf(1, "cannot calloc() Offs\n");

   if ((Data = (int *)calloc(MaxOffs, sizeof(int))) == NULL)
      eprintf(1, "cannot calloc() Data\n");

   if ((fd = (int *)calloc(MaxFiles, sizeof(int))) == NULL)
      eprintf(1, "cannot calloc() fd\n");

   if ((fp = (FILE **)calloc(MaxFiles, sizeof(FILE *))) == NULL)
      eprintf(1, "cannot calloc() fp\n");

   if ((FileNames = (char **)calloc(MaxFiles, sizeof(char *))) == NULL)
      eprintf(1, "cannot calloc() FileNames\n");

#ifdef   ENV_OS_AIX
   if ((MemMapAddr = (byte **)calloc(MaxFiles, sizeof(byte *))) == NULL)
      eprintf(1, "cannot calloc() MemMapAddr\n");
#endif

#ifdef ENV_OS_NOVELL
   AtUnload(RWRTUnload);
   atexit(RWRTUnload);
#endif

   opterr = 1;
   while ((opt = getopt(argc, argv, optString)) != EOF)
   {
      switch (opt)
      {
         case 'm':
#if   defined(ENV_OS_AIX)
            MemMapWrite = 1;
#else
            fprintf(LogFile, "MemMapWrite is not supported in this environment.\n",
               ProgName);
            exit(1);
#endif
            break;

         case 'r':
            OnlyRead = 1;
            break;

			case 'N':
				NumPerFile = strtoul(optarg, &tmps, 0);
				break;

			case 'I':
				IthFile = strtoul(optarg, &tmps, 0);
				break;

			case 'S':
				Offset = strtoul(optarg, &tmps, 0);
				break;

         case 'y':
            EchoLots = Echo = 2;
            break;

         case 'X':   /* unbuf stdout */
            /*
            // NW C needs non zero buffer length
            */
            if (setvbuf(stdout, NULL, _IONBF, 20))
            {
               fprintf(stderr, "rwrt: cannot setvbuf() stdout.\n");
               exit(1);
            }
            if (setvbuf(stderr, NULL, _IONBF, 20))
            {
               fprintf(stderr, "rwrt: cannot setvbuf() stderr.\n");
               exit(1);
            }
            break;

         case 'd':
            MaxOffs = atoi(optarg);
            if ((Offs = (long *)realloc(Offs, MaxOffs * sizeof(long))) == NULL)
               eprintf(1, "cannot realloc() Offs\n");

            if ((Data = (int *)realloc(Data, MaxOffs * sizeof(int))) == NULL)
               eprintf(1, "cannot realloc() Data\n");

            break;

         case 'e':
            Echo = 1;
            break;

         case 'E':
            EchoLots = Echo = 1;
            break;

         case 's':
            seed = atoi(optarg);
            break;

         case 'l': case 'L':
            MaxLoops = atoi(optarg);
            break;

         case 'f':
            sscanf(optarg, "%ld", &MaxFile);
            break;

         case 'o': case 'a':
         case 'O': case 'A':  /* dumbshit Novell upper cases everting */
            openMode = (opt == 'o' || opt == 'O') ? "w" : "a";
            if (openMode && (LogFile = freopen(optarg, openMode, stderr)) == NULL)
            {
               printf("rwrt: cannot freopen() %s in mode %s\n",
                  optarg, openMode);
               exit(1);
            }

            /*
            // NW C needs non zero buffer length
            */
            if (setvbuf(LogFile, NULL, _IONBF, 20))
            {
               printf("rwrt: cannot setvbuf() %s.\n", optarg);
               exit(1);
            }

            break;

         case 'q': case 'Q':
            LogTime = 0;
            break;

         case 'i':
            Interleave = 1;
            break;

         case 'p':
            Pause = 1;
            break;

         case 'w':
            waitForZeroPendings = 1;
            break;

         case 'k':
            doRegionLocking = 1;
            break;

         case 'H':
         case 'h':
            PrintHelp();
            exit(1);
            break;

         default:
            PrintHelp();
            exit(1);
            break;
      }
   }

   if (Pause)
   {
      Pause = 0;
      PressAnyKeyToContinue();
   }

   pid = getpid();
   for (nofds = 0; optind < argc; optind++)
   {
      if ((fd[nofds] = open(argv[optind], O_RDWR | O_CREAT, 0666)) < 0)
      {
         fprintf(LogFile, "cannot open %s", argv[optind]);
         PError("");
         printf("cannot open %s\n", argv[optind]);
         exit(1);
      }

      FileNames[nofds] = argv[optind];

      if (MemMapWrite)
      {
         long  numBytes;
#if   defined(ENV_OS_AIX)
         numBytes = Offset + (((MaxFile * NumPerFile) + IthFile) * sizeof(int));
#if 0
         /* we want to make sure the file size is as large as */
         /* the largest offset we will write to. */
         if (lseek(fd[nofds], numBytes - 1, SEEK_SET) != numBytes - 1)
         {
            fprintf(LogFile, "%s: seek failed in main() :",
               ProgName);
            perror("");
            exit(1);
         }

         if (write(fd[nofds], "", 1) != 1)
         {
            fprintf(LogFile, "%s: write failed in FunctionalWrite() :",
               ProgName);
            perror("");
            exit(1);
         }
#endif

         MemMapAddr[nofds] = shmat(fd[nofds], NULL, SHM_MAP);
         if (MemMapAddr[nofds] == (byte *)-1)
         {
            fprintf(LogFile, "%s: shmget failed in FunctionalWrite() :", ProgName);
            perror("");
            exit(1);
         }
#else
         fprintf(LogFile, "MemMapWrite is not supported in this environment.\n",
            ProgName);
         exit(1);
#endif
                     
      }

      nofds++;
      if (nofds >= MaxFiles)
      {
         MaxFiles += MaxFilesInc;
         if ((fd = (int *)realloc(fd, MaxFiles * sizeof(int))) == NULL)
            eprintf(1, "cannot realloc() fd\n");

         if ((fp = (FILE **)realloc(MaxFiles, sizeof(FILE *))) == NULL)
            eprintf(1, "cannot realloc() fp\n");

         if ((FileNames = (char **)realloc(FileNames, MaxFiles * sizeof(char *))) == NULL)
            eprintf(1, "cannot realloc() FileNames\n");

#ifdef   ENV_OS_AIX
         if ((MemMapAddr = (byte **)realloc(MemMapAddr, MaxFiles * sizeof(byte *))) == NULL)
            eprintf(1, "cannot realloc() FileNames\n");
#endif
      }
   }

   if (!nofds)
      eprintf(1, "no files could be opened.\n");

   if (LogTime)
   {
      time(&startTime);
      fprintf(LogFile, "(%u)seed: %d, Start time:%s", getpid(), seed, ctime(&startTime));
   }

   srand(seed);

   key = 0;
   for (l = 0; l < MaxLoops && key != 0x1b; l++)
   {
#ifdef   ENV_OS_DOS
      if (kbhit())
         if ((key = getch()) == 0x1b)
            break;
#endif

      if (Pause)
      {
         Pause = 0;
         PressAnyKeyToContinue();
      }

      if (Echo == 1)
         printf("%c(%d)l: %6d, gen addrs, ", errors ? '*' : ' ', pid, l);
      else if (Echo == 2)
         printf("%c(%d)l: %6d, gen addrs\n", errors ? '*' : ' ', pid, l);

      for (j = 0; j < MaxOffs; j++)
      {
         if (EchoLots == 1)
            printf("%06d\b\b\b\b\b\b", j);
         else if (EchoLots == 2)
            printf("%06d\n", j);


         while (1)
         {
            ltmp = (long)rand() * (long)rand();
            Offs[j] = Offset + 
               ((((nneg(ltmp) % MaxFile) * NumPerFile) + IthFile) *
               sizeof(int));
            for (k = 0; k < j; k++)
               if (Offs[j] == Offs[k])
                  break;
            if (k >= j)
               break;
         }
      }

      if (Echo == 1)
         printf("write data, ");
      else if (Echo == 2)
         printf("write data\n");

      if (Interleave)
      {
         for (j = 0; j < MaxOffs; j++) {
            for (fdno = 0; fdno < nofds; fdno++) {
               /* lock the region (if requested).
                  the region consists of 1 integer size beginning at Offs[j] */
               if (doRegionLocking) {
                  while (1) {
                     /* Now attempt the reqd lock! */
                     sentFlock.l_start = Offs[j];
                     sentFlock.l_type = F_WRLCK;

                     if ((sentFlock.l_len != sizeof(int)) || (sentFlock.l_whence != SEEK_SET)) {
                        fprintf(stderr, "Values of SentFlock have changed!\n");
                        exit(1);
                     }

                     if (LockFunc(fd[fdno], F_SETLKW, &sentFlock) < 0) {
                        fprintf(stderr, "\nLock Request failed!\n");
                     }
                     else break;
                     if (errno == EDEADLK) {
                        fprintf(stderr, "Reported Possible Dead-Lock, will retry...\n");
                        continue;
                     }
                     else {
                        fprintf(stderr, "\nErrno: %x\n", errno);
                        exit(1);
                     }
                  }
               }
               DoWrite(fdno, j, Offs[j], Data);
            }
         }
      }
      else
      {
         for (fdno = 0; fdno < nofds; fdno++) {
            for (j = 0; j < MaxOffs; j++) {
               /* lock the region (if requested).
                  the region consists of 1 integer size beginning at Offs[j] */
               if (doRegionLocking) {
                  while (1) {
                     /* Now attempt the reqd lock! */
                     sentFlock.l_start = Offs[j];
                     sentFlock.l_type = F_WRLCK;
                     if ((sentFlock.l_len != sizeof(int)) || (sentFlock.l_whence != SEEK_SET)) {
                        fprintf(stderr, "Values of SentFlock have changed!\n");
                        exit(1);
                     }

                     if (LockFunc(fd[fdno], F_SETLKW, &sentFlock) < 0) {
                        fprintf(stderr, "\nLock Request failed\n");
                     }
                     else break;
                     if (errno == EDEADLK) {
                        fprintf(stderr, "Reported Possible Dead-Lock, will retry...\n");
                        continue;
                     }
                     else {
                        fprintf(stderr, "\nErrno: %x\n", errno);
                        exit(1);
                     }
                  }
               }
               DoWrite(fdno, j, Offs[j], Data);
            }
         }
      }


      if (Echo == 1)
         printf("read data ");
      else if (Echo == 2)
         printf("read data\n");

      if (Interleave)
      {
         for (j = 0; j < MaxOffs; j++) {
            for (fdno = 0; fdno < nofds; fdno++) {
               DoRead(fdno, j, Offs[j], Data[j]);

               /* unlock the region (if required).
                  the region consists of 1 integer size beginning at Offs[j] */
               if (doRegionLocking) {
                  sentFlock.l_type = F_UNLCK;
                  /* Now attempt the reqd unlock! */
                  sentFlock.l_start = Offs[j];
                  if ((sentFlock.l_len != sizeof(int)) || (sentFlock.l_whence != SEEK_SET)) {
                     fprintf(stderr, "Values of SentFlock have changed!\n");
                     exit(1);
                  }

                  if (LockFunc(fd[fdno], F_SETLK, &sentFlock) < 0) {
                     fprintf(stderr, "\nUnLock Request failed\n");
                     exit(1);
                  }
               }
            }
         }
      }
      else
      {
         for (fdno = 0; fdno < nofds; fdno++) {
            for (j = 0; j < MaxOffs; j++) {
               DoRead(fdno, j, Offs[j], Data[j]);

               /* unlock the region (if required).
                  the region consists of 1 integer size beginning at Offs[j] */
               if (doRegionLocking) {
                  sentFlock.l_type = F_UNLCK;
                  /* Now attempt the reqd unlock! */
                  sentFlock.l_start = Offs[j];
                  if ((sentFlock.l_len != sizeof(int)) || (sentFlock.l_whence != SEEK_SET)) {
                     fprintf(stderr, "Values of SentFlock have changed!\n");
                     exit(1);
                  }

                  if (LockFunc(fd[fdno], F_SETLK, &sentFlock) < 0) {
                     fprintf(stderr, "\nUnLock Request failed\n");
                     exit(1);
                  }
               }
            }
         }
      }


      if (Echo)
         printf("\n\r");
   }

   for (l = 0; l < nofds; l++)
      close(fd[l]);

#ifdef ENV_OS_NOVELL
   if (waitForZeroPendings)
   {
      while (NDirtyBlocks || DiskIOsPending)
         delay(100);
   }
#endif

   if (LogTime)
   {
      time(&endTime);
      fprintf(LogFile, "(%u)Stop  time:%s", getpid(), ctime(&endTime));
      fprintf(LogFile, "(%u)Elapsed time: %ld\n", getpid(),
         endTime - startTime);
   }

   if (errors)
      fprintf(LogFile, "(%u)errors: %u\n\r", getpid(), errors);

   exit(0);
}


PError(
char  *s)
{
   char        *p;
   char        tmp[180];
   extern int  sys_nerr;
   extern char *sys_errlist[];
   extern int  errno;

   if (errno >= sys_nerr)
   {
      sprintf(tmp, "unknown errno: %d", errno);
      p = tmp;
   }
   else
      p = sys_errlist[errno];

   fprintf(LogFile, ":%s\n", p);
}


PrintHelp()
{
   fputs("Random Write Read Test\n", stderr);
   fputs("usage: rwrt [-options] files...\n", stderr);
   fputs("options:\n", stderr);
   fputs("d n         - number of data points per iteration\n", stderr);
   fputs("e           - echo progress info to stdout\n", stderr);
   fputs("E           - echo LOTS of progress to stdout\n", stderr);
   fputs("s n         - set seed for random number generator to n\n", stderr);
   fputs("{lL} n      - set number of loops per file\n", stderr);
   fputs("{oOaA} file - log stderr to file. {oO}: overwrite log, {aA} append\n", stderr);
   fputs("f n         - max offset is n * 4 [800000]\n", stderr);
   fputs("i           - interleave I/Os\n", stderr);
   fputs("k           - perform (blocked) locking of regions\n", stderr);
   fputs("{hH}        - usage (help)\n", stderr);
}
