#include "environ.h"
#include <fcntl.h>
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#if   defined(ENV_OS_AIX)
#include <sys/flock.h>
#endif
#include <sys/file.h>

#define  MAXARGV  (50)

#define  TRACE    (0)
#define  NUMFDS   (32)

#define     CMD_OPT_LIST   "gs:r:n:k:bqhmo:f:c:l"

int      nArgC;
char     *nArgV[MAXARGV];
int      Fds[NUMFDS];
char     *FNames[NUMFDS];


/*********************************************************************/
PrintUsage()
{
   fprintf(stderr, "USAGE: \n");
   fprintf(stderr, "lock2 [-gsrnkbqhmofc]\n");
   fprintf(stderr, "g\t= get lock status vs set lock\n");
   fprintf(stderr, "s n\t= start location is n {START_CURR(c)/START_BEGIN(b)/START_END(e)}\n"
      "\t  [Default = START_BEGIN])\n");
   fprintf(stderr, "r n\t= relative offset is n (Default = 0)\n");
   fprintf(stderr, "n n\t= number of bytes to lock is is n\n"
      "\t  [Default = 0 = rest of the file]\n");
   fprintf(stderr, "k n\t= n is kind of lock {READ_LOCK(r)/WRITE_LOCK(w)/REMOVE_LOCK(c)}\n"
      "\t  [Default = WRITE_LOCK]\n");
   fprintf(stderr, "m\t= open mode for file is RO instead of RW\n");
   fprintf(stderr, "b\t= blocking for lock instead of returning w/error.\n");
   fprintf(stderr, "q\t= quit.\n");
   fprintf(stderr, "h\t= help.\n");
   fprintf(stderr, "l\t= list open files.\n");
   fprintf(stderr, "o f\t= open file f.\n");
   fprintf(stderr, "f n\t= operation is on open file #n or name n.\n"
      "\t  [Default 0].\n");
   fprintf(stderr, "c n\t= close file #n or name n\n");
}

/*********************************************************************/
usage()
{
   PrintUsage();
   exit(1);
}

/*********************************************************************/
CloseFile(
int   fileNum)
{
   if (Fds[fileNum] != -1)
   {
      close(Fds[fileNum]);
      Fds[fileNum] = -1;
      if (FNames[fileNum])
         free(FNames[fileNum]);
      return (0);
   }

   fprintf(stderr, "lock2: CloseFile: fileNum %d is not open.\n", fileNum);
   return (-1);
}

/*********************************************************************/
CloseAll()
{
   int   i;

   for (i = 0; i < NUMFDS; i++)
      if (Fds[i] != -1)
         CloseFile(i);
}

/*********************************************************************/
OpenNewFile(
char  *fileName,
int   openMode)
{
   int   i;

   for (i = 0; i < NUMFDS; i++)
   {
      /* printf("%d: Fds[i]: %d FNames[i]: 0x%x\n", i, Fds[i], FNames[i]); */
      if (Fds[i] == -1)
         break;
   }

   if (i >= NUMFDS)
   {
      fprintf(stderr, "lock2: cannot find free fd slot.\n");
      return (-1);
   }

   if ((Fds[i] = open(fileName, openMode)) == -1)
   {
      fprintf(stderr, "lock2: cannot open %s");
      perror(" ");
      return (-1);
   }

   if ((FNames[i] = malloc(strlen(fileName) + 1)) == NULL)
   {
      fprintf(stderr, "lock2: cannot malloc space for file name.\n");
      CloseFile(i);
      return (-1);
   }

   strcpy(FNames[i], fileName);

   return (-1);
}
/*********************************************************************/
ListFiles()
{
   int   i;

   for (i = 0; i < NUMFDS; i++)
   {
      if (Fds[i] == -1)
         continue;

      printf("%FileNum: %d, Name: %s\n", i, FNames[i]);
   }
}

/*********************************************************************/
char  *WhenceToStr(
int   whence)
{
   switch (whence)
   {
      case SEEK_CUR:
         return ("COF");

      case SEEK_SET:
         return("SOF");

      case SEEK_END:
         return ("EOF");

      default:
         return ("???");

   }
}

/*********************************************************************/
BuildArgV(
int   *argcp,
char  *argv[],
char  *cmdLine)
{
   int   i;
   int   len;
   char  *p;

   for (i = 1; i < MAXARGV; i++)
   {
      if (argv[i] != NULL)
      {
         free(argv[i]);
         argv[i] = NULL;
      }

      /* skip any blanks */
      for (cmdLine; *cmdLine && isspace(*cmdLine); cmdLine++)
         ;

      /* find a blank */
      for (p = cmdLine; *p && !isspace(*p); p++)
         ;

      if (p == cmdLine)
      {
         argv[i] = NULL;
         break;
      }

      len = p - cmdLine;

      if ((argv[i] = malloc(len + 1)) == NULL)
      {
         fprintf(stderr, "lock2: cannot malloc() in BuildArgV()\n");
         exit(1);
      }

      memcpy(argv[i], cmdLine, len);
      argv[i][len] = '\0';

      cmdLine = p;
   }

   *argcp = i;
}
/*********************************************************************/
GetFileNum(
char  *arg,
int   *fileNum)
{
   int   i;
   char  *dummy;

   if (isdigit(*arg))
   {
      *fileNum = strtol(arg, &dummy, 0);
      i = 0;
   }
   else
   {
      for (i = 0; i < NUMFDS; i++)
      {
         if (!strcmp(FNames[i], arg))
            break;
      }

      if (i >= NUMFDS)
      {
         fprintf(stderr, "lock2: file %s is not opened\n", arg);
         return (-1);
      }

      *fileNum = i;
   }

   if (i >= NUMFDS || Fds[*fileNum] == -1)
   {
      fprintf(stderr, "lock2: fileNum %d is not opened\n", *fileNum);
      return (-1);
   }

   return(0);
}
/*********************************************************************/
int   doParse(
int      numArgs,
char     **args,
int      *command,
int      *startLocation,
off_t    *relativeStart,
off_t    *numBytes,
int      *kindLock,
int      *fileNum)
{
   char           **myargs;
   int            getOptChar;
   char           *dummy;
   extern int     optind;
   extern char    *optarg;
   extern int     opterr;
   char           *fileName = NULL;
   int            openMode;

   myargs = args;

   optind = 1;

   *command = F_SETLK;
   *startLocation = SEEK_SET;
   *relativeStart = 0;
   *numBytes = 0;
   *kindLock = F_WRLCK;
   *fileNum = 0;
   openMode = O_RDWR;

   if (numArgs < 2) {
      return(-1);
   }

   getOptChar = getopt(numArgs, myargs, CMD_OPT_LIST);
   while (getOptChar != EOF) {
#if   TRACE
      printf("getOptChar: %c\n", getOptChar);
#endif

      switch (getOptChar) {
         case 'l':
            ListFiles();
            return (-1);

         case 'c':
            if (GetFileNum(optarg, fileNum))
               return (-1);
            return (CloseFile(*fileNum));

         case 'f':
            if (GetFileNum(optarg, fileNum))
               return (-1);
            break;

         case 'o':
            fileName = optarg;
            break;

         case 'h':
            PrintUsage();
            return (-1);
            break;

         case 'q':         /* quit in command mode */
            return (1);

      case 'g':   
                  *command = F_GETLK;
                  break;
      case 's':   if (!strcmp(optarg, "START_CURR") || *optarg == 'c') {
                     *startLocation = SEEK_CUR;
                     break;
                  }
                  else if (!strcmp(optarg, "START_BEGIN") || *optarg == 'b') {
                     *startLocation = SEEK_SET;
                     break;
                  }
                  else if (!strcmp(optarg, "START_END") || *optarg == 'e') {
                     *startLocation = SEEK_END;
                     break;
                  }
                  else usage();
                  break;
      case 'r':   *relativeStart = strtol(optarg, &dummy, 0);
                  break;
      case 'n':   *numBytes = strtol(optarg, &dummy, 0);
                  break;
      case 'k':   if (!strcmp(optarg, "READ_LOCK") || *optarg == 'r') {
                     *kindLock = F_RDLCK;
                     break;
                  }
                  else if (!strcmp(optarg, "WRITE_LOCK") || *optarg == 'w') {
                     *kindLock = F_WRLCK;
                     break;
                  }
                  else if (!strcmp(optarg, "REMOVE_LOCK") || *optarg == 'c') {
                     *kindLock = F_UNLCK;
                     break;
                  }
                  else usage();
                  break;
      case 'm':   openMode = O_RDONLY;
                  break;
      case 'b':   if (*command == F_SETLK) {
                     *command = F_SETLKW;
                     break;
                  }
                  break;

      case '?':   usage();
                  break;
      default:    fprintf(stderr, "Invalid Option: %c\n", getOptChar);
                  PrintUsage();
                  return (-1);
      }
      getOptChar = getopt(numArgs, myargs, CMD_OPT_LIST);
   }

   if (fileName)
   {
      return (OpenNewFile(fileName, openMode));
   }

   return(0);
}


/*********************************************************************/
void  DumpLock(
struct flock   *lock,
int            command)
{
   char  *reqStr;

   if (command == F_SETLK || command == F_SETLKW)
   {
      if (lock->l_type == F_UNLCK)
         reqStr = "Clear";
      else if (command == F_SETLKW)
         reqStr = "Set & wait for";
      else
         reqStr = "Set";
   }
   else
      reqStr = "Query";

   if (lock->l_type == F_UNLCK)
   {
      if (command == F_GETLK)
      {
         printf("Lock was not set.\n");
         return;
      }
      printf("%s lock", reqStr);
   }
   else
      printf("%s %s lock", reqStr,
         lock->l_type == F_RDLCK ? "Read" : "Write");

   printf(", whence: %s, start: %d, len: %d\n",
      WhenceToStr(lock->l_whence), lock->l_start, lock->l_len);
}




/*********************************************************************/
main(
int   argc,
char  **argv)
{
   int      fileDesc;
   char     *fileName;
   char     cLine[120];
   char     *reqStr;
   int      command;
   int      startLocation;
   off_t    relativeStart;
   off_t    numBytes;
   int      kindLock;
   int      fileNum;
   int      parseRC;

   struct flock   sentFlock;

   for (fileDesc = 0; fileDesc < NUMFDS; fileDesc++)
      Fds[fileDesc] = -1;

   doParse(argc, argv, &command,
      &startLocation, &relativeStart, &numBytes, &kindLock, &fileNum);

   /* loop getting command lines till quit requested */
   for (;;)
   {
      printf("Enter command: ");
      cLine[0] = '\0';
      if (fgets(cLine, 80, stdin) == NULL)
         break;

      BuildArgV(&nArgC, nArgV, cLine);

#if   TRACE
      if (1)
      {
         int   i;
      
         printf("\n");
         for (i = 1; i < nArgC; i++)
         {
            printf("nArgV[%d]>%s<\n", i, nArgV[i]);
         }
      }
#endif

      parseRC = doParse(nArgC, nArgV, &command,
         &startLocation, &relativeStart, &numBytes, &kindLock, &fileNum);

      if (parseRC == 1)
         break;

      if (parseRC == -1)
         continue;

      fileDesc = Fds[fileNum];

      sentFlock.l_type = kindLock;
      sentFlock.l_whence = startLocation;
      sentFlock.l_start = relativeStart;
      sentFlock.l_len = numBytes;

#ifdef   ENV_OS_AIX
      sentFlock.l_sysid = sentFlock.l_pid = sentFlock.l_vfs = 0;
#endif

      printf("%s: ", FNames[fileNum]);
      DumpLock(&sentFlock, command);

#if defined (ENV_OS_AIX)
      /* Now attempt the reqd lock! */
      if (lockfx(fileDesc, command, &sentFlock) < 0) {
#elif defined(ENV_OS_SOLARIS)
      if (fcntl(fileDesc, command, &sentFlock) < 0) {
#else
   ERROR !!!!! NO FS defined
#endif

         fprintf(stderr, "Lock/Unlock Request failed");
         perror(" ");

         /* accept failure due to not obtaining the lock and not sleeping */
         if (command != F_SETLK || errno != EACCES)
            break;
      }

      if (command == F_GETLK)
      {
         printf("GetLock results: ");
         DumpLock(&sentFlock, command);
      }
   }

   fprintf(stderr, "Exiting....\n");
   CloseAll();
   exit(0);
}

