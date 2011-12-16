/*****************************************************************************/
/*****************************************************************************/
/******************************** distress.c *********************************/
/*****************************************************************************/
/*****************************************************************************/

/* distress.c,v 1.117 93/05/06 10:37:12 rpt */

char RCS_ID[] = "@(#) $Header: /usr/yokel/archive-cvsroot/davep/bin/src/distress.c,v 1.1.1.1 2001/01/17 22:22:32 davep Exp $";

/*****************************************************************************/
/*                                                                           */
/* This version of distress performs stress tests on mounted filesystems.    */
/*                                                                           */
/* Basically, these tests fire off a bunch of processes which use System V   */
/* IPC to coordinate their actions.  The processes are hierarchically        */
/* related as follows:                                                       */
/*                                                                           */
/*   "Global" is the global test process -- it forks all other test          */
/*   processes, allocates global (test-wide) resources such as the pseudo    */
/*   random data shared memory segment and mount table semaphore.  These     */
/*   resources are inherited by all forked children.  Eventually, Global     */
/*   forks one "Disk()" process for each disk being tested and one           */
/*   "Tape()" process for each tape being tested.  These processes           */
/*   learn about their specific responsibilities (what device to test        */
/*   and how) from the "my..." global variables that Global initializes      */
/*   immediately prior to calling Fork().                                    */
/*                                                                           */
/*   "Disk" then does any device set-up needed prior to actual               */
/*   stress testing.  For example, Disk will check to see if it can get      */
/*   exclusive access to the disk it is responsible for testing, and if      */
/*   not, skip forking the raw stress processes since the device is          */
/*   likely being swapped to.  Disk will also create semaphores to be passed */
/*   on to all of their children so that they may synchronize access to      */
/*   the devices being tested.  Then, once device initialization is          */
/*   complete, Disk will fork the actual test processes -- one               */
/*   set of them for each level of load called for by the user.              */
/*                                                                           */
/*   These test processes are:                                               */
/*                                                                           */
/*     FilesystemStressRO  - read-only filesystem stress                     */
/*     FilesystemStressRW  - read-write filesystem stress                    */
/*                                                                           */
/*****************************************************************************/


/* BUGS:
**
**   new tests:
**     SDS
**     BOOT
**
**   enhancements:
**     general
**       CLEAN UP SHUTDOWN SEQUENCE -- WATCHDOG LAST!!!
**       DEVS FILES SHOULD BE READ FROM CD, NOT WORKDIR
**       WATCHDOG SHOULD TERMINATE TESTS WHEN ROOT FS FILLS UP!!!
**       backwards reads/writes
**       stress tests will mount unclean directory!!!
**     disk
**       fix devs > 2G
**       why does cdrom get a bogus fsSize?
*/


#include <ctype.h>
#include <stdio.h>
#include <sys/types.h>

#ifdef _SUN
#include <sys/ipc.h>
#include <sys/filio.h>		/* for FIONREAD ioctl */
#endif /* _SUN */

#include <sys/sem.h>
#include <sys/shm.h>
#include <sys/param.h>
#include <nlist.h>
#include <sys/msgbuf.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/signal.h>
#include <varargs.h>
#include <sys/vfs.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <strings.h>
#include <sys/mtio.h>
#include <sys/wait.h>
#include <sys/utsname.h>
#include <sys/mount.h>
#include <disktab.h>
#include <sys/time.h>

#ifndef _SUN
#include <sys/pstat.h>
#endif /* _SUN */

#include <sys/lock.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#undef minor
#undef major

#if defined(hp9000s800) && defined(_WSIO)
#define hp9000s700
#undef hp9000s800
#endif

#ifdef _SUN

typedef int ssize_t;
#define _NFILE 60

#endif /* _SUN */

/********************************** lint *************************************/

#ifdef lint
#ifndef _SUN
int pstat(c, p, n, i, j)
  int c; struct pst_static *p; int n; int i, j;{}
#endif /* _SUN */
#endif


/******************************** forward ************************************/

extern void Global();
extern void Disk();
extern void FilesystemStressRO();
extern void FilesystemStressRW();
extern void Log();
extern void Error();
extern void Perror();
extern void Dmesg();
extern void Inform();
extern void PreFork();
extern void PetWatchdog();
extern void Watchdog();
extern void Wait();
extern void Exit();
extern void ReadFile();
extern unsigned Min();
extern unsigned Max();
int Ismountpoint();
int MDI_Mount();
int MDI_Unmount();


/********************************* mainPid ***********************************/
/*                                                                           */
/* This is the process id of the main distress process.                      */
/*                                                                           */
/*****************************************************************************/

pid_t mainPid;


/******************************** baseTime ***********************************/
/*                                                                           */
/* This is the time (from time(2)) when the distress tests were started.     */
/*                                                                           */
/*****************************************************************************/

time_t baseTime;


/********************************* iter **************************************/
/*                                                                           */
/* This is the number of test iterations which this particular process has   */
/* completed since being forked.  Note that different processes run          */
/* different tests, so they count iterations of different things...          */
/*                                                                           */
/*****************************************************************************/

int iter;


/*********************************** arg... **********************************/
/*                                                                           */
/* These are the option flags passed in from the command-line.               */
/*                                                                           */
/*****************************************************************************/

char *arg0;
struct utsname utsname;
struct hostent *hostent;

int argNoHalt;

int argMount = 0;		/* Perform mounts/unmounts in FS stress */
int argMinblocks = 0;		/* Minimum file size, in blocks */
int argMaxblocks = 600;		/* Maximum file size, in blocks */
int argMaxfiles = 0;

int argNoDmesg = 0;
int argNoNet = 1;
int argNoClean = 1;
int argTime = 0;
int argVerbose;
int argDataLog;
int argDelRandom = 1;
int argDoFTWRead = 10;
int argNameLength = 0;
 
char *argWorkDir = "/";


/**************************** argDevs / lastDev ******************************/
/*                                                                           */
/* argDevs is the list of devices to test; lastDev is the index into the     */
/* list of the next empty entry.  This list is initialized either by reading */
/* the configuration file specified on the command-line or by scanning the   */
/* bus.  The base fields are:                                                */
/*                                                                           */
/*   minor      - the minor number (SC, F, T, L) where the device exists     */
/*   load       - the distress load average for the device                   */
/*   width      - the distress load subtree width (0 = no subtrees)          */
/*   depth      - the distress load subtree depth (0 = no subtrees)          */
/*   ro         - run read-only tests (boolean)                              */
/*   hd         - Use hard disk cache (boolean)  ...MDI only                 */
/*                                                                           */
/* The derived fields are:                                                   */
/*                                                                           */
/*   cMajor     - the character driver major number for this device          */
/*   bMajor     - the block driver major number for this device, or -1       */
/*   inq        - the inquiry data for this device                           */
/*   cap        - the capacity data for this device                          */
/*                                                                           */
/*****************************************************************************/

struct {
  char path[128];		/* JKH:  Mount point of MDI volume */
  char volname[128];		/* JKH:  Volume name */
  int load;
  int width;
  int depth;
  int ro;
  int hd;
} argDevs[32];

int lastDev;


/********************************* my... *************************************/
/*                                                                           */
/* This global data identifies the device and parameters for this instance   */
/* (process) of distress.  They are updated prior to forking subprocesses    */
/* which do actual testing work -- they are then accessed by the subprocess  */
/* as global data.  Specifically, these are:                                 */
/*                                                                           */
/*   myFunc       - a logging string to identify this process's test type    */
/*   myMinor      - the minor number of the device tested by this process    */
/*   myLoad       - the (total) load average to test this device             */
/*   myWidth      - the distress load subtree width (0 = no subtrees)        */
/*   myDepth      - the distress load subtree depth (0 = no subtrees)        */
/*   myLoadNum    - this process's load number (1 .. myLoad)                 */
/*   myRo         - this process is doing read-only testing (boolean)        */
/*   myHd         - this process is using a hard disk cache (boolean)        */
/*                                                                           */
/*****************************************************************************/

char *myFunc = "MAIN";
char myPath[128];	/* JKH:  this process' MDI volume mount point */
char myVolname[128];	/* JKH:  this process' MDI volume name */
int myBlocksize; 	/* JKH:  this process' filesystem block size */
int myLoad;
int myWidth;
int myDepth;
int myLoadNum;
int myRo;
int myHd;

/******************** logFp / errorsFp / datalogFp ***************************/
/*                                                                           */
/* These are the file pointers to the /stress/log and /stress/errors files.  */
/* Logging occurs at one of three levels:                                    */
/*                                                                           */
/*   Error       - send to log; send to errors; send to stdout; errors++     */
/*   Log         - send to log; if (argVerbose) send to stdout               */
/*   Inform      - send to log; send to errors; send to stdout               */
/*   DataLog     - send to datalog; send to stdout                           */
/*                                                                           */
/*****************************************************************************/

FILE *logFp;
FILE *errorsFp;
FILE *datalogFp;


/******************************* watchdogFds *********************************/
/*                                                                           */
/* This pipe is read by the Watchdog function (which is called by the main   */
/* process once it has forked off all the tests) and written by any process  */
/* that might hang doing I/O.  Once a process writes its pid to this pipe,   */
/* watchdog process will declare it as "timed out" unless it writes its pid  */
/* *again* within a few minutes.  If a process knows it is going away for    */
/* a while *without* potential for hanging doing I/O (such as when it makes  */
/* a sleep(3) call), it should write the negative of its pid to the pipe     */
/* to temporarily turn off the watchdog check.                               */
/*                                                                           */
/*****************************************************************************/

int watchdogFds[2];


/******************************** ...TIME... *********************************/
/*                                                                           */
/* These constants define the overall rate at which distress sequences thru  */
/* its tests in seconds.  Specifically:                                      */
/*                                                                           */
/*   TIME        - the upper limit for how long a timed test should run      */
/*                 before sleeping                                           */
/*   STIME       - the upper limit for how long a test should sleep before   */
/*                 running again                                             */
/*   RTIME       - the retry time for various failed operations              */
/*   DTIME       - the dmesg time for an expected message to show up         */
/*   TIMEOUT     - the maximum time a process can wait before "petting the   */
/*                 watchdog" again without being declared "timed out" and    */
/*                 killed                                                    */
/*                                                                           */
/*****************************************************************************/

#define TIME     60
#define STIME    30
#define RTIME    10
#define DTIME    30
#define LTIME    300
#define TIMEOUT  3600


/******************************** PATHLEN ************************************/
/*                                                                           */
/* Something smaller than MAXPATHLEN to keep the tests small -- should be    */
/* OK for most situations...                                                 */
/*                                                                           */
/*****************************************************************************/

#define PATHLEN  	128

#define CMDLEN  	128

#define NAMELEN		1024
#define MAXDEPTH	20


/******************************* K / M / G ***********************************/
/*                                                                           */
/* These constants just define kilo, mega, and giga.                         */
/*                                                                           */
/*****************************************************************************/

#define K  *1024
#define M  *1024*1024
#define G  *1024*1024*1024


/******************************** buffer *************************************/
/*                                                                           */
/* This is a per-process static buffer to be shared by various distress      */
/* functions that read and write data from and to the device.                */
/*                                                                           */
/*****************************************************************************/

unsigned char buffer[8 K];


/****************************** ioSem / ioSemP *******************************/
/*                                                                           */
/* ioSem is the semaphore used to control all logging operations.  It is     */
/* used so that one distress process's logging output cannot rudely          */
/* interrupt another's.  Basically, each process gets the semaphore, does    */
/* its logging (to /stress/log or /stress/errors), and then releases the     */
/* semaphore.  This keeps everything neat and clean.                         */
/*                                                                           */
/*****************************************************************************/

int ioSem;


/*****************************************************************************/

int baseFd;


/********************************* dirMount **********************************/
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

int dirMounted;
char dirMount[PATHLEN];


/********************************* dirFill ***********************************/
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

int dirFilled;
char dirFill[PATHLEN];


/**************************** StopWatch Vars *********************************/
/*                                                                           */
/*                                                                           */
/*****************************************************************************/
struct timeval start_time;
struct timeval end_time;


/************************** Name Buffer Vars *********************************/
/*                                                                           */
/*                                                                           */
/*****************************************************************************/
char namebuf1[NAMELEN];
char namebuf2[NAMELEN];

/****************************** errorAddr ************************************/
/*                                                                           */
/* This pointer points to a shared memory count of the total number of       */
/* errors encountered by the distress tests so far.  Each time a process     */
/* detects an error, it increments this count.  (This is done in the         */
/* Error() routine, which uses the ioSem for exclusive access to the log     */
/* files, so exclusive access to *errorAddr is guaranteed...)  When a        */
/* distress process exits, it uses this count as its exit value.             */
/*                                                                           */
/*****************************************************************************/

int *errorAddr;


/******************************* mountSem ************************************/
/*                                                                           */
/* This semaphore is used to guarantee exclusive access to the mount         */
/* subsystem of the kernel.  Before a process does a mount, umount, or       */
/* getmount_entry, it gets this semaphore.  After it is done, it releases    */
/* this semaphore.  This helps us avoid nasty race conditions in the kernel. */
/*                                                                           */
/*****************************************************************************/

int mountSem;


/***************************** expectedSem / expectedAddr ********************/
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

struct {
  struct {
    int time;
    char string[64];
    int count;
    int found;
  } line[16];
  int lastLine;
} *expectedAddr;

int expectedSem;


/****************************** dataAddr / DSIZE *****************************/
/*                                                                           */
/* DSIZE is the size of a shared memory segment pointed to by dataAddr which */
/* contains pseudo-random data to be used by the various distress processes  */
/* and functions.                                                            */
/*                                                                           */
/*****************************************************************************/

#ifdef SMALLFILES
#define DSIZE  (256 K)
#else
#ifdef _SUN
#define DSIZE  (1020 K)
#else
#define DSIZE  (4096 K)
#endif /* _SUN */
#endif	/* SMALLFILES */

unsigned char (*dataAddr)[DSIZE];


/******************************* pids / lastPid ******************************/
/*                                                                           */
/* pids is a list of all of the process ids of all of the processes forked   */
/* by this one.  lastPid is the index of the next empty entry in the list.   */
/* Each time this process forks a sub-process, the pid of the sub-process    */
/* is added here.  If this process should die for any reason, it will        */
/* go thru this list and kill all of its sub-processes and wait for them     */
/* to die before actually exiting itself.                                    */
/*                                                                           */
/* This list is initialized by PreFork(), maintained by Fork() and Exec(),   */
/* and used by Exit().                                                       */
/*                                                                           */
/*****************************************************************************/

pid_t pids[256];

int lastPid;


/********************************** sems / lastSem ***************************/
/*                                                                           */
/* These are just like pids/lastPid; they maintain a list of all semaphores  */
/* created by this process so that they can all be destroyed when this       */
/* process dies.                                                             */
/*                                                                           */
/* This list is initialized by PreFork(), maintained by InitSem() and used   */
/* by Exit().                                                                */
/*                                                                           */
/*****************************************************************************/

int sems[64];

int lastSem;


/********************************** shms / lastShm ***************************/
/*                                                                           */
/* These are just like pids/lastPid; they maintain a list of all shared      */
/* memory segments created by this process so that they can all be destroyed */
/* when this process dies.                                                   */
/*                                                                           */
/* This list is initialized by PreFork(), maintained by ShmAddr() and used   */
/* by Exit().                                                                */
/*                                                                           */
/*****************************************************************************/

int shms[64];

int lastShm;


/******************************** exiting ************************************/
/*                                                                           */
/* This boolean is set to 1 if this process is currently trying to exit --   */
/* any other calls to Exit() will be ignored.                                */
/*                                                                           */
/*****************************************************************************/

int exiting;


/*****************************************************************************/
/*****************************************************************************/
/********************************** IPC **************************************/
/*****************************************************************************/
/*****************************************************************************/


/******************************** InitSem() **********************************/
/*                                                                           */
/* This routine creates a private semaphore (which can be shared with any    */
/* children it forks), initializes its value to 1 (making it a "mutual       */
/* exclusion" type semaphore), and adds its semaphore id to the list of      */
/* semaphores created by this process (which need to be destroyed when this  */
/* process exits).                                                           */
/*                                                                           */
/*****************************************************************************/


int InitSem()
{
  int semid;
  int rc;
#ifdef _SUN
  union semun arg;
#endif /* _SUN */

  Log("Attempting to InitSem()\n");
  semid = semget(IPC_PRIVATE, 1, IPC_CREAT | 0600);
  if (semid < 0) {
    Perror("semget");
  }
#ifdef _SUN
  arg.val = 1;
  rc = semctl(semid, 0, SETVAL, arg);
  if(rc < 0) {
    Perror("semctl");
  }
#else
  (void)semctl(semid, 0, SETVAL, 1);
#endif /* _SUN */
  sems[lastSem++] = semid;
  return semid;
}


/************************************ P() ************************************/
/*                                                                           */
/* This routine "gets" the specified semaphore; it decrements the semaphore  */
/* value, and if it becomes less than 0, puts the calling process to sleep   */
/* until it becomes greater than or equal to 0.  If we get the "ioSem"       */
/* semaphore, then we set the per-process global boolean "ioSemP" so that    */
/* if we exit, we know to release the semaphore first so that other          */
/* processes can continue logging.                                           */
/*                                                                           */
/* Note that while we are waiting on a semaphore, we are *not* being         */
/* monitored by the watchdog since we assume we are waiting on another       */
/* process (which has the semaphore currently) which ultimately *is*         */
/* being monitored by the watchdog.                                          */
/*                                                                           */
/*****************************************************************************/

int criticalSemCount;
long criticalSemMask;

void P(semid)
int semid;
{
  int e;
  struct sembuf op;

  PetWatchdog(-1);

  if (semid == ioSem || semid == mountSem || semid == expectedSem) {
    if (! criticalSemCount++) {
      criticalSemMask =
        sigblock(sigmask(SIGTERM) | sigmask(SIGINT) | sigmask(SIGQUIT) |
                 sigmask(SIGALRM) | sigmask(SIGHUP) | sigmask(SIGPIPE));
    }
  }

  op.sem_num = 0;
  op.sem_op = -1;
  op.sem_flg = 0;
  while ((e = semop(semid, &op, 1)) < 0 && errno == EINTR) {
    e = 0;
  }
  if (e) {
    perror("semop");
  }

  PetWatchdog(1);
}


/************************************ V() ************************************/
/*                                                                           */
/* This routine "releases" the specified semaphore; it increments the        */
/* semaphore count, and if it becomes greater than 0, wakes up the process   */
/* on the head of the semaphore queue.  If we release the "ioSem"            */
/* semaphore, then we clear the per-process global boolean "ioSemP" so       */
/* that we no longer try to release the semaphore again if we exit.          */
/*                                                                           */
/*****************************************************************************/

void V(semid)
int semid;
{
  int e;
  struct sembuf op;

  op.sem_num = 0;
  op.sem_op = 1;
  op.sem_flg = 0;
  e = semop(semid, &op, 1);
  if (e) {
    perror("semop");
  }

  if (semid == ioSem || semid == mountSem || semid == expectedSem) {
    if (! --criticalSemCount) {
      sigsetmask(criticalSemMask);
    }
  }
}


/****************************** ShmAddr() ************************************/
/*                                                                           */
/* This routine creates a shared memory segment of the specified size        */
/* (which can be shared with any children it forks), initializes it to       */
/* all zeros, and adds its shared memory id to the list of shared memory     */
/* segments created by this process (which need to be destroyed when this    */
/* process exits).                                                           */
/*                                                                           */
/*****************************************************************************/

void *ShmAddr(size)
int size;
{
  int shmid;
#ifdef _SUN
  char *addr;
#else
  void *addr;
#endif /* _SUN */


  printf("ShmAddr(): requesting memory segment of size %d\n",size);
  fflush(stdout);
  shmid = shmget(IPC_PRIVATE, size, IPC_CREAT | 0600);
  if (shmid < 0) {
    Perror("shmget");
  }
  shms[lastShm++] = shmid;
#ifdef _SUN
  addr = (char *) shmat(shmid, (char *) NULL, (int) 0);
#else
  addr = shmat(shmid, (void *)NULL, 0);
#endif /* _SUN */
  bzero((char *)addr, size);
  return addr;
}


/*****************************************************************************/
/*****************************************************************************/
/******************************** LOGGING ************************************/
/*****************************************************************************/
/*****************************************************************************/


/********************************** Id() *************************************/
/*                                                                           */
/* This routine writes an id string for this process to the specified log    */
/* file.  It optionally writes a second string, also.                        */
/*                                                                           */
/*****************************************************************************/

void Id(fp, s)
FILE *fp;
char *s;
{
  fprintf(fp, "%s.%s.%d[%d]: ", myFunc, myPath, myLoadNum, Time());
  if (s) {
    fprintf(fp, "%s: ", s);
  }
}


/********************************** Log() ************************************/
/*                                                                           */
/* This routine logs the specified printf(3) style message to /stress/log    */
/* and optionally to stdout if the -v (verbose) command-line option was      */
/* specified.                                                                */
/*                                                                           */
/*****************************************************************************/

#define LASTLOGS 8
char lastLogs[LASTLOGS][128];
int lastLog;

/* VARARGS1 */
void Log(format, va_alist)
char *format;
va_dcl
{
  va_list ap = 0;

  P(ioSem);
  va_start(ap);

  if (argVerbose) {
    Id(stdout, (char *)NULL);
    vfprintf(stdout, format, ap);
    fflush(stdout);
  }

  Id(logFp, (char *)NULL);
  vfprintf(logFp, format, ap);
  fflush(logFp);


  if (format[0] != '.') {
    vsprintf(lastLogs[lastLog], format, ap);
    lastLog = (lastLog+1) % LASTLOGS;
  }

  va_end(ap);
  V(ioSem);
}


/******************************** Error() ************************************/
/*                                                                           */
/* This routine logs the specified printf(3) style message to /stress/log,   */
/* /stress/errors, and stdout.  It also increments the global distress       */
/* error count to indicate that an error has occurred.                       */
/*                                                                           */
/*****************************************************************************/

/* VARARGS1 */
void Error(format, va_alist)
char *format;
va_dcl
{
  va_list ap = 0;

  P(ioSem);
  va_start(ap);

  Id(stdout, "ERROR");
  vfprintf(stdout, format, ap);
  fflush(stdout);

  Id(logFp, "ERROR");
  vfprintf(logFp, format, ap);
  fflush(logFp);

  Id(errorsFp, "ERROR");
  vfprintf(errorsFp, format, ap);
  fflush(errorsFp);

  (*errorAddr)++;

  va_end(ap);
  V(ioSem);
}


/********************************* CheckDmesg() ******************************/
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

void CheckDmesg()
{
  int l;
  time_t t;

  P(expectedSem);

  t = Time();
  for (l = 0; l < (*expectedAddr).lastLine; l++) {
    if ((*expectedAddr).line[l].count && t > (*expectedAddr).line[l].time) {
      if (! (*expectedAddr).line[l].found) {
        Error("Expected DMESG output not found: %s\n",
              (*expectedAddr).line[l].string);
      }
      (*expectedAddr).line[l].count = 0;
    }
  }

  V(expectedSem);
}


/***************************** ExpectDmesg() *********************************/
/*                                                                           */
/* This routine makes us ignore all dmesg output as errors for DTIME seconds */
/* or until a line with the specified string shows up.                       */
/*                                                                           */
/*****************************************************************************/

void ExpectDmesg(s)
char *s;
{
  int l;

  P(expectedSem);

  for (l = 0; l < (*expectedAddr).lastLine; l++) {
    if (! (*expectedAddr).line[l].count ||
        strcmp((*expectedAddr).line[l].string, s) == 0) {
      break;
    }
  }

  if (l == (*expectedAddr).lastLine) {
    (*expectedAddr).lastLine++;
  }

  (*expectedAddr).line[l].time = Time() + DTIME;
  strcpy((*expectedAddr).line[l].string, s);
  if (! (*expectedAddr).line[l].count) {
    (*expectedAddr).line[l].found = 0;
  }
  (*expectedAddr).line[l].count++;

  V(expectedSem);
}


/******************************** Dmesg() ************************************/
/*                                                                           */
/* This routine logs the specified printf(3) style message to /stress/log,   */
/* /stress/errors, and, if the -d (no dmesg) command-line option was not     */
/* specified, to stdout.                                                     */
/*                                                                           */
/*****************************************************************************/

/* VARARGS1 */
void Dmesg(format, va_alist)
char *format;
va_dcl
{
  int l;
  time_t t;
  int total;
  va_list ap = 0;
  int error;
  char s[256];
  static time_t lastT;

  P(ioSem);
  P(expectedSem);
  va_start(ap);

  error = 0;

  total = 0;
  for (l = 0; l < (*expectedAddr).lastLine; l++) {
    total += (*expectedAddr).line[l].count;
  }

  if (! total) {
    t = Time();

    if (t > lastT) {
      V(ioSem);
      if(!argNoDmesg)
      {
        Error("Unexpected DMESG output!\n");
      }
      P(ioSem);
      lastT = t + DTIME;
    }

    Id(errorsFp, "DMESG");
    vfprintf(errorsFp, format, ap);
    fflush(errorsFp);

    error = 1;

  } else {
    vsprintf(s, format, ap);

    for (l = 0; l < (*expectedAddr).lastLine; l++) {
      if ((*expectedAddr).line[l].count &&
          strstr(s, (*expectedAddr).line[l].string)) {
        (*expectedAddr).line[l].count--;
        (*expectedAddr).line[l].found++;
        break;
      }
    }
  }

  if (! argNoDmesg && (error || argVerbose)) {
    Id(stdout, "DMESG");
    vfprintf(stdout, format, ap);
    fflush(stdout);
  }

  Id(logFp, "DMESG");
  vfprintf(logFp, format, ap);
  fflush(logFp);

  va_end(ap);
  V(expectedSem);
  V(ioSem);
}


/****************************** Inform() *************************************/
/*                                                                           */
/* This routine logs the specified printf(3) style message to /stress/log,   */
/* /stress/errors, and stdout.                                               */
/*                                                                           */
/*****************************************************************************/

/* VARARGS1 */
void Inform(format, va_alist)
char *format;
va_dcl
{
  va_list ap = 0;

  P(ioSem);
  va_start(ap);

  Id(stdout, (char *)NULL);
  vfprintf(stdout, format, ap);
  fflush(stdout);

  Id(logFp, (char *)NULL);
  vfprintf(logFp, format, ap);
  fflush(logFp);

  Id(errorsFp, (char *)NULL);
  vfprintf(errorsFp, format, ap);
  fflush(errorsFp);

  va_end(ap);
  V(ioSem);
}


/****************************** DataLog() ************************************/
/*                                                                           */
/* This routine logs the specified printf(3) style message to                */
/* /stress/dataout and optionally to stdout if -v (verbose) command-line     */
/* option was specified.                                                     */
/*                                                                           */
/*****************************************************************************/

/* VARARGS1 */
void DataLog(seconds, operation, path, name, bytes)
double seconds;
char *operation;
char *path;
char *name;
long bytes;
{

  if (argDataLog) {
    P(ioSem);

    if (myDepth == 0 && myWidth == 0) {
      if (bytes != 0) {
        fprintf(datalogFp, "%14.6lf%5s%9.3lf  %s/%s\n", 
          seconds, operation, 1e-3 * bytes, path, name);
      } else {
        fprintf(datalogFp, "%14.6lf%5s           %s/%s\n", seconds, operation, path, name);
      }
      fflush(datalogFp);

      if (argVerbose) {
        Id(stdout, (char *)NULL);
        if (bytes != 0) {
          fprintf(stdout, "%s %s, %5.3lf KB, %7.6lf seconds\n", 
            operation, name, 1e-3 * bytes, seconds);
        } else {
          fprintf(stdout, "%s %s, %7.6lf seconds\n", operation, name, seconds);
        }
        fflush(stdout);
      }

    } else {
      if (bytes != 0) {
        fprintf(datalogFp, "%14.6lf %3s %9.3lf %s\n", 
          seconds, operation, 1e-3 * bytes, name);
      } else {
        fprintf(datalogFp, "%14.6lf %3s %s\n", seconds, operation, name);
      }
      fflush(datalogFp);

      if (argVerbose) {
        Id(stdout, (char *)NULL);
        if (bytes != 0) {
          fprintf(stdout, "%s %s, %5.3lf KB, %7.6lf s\n", 
            operation, name, 1e-3 * bytes, seconds);
        } else {
          fprintf(stdout, "%s %s, %7.6lf s\n", operation, name, seconds);
        }
        fflush(stdout);
      }

    }

    V(ioSem);
  }
}




/****************************** Perror() *************************************/
/*                                                                           */
/* This routine calls Error() to log the error associated with the current   */
/* errno, prefixed by the specified string.                                  */
/*                                                                           */
/*****************************************************************************/

void Perror(s)
char *s;
{
  extern int sys_nerr;
  extern char *sys_errlist[];

  if (errno >= 0 && errno <= sys_nerr) {
    Error("%s: %s\n", s, sys_errlist[errno]);
  } else {
    Error("%s: Invalid errno = %d\n", s, errno);
  }
}


/*****************************************************************************/
/*****************************************************************************/
/******************************* UTILITIES ***********************************/
/*****************************************************************************/
/*****************************************************************************/


/*****************************************************************************/

unsigned char *readBuf;
unsigned readBufLen;
unsigned char *writeBuf;
unsigned writeBufLen;
unsigned char *rereadBuf;
unsigned rereadBufLen;

int fsize;
int bsize;

Zero(p, n)
unsigned char *p;
unsigned n;
{
  int i;

  for (i = 0; i < n; i++) {
    if (p[i]) {
      return 0;
    }
  }
  return 1;
}

Data(p, n)
unsigned char *p;
int n;
{
  int i;
  int j;

  for (i = 0; i < sizeof(*dataAddr)+4096-n+1; i++) {
    for (j = 0; j < n; j++) {
      if (p[j] != *(*dataAddr+i+j)) {
        break;
      }
    }
    if (j == n) {
      return 1;
    }
  }
  return 0;
}

Corruptions()
{
  int i;
  int l;
  int o;
  unsigned char *r;
  unsigned char *w;
  char *oldFunc;
  char bytes[80];

  Inform("\n");

  oldFunc = myFunc;
  myFunc = "CORR";

  Inform("Corruption: %s %s %s\n",
         utsname.nodename, utsname.machine, utsname.release);

  Inform("Look for DMESG output admitting error above...\n");

  Inform("Last log lines:\n");
  l = lastLog;
  for (i = 0; i < LASTLOGS; i++) {
    if (lastLogs[l][0]) {
      Inform("  %s", lastLogs[l]);
    }
    l = (l+1) % LASTLOGS;
  }

  Inform("Error type:\n");
  if (! rereadBufLen && ! writeBufLen) {
    Inform("  Not available (no write or reread data)\n");
  } else if (! rereadBufLen) {
    Inform("  Not available (no reread data)\n");
  } else if (! writeBufLen) {
    Inform("  Not available (no write data)\n");
  } else if (readBufLen != writeBufLen || readBufLen != rereadBufLen) {
    Inform("  Inconsistent lengths!\n");
    Inform("    write = %d\n", writeBufLen);
    Inform("    read = %d\n", readBufLen);
    Inform("    reread = %d\n", rereadBufLen);
  } else {
    if (memcmp((void *)writeBuf, (void *)readBuf, readBufLen) == 0 &&
        memcmp((void *)readBuf, (void *)rereadBuf, readBufLen) == 0) {
      Inform("  Not caught!\n");
    } else if (memcmp((void *)readBuf, (void *)rereadBuf, readBufLen) == 0) {
      Inform("  Write error!\n");
    } else if (memcmp((void *)rereadBuf, (void *)writeBuf, readBufLen) == 0) {
      Inform("  Read error!\n");
    } else {
      Inform("  Read and write error!\n");
    }
  }
  if (*oldFunc == 'F') {
    Inform("  %d/%d filesystem (%s)\n", bsize, fsize, oldFunc);
  } else {
    Inform("  Raw (%s)\n", oldFunc);
  }

  Inform("Error characteristics:\n");
  if (! readBufLen) {
    Inform("  Not available (no read data)\n");
  } else if (! writeBufLen) {
    Inform("  Not available (no write data)\n");
  } else if (readBufLen != writeBufLen) {
    Inform("  Inconsistent lengths!\n");
    Inform("    write = %d\n", writeBufLen);
    Inform("    read = %d\n", readBufLen);
  } else {
    Inform("  I/O length: %d\n", writeBufLen);
    r = readBuf;
    l = readBufLen;
    w = writeBuf;
    while (*r == *w && l) {
      r++;
      w++;
      l--;
    }
    if (l) {
      o = r-readBuf;
      Inform("  Error offset: %d\n", o);
      r = readBuf+readBufLen-1;
      w = writeBuf+readBufLen-1;
      while (*r == *w) {
        r--;
        w--;
      }
      l = r-readBuf+1 - o;
      Inform("  Error length: %d\n", l);
      bytes[0] = '\0';
      for (i = 0; i < Min((unsigned)8, (unsigned)l); i++) {
        sprintf(strchr(bytes, '\0'), " 0x%02x", readBuf[o+i]);
      }
      if (l > 8) {
        strcat(bytes, "...");
      }
      Inform("  Initial bytes:%s\n", bytes);
      if (Zero(readBuf+o, l)) {
        Inform("  Bytes are zeroes\n");
      } else if (l < 8) {
        Inform("  Bytes are burst\n");
      } else if (Data(readBuf+o, l)) {
        Inform("  Bytes are pseudorandom\n");
      } else if (l > 512 &&
                 Data(readBuf+o, 512) && Data(readBuf+o+l-512, 512)) {
        Inform("  Bytes are mixed-pseudorandom\n");
      } else if (l > 512 &&
                 (Data(readBuf+o, 512) || Data(readBuf+o+l-512, 512))) {
        Inform("  Bytes are partial-pseudorandom\n");
      } else {
        Inform("  Bytes are garbage!\n");
      }
    } else {
      Inform("  Not caught!\n");
    }
  }
  Inform("\n");

  myFunc = oldFunc;
}

/*****************************************************************************/

int ofd;
unsigned char *obuf;

bread(fd, offset, buf, n)
int fd;
unsigned offset;
char *buf;
unsigned n;
{
  unsigned r;
  unsigned bn;
  unsigned tn;
  unsigned toffset;
  unsigned boffset;
  char block[MAXBSIZE];

  Log("...Bread'd %d bytes from offset %d\n", n, offset);

  boffset = offset&~(DEV_BSIZE-1);
  r = offset-boffset;
  bn = r+n+((r+n)%DEV_BSIZE?DEV_BSIZE-(r+n)%DEV_BSIZE:0);

  toffset = offset%DEV_BSIZE;
  tn = n;

  (void)lseek(fd, boffset, 0);
  if (read(fd, block, bn) < 0) {
    Perror("read");
  }
  bcopy(block+toffset, buf, (int)tn);
}


/*****************************************************************************/

char *DumpName(i, suffix)
int i;
char *suffix;
{
  char *p;
  char buf[16];
  static char name[PATHLEN];

  if (name[0]) {
    p = strrchr(name, '.');
    p++;
    strcpy(p, suffix);
    return name;
  }

  strcpy(name, argWorkDir);
  strcat(name, "stress/corrupt/");

  (void) sprintf(buf,"%ld",(long)Time());
  strcat(name,buf);

  strcat(name, ".");

  (void) sprintf(buf,"%ld",(long)Time());
  strcat(name,buf);

  strcat(name, ".");
  strcat(name, suffix);
  return name;
}

unsigned char *DumpBuf(i, buf, n, suffix)
int i;
unsigned char *buf;
unsigned n;
char *suffix;
{
  int wfd;
  char *s;
  int total;
  unsigned char *copy;

  total = 0;
  s = DumpName(i, suffix);
  if ((wfd = open(s, O_WRONLY | O_CREAT, 0666)) < 0) {
    Perror("open");
  }
  total = write(wfd, buf, n);
  Log("...Dumped %d bytes of corrupt %s buf to %s\n", total, suffix, s);
  close(wfd);
  copy = (unsigned char *) malloc(n);
  bcopy(buf, copy, n);
  return copy;
}

void DumpSym(i, name)
int i;
char *name;
{
  char *s;
  char path[PATHLEN];

  if (name[0] == '/') {
    strcpy(path, name);
  } else {
    path[0] = '\0';
    getcwd(path, sizeof(path));
    strcat(path, "/");
    strcat(path, name);
  }
  s = DumpName(i, "reread");
  symlink(path, s);
  Log("...Symlinked %s corrupt reread fd to %s\n", path, s);

  rereadBufLen = 0;
  rereadBuf = NULL;
}

void DumpFd(i, fd)
int i;
int fd;
{
  int n;
  int wfd;
  char *s;
  int total;
  char buf[8 K];
  struct stat st;

  total = 0;
  s = DumpName(i, "read");
  if ((wfd = open(s, O_WRONLY | O_CREAT, 0666)) < 0) {
    Perror("open");
  }

  fstat(fd, &st);
  readBuf = (unsigned char *) malloc((unsigned)st.st_size);
  obuf = readBuf;

  (void)lseek(fd, (long)0, SEEK_SET);
  while ((n = read(fd, buf, sizeof(buf))) > 0) {
    total += write(wfd, buf, n);
    bcopy(buf, obuf, n);
    obuf += n;
  }
  readBufLen = total;
  Log("...Dumped %d bytes of corrupt read fd to %s\n", total, s);
  close(wfd);
}


/***************************** Update() **************************************/
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

char *server;


/***************************** HaltTests() ***********************************/
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

int haltTests;

void HaltTests()
{
  if (argNoHalt) {
    return;
  }

  Inform("Halting tests!\n");
  haltTests = 1;

  sleep(RTIME);
  (void)kill(mainPid, SIGHUP);
  sleep(RTIME);

  for (;;) {
    sleep(RTIME);
    Log("Waiting to be killed...\n");
  }
}


/***************************** SaveLogs() ************************************/
/*                                                                           */
/*  Currently not used...                                                    */
/*                                                                           */
/*****************************************************************************/

void SaveLogs()
{
  int logs;
  char *s;
  char command[CMDLEN];
  char id[64];
  time_t thisTime;

  (void)mkdir("stress", 0777);

  (void)system("compress stress/log >/dev/null 2>&1");
#ifndef _SUN
  (void)system("shar -scZ stress/corrupt >stress/corrupt.shar 2>/dev/null && \
               rm -rf stress/corrupt");
#endif /* _SUN */

  if (argDataLog) {
    (void)system("compress stress/datalog >/dev/null 2>&1");
  }

  if (access("stress/nosave", F_OK) == 0) {
    return;
  }

  thisTime = time((time_t *)NULL);
  s = (char *) ctime(&thisTime);
  if (s[8] == ' ') {
    s[8] = '0';
  }
  sprintf(id, "%s.%.2s%.3s.%.2s%.2s", utsname.nodename, s+8, s+4, s+11, s+14);

  logs = 0;

  sprintf(command, "rcp stress/errors stress@%s:%s.errors >/dev/null 2>&1",
          server, id);
  if (system(command) == 0) {
    logs++;
    (void)system("mv stress/errors stress/errors.old");
  }

  sprintf(command, "rcp stress/log.Z stress@%s:%s.log.Z >/dev/null 2>&1",
          server, id);
  if (system(command) == 0) {
    logs++;
    (void)system("mv stress/log.Z stress/log.Z.old");
  }

  sprintf(command,
          "rcp stress/corrupt.shar stress@%s:%s.corrupt.shar >/dev/null 2>&1",
          server, id);
  if (system(command) == 0) {
    logs++;
    (void)system("mv stress/corrupt.shar stress/corrupt.shar.old");
  }

  if (logs == 3) {
    (void)system("touch stress/nosave");
  }
}


/****************************** Sleep() **************************************/
/*                                                                           */
/* This routine puts the calling process to sleep for the specified number   */
/* of seconds.  It disables the watchdog functionality for that time (since  */
/* it knows it will wake up eventually).                                     */
/*                                                                           */
/*****************************************************************************/

void Sleep(i)
int i;
{
  PetWatchdog(-1);

  sleep((unsigned)i);

  PetWatchdog(1);
}


/******************************** Time() *************************************/
/*                                                                           */
/* This routine returns the time in seconds since the distress tests began.  */
/*                                                                           */
/*****************************************************************************/

int Time()
{
  return time((time_t *)NULL) - baseTime;
}


/**************************** StartStopWatch() *******************************/
/*                                                                           */
/* This routine starts a stop watch                                          */
/*                                                                           */
/*****************************************************************************/

void StartStopWatch()
{
  struct timezone tzp;

  (void) gettimeofday(&start_time, &tzp);
}


/**************************** StopStopWatch() ********************************/
/*                                                                           */
/* This routine stops the stop watch and returns the time in seconds         */
/*                                                                           */
/*****************************************************************************/

double StopStopWatch()
{
  struct timezone tzp;
  double start_seconds, end_seconds;

  (void) gettimeofday(&end_time, &tzp);

  start_seconds = (double) (start_time.tv_sec) + 1e-6 * (start_time.tv_usec);
  end_seconds = (double) (end_time.tv_sec) + 1e-6 * (end_time.tv_usec);
  return(end_seconds - start_seconds);
}



/******************************** Random() ***********************************/
/*                                                                           */
/* This routine returns a random number between 0 and n-1.                   */
/*                                                                           */
/*****************************************************************************/

int Random(n)
int n;
{
  if (n) {
    return (int) (lrand48() % n);
  }
  return 0;
}


/********************************** Max() ************************************/
/*                                                                           */
/* This routine returns the maximum of two unsigned numbers.                 */
/*                                                                           */
/*****************************************************************************/

unsigned Max(a, b)
unsigned a;
unsigned b;
{
  if (a > b) {
    return a;
  }
  return b;
}

unsigned Min(a, b)
unsigned a;
unsigned b;
{
  if (a < b) {
    return a;
  }
  return b;
}


/********************************* Trim() ************************************/
/*                                                                           */
/* This routine returns a copy of the specified length string with trailing  */
/* spaces removed and a null terminator added.                               */
/*                                                                           */
/*****************************************************************************/

char *Trim(s, n)
char *s;
size_t n;
{
  static char trim[64];

  strncpy(trim, s, n);
  trim[n] = '\0';
  while (n && isspace(trim[--n])) {
    trim[n] = '\0';
  }
  return trim;
}


/******************************** Checksum() *********************************/
/*                                                                           */
/* This routine returns a simple cyclic checksum of the specified data of    */
/* the specified size.  A "previous" checksum can also be specified if       */
/* this data is a continuation of previously checksummed data, such as when  */
/* reading a large file into a small buffer and checksumming one buffer's    */
/* worth of data at a time...                                                */
/*                                                                           */
/*****************************************************************************/

int Checksum(csum, data, size)
int csum;
unsigned char *data;
size_t size;
{
  int i;

  for (i = 0; i < size; i++) {
    csum = ((unsigned)csum<<1 | (unsigned)csum>>31) ^ (unsigned)data[i];
  }
  return csum;
}


/*****************************************************************************/
/*****************************************************************************/
/**************************** PROCESS CONTROL ********************************/
/*****************************************************************************/
/*****************************************************************************/


/********************************* Exit() ************************************/
/*                                                                           */
/* This routine cleans up all resources allocated by this instance of the    */
/* distress process prior to exiting.  Specifically, it:                     */
/*                                                                           */
/*   - kills all children forked (or forked and exec'd) by this process      */
/*   - waits for them to die                                                 */
/*   - destroys all semaphores created by this process                       */
/*   - destroys all shared memory segments created by this process           */
/*   - if this is the main distress process, clean up the filesystems        */
/*                                                                           */
/*****************************************************************************/

void AtExit()
{
  Exit(0);
}

void Exit(sig)
int sig;
{
  int i;
  int rmIo;
  int error;
  char command[CMDLEN];

  if (exiting) {
    return;
  }
  exiting = 1;

  (void)sigblock(sigmask(SIGTERM) | sigmask(SIGINT) | sigmask(SIGQUIT) |
                 sigmask(SIGALRM) | sigmask(SIGHUP) | sigmask(SIGPIPE));

  error = *errorAddr;

  if (getpid() == mainPid) {
    Inform("\n");
    Inform("%d total errors\n", error);
    Inform("(Wait for all processes to exit...)\n");
    Inform("\n");
  }

  for (i = 0; i < lastPid; i++) {
    (void)kill(pids[i], SIGTERM);
  }
  Wait();

  if (getppid() == mainPid &&
      (strcmp(myFunc, "DISK") == 0 || strcmp(myFunc, "TAPE") == 0)) {
    Inform("%d target CHO: %s %s %s\n", Time()/3600,
           utsname.nodename, utsname.machine, utsname.release);
  } else if (getpid() == mainPid && strcmp(myFunc, "MAIN") == 0) {
    Inform("%d system CHO: %s %s %s\n", Time()/3600,
           utsname.nodename, utsname.machine, utsname.release);
  }

  for (i = baseFd; i < _NFILE; i++) {
    (void)close(i);
  }

  (void)chdir(argWorkDir);

  if (sig == SIGQUIT) {
    (void)system("touch stress/nosave");
  }

  /*
  ** In order for rm -rf to work, the volume must be mounted
  */

  if (! haltTests && dirFilled && dirFill[0]) {
    if(!Ismountpoint(myPath))
    {
      StartStopWatch();
      (void) MDI_Mount(myVolname, myPath);
      DataLog(StopStopWatch(), " mt", dirFill, myVolname, 0); 
    }
    if (!argNoClean) {
      Log("Cleaning up with rm -rf %s\n", dirFill);
      strcpy(command, "rm -rf ");
      strcat(command, dirFill);
      (void)system(command);
    } else {
      Log("NOT Cleaning up with rm -rf %s\n", dirFill);
    }
  }

  if (getpid() == mainPid) {
    ExpectDmesg("");

    if (error != *errorAddr) {
      error = *errorAddr;
      Inform("Now %d total errors!\n", error);
    }

    if (access("stress/nosave", F_OK) == 0) {
      Inform("*Not* saving the error logs!\n");
    }
  }

  rmIo = 0;
  for (i = 0; i < lastSem; i++) {
    if (sems[i] == ioSem) {
      rmIo = 1;
    } else {
      if (semctl(sems[i], 0, IPC_RMID) < 0) {
        Perror("IPC_RMID");
      }
    }
  }

  for (i = 0; i < lastShm; i++) {
    if (shmctl(shms[i], IPC_RMID, (struct shmid_ds *)0) < 0) {
      Perror("IPC_RMID");
    }
  }

  Log("Pid %d exiting %d after %d iterations (%d/h)\n",
      getpid(), error, iter, iter*3600/(Time()+1));

  if (rmIo) {
    (void)semctl(ioSem, 0, IPC_RMID);
  }

  if (haltTests) {
    (void)chdir(argWorkDir);
    (void)chdir("stress");
    abort();
  }

  if (getpid() == mainPid) {
    SaveLogs();
  }

  exit(error);
}


/****************************** PreFork() ************************************/
/*                                                                           */
/* This routine initializes this process's data structures to reflect that   */
/* it has been forked from its parent.  It should be called once (early)     */
/* for the main distress process and then again by each child process        */
/* immediately after it is forked.                                           */
/*                                                                           */
/*****************************************************************************/

void PreFork()
{
#ifdef _SUN
  struct sigvec sigvector;
#else
  struct sigvec sigvec;
#endif /* _SUN */

  iter = 0;

  lastSem = 0;
  lastShm = 0;
  lastPid = 0;

  dirMounted = 0;
  dirFilled = 0;

#ifdef _SUN

  sigvector.sv_handler = Exit;
  sigvector.sv_mask = 0L;
  sigvector.sv_flags = 0L;
  sigvec(SIGTERM, &sigvector, (struct sigvec *)NULL);
  sigvec(SIGINT, &sigvector, (struct sigvec *)NULL);
  sigvec(SIGQUIT, &sigvector, (struct sigvec *)NULL);
  sigvec(SIGALRM, &sigvector, (struct sigvec *)NULL);
  sigvec(SIGHUP, &sigvector, (struct sigvec *)NULL);
  sigvec(SIGPIPE, &sigvector, (struct sigvec *)NULL);

#else
  sigvec.sv_handler = Exit;
  sigvec.sv_mask = 0L;
  sigvec.sv_flags = 0L;
  sigvector(SIGTERM, &sigvec, (struct sigvec *)NULL);
  sigvector(SIGINT, &sigvec, (struct sigvec *)NULL);
  sigvector(SIGQUIT, &sigvec, (struct sigvec *)NULL);
  sigvector(SIGALRM, &sigvec, (struct sigvec *)NULL);
  sigvector(SIGHUP, &sigvec, (struct sigvec *)NULL);
  sigvector(SIGPIPE, &sigvec, (struct sigvec *)NULL);
#endif /* _SUN */

#ifndef _SUN
  atexit(AtExit);
#endif /* _SUN */

  (void)srand48((long)getpid());
}


/****************************** Fork() ***************************************/
/*                                                                           */
/* This routine forks a child process running the specified function and     */
/* known by the specified id string (for logging purposes).  The function    */
/* is called with up to the 4 specified arguments.                           */
/*                                                                           */
/*****************************************************************************/

/*VARARGS2*/
void Fork(func, s, a1, a2, a3, a4)
void (*func)();
char *s;
{
  pid_t pid;

  switch (pid = fork()) {
    case -1:
      Perror("fork");
      exit(1);

    case 0:
      alarm(0);
      setsid();
      PreFork();
      Sleep(1);
      myFunc = s;
      Log("Forked with pid %d\n", getpid());
      (*func)(a1, a2, a3, a4);
      exit(1);

    default:
      pids[lastPid++] = pid;
      break;
  }
}


/********************************* Exec() ************************************/
/*                                                                           */
/* This routine forks and execs the specified command (which may include     */
/* arguments) with the specified file descriptors as stdin, stdout, and      */
/* stderr.  Specifying a file descriptor of -1 will cause /dev/null to be    */
/* opened for that file.                                                     */
/*                                                                           */
/*****************************************************************************/

int Exec(s, in, out, err, check)
char *s;
int in;
int out;
int err;
int check;
{
  int i;
  int l;
  pid_t pid;
  int status;
  char *v[16];
  char name[32];

  strncpy(name, s, sizeof(name));
  name[sizeof(name)-1] = '\0';
  l = strcspn(name, " ");
  name[l] = '\0';

  switch (pid = fork()) {
    case -1:
      Perror("fork");
      exit(1);

    case 0:
      alarm(0);
      setsid();
      exiting = 1;
      PreFork();
      Sleep(1);

      Log("Exec'd %s with pid %d\n", name, getpid());

      if (in != 0) {
        (void)close(0);
        if (in >= 0) {
          (void)dup(in);
        } else {
          (void)open("/dev/null", O_RDONLY);
        }
      }
      if (out != 1) {
        (void)close(1);
        if (out >= 0) {
          (void)dup(out);
        } else {
          (void)open("/dev/null", O_WRONLY);
        }
      }
      if (err != 2) {
        (void)close(2);
        if (err >= 0) {
          (void)dup(err);
        } else {
          (void)open("/dev/null", O_WRONLY);
        }
      }

      i = 0;
      while (s[0]) {
        v[i++] = s;
        l = strcspn(s, " ");
        if (s[l]) {
          s[l] = '\0';
          s = s+l+1;
        } else {
          s = s+l;
        }
        l = strspn(s, " ");
        s += l;
      }
      v[i] = NULL;

      execvp(v[0], v);
      Perror("exec");
      exit(1);

    default:
      pids[lastPid++] = -pid;
      break;
  }

  PetWatchdog(-1);
  PetWatchdog(1);
  if (strncmp(s, "fsck", 4) == 0) {
    PetWatchdog(1);
    PetWatchdog(1);
  }

  while (waitpid(pid, &status, 0) < 0 && errno != ECHILD) {
    /* NULL */
  }

  PetWatchdog(-1);
  PetWatchdog(1);

  lastPid--;

  if (check && (! WIFEXITED(status) || WEXITSTATUS(status))) {
    Error("%s failed 0x%x\n", name, status);
  }
  return status;
}


/****************************** Wait() ***************************************/
/*                                                                           */
/* This routine waits for all children forked by this process to exit.       */
/* Note that while waiting, we are *not* being monitored by the watchdog.    */
/*                                                                           */
/*****************************************************************************/

void Wait()
{
  PetWatchdog(-1);

  while (wait((int *)NULL) == 0 || errno != ECHILD) {
    /* NULL */
  }

  PetWatchdog(1);
}

/*****************************************************************************/
/*****************************************************************************/
/********************************* main **************************************/
/*****************************************************************************/
/*****************************************************************************/


/******************************** Usage() ************************************/
/*                                                                           */
/* This routine prints a usage message and exits.                            */
/*                                                                           */
/*****************************************************************************/

void Usage()
{
  printf("Revision 1.3 Usage:\n");
  printf("  distress [options] <file> \n");
  printf("\n");
  printf("Options:\n");
  printf("  -W <dir>      = use absolute <dir> instead of /\n");
  printf("  -T <time>     = run for <time> hours\n");
  printf("  -t <time>     = run for <time> minutes\n");
  printf("  -v            = verbose mode\n");
  printf("  -H            = don't halt tests on corruption\n");
  printf("  -m            = do not send dmesg output to stdout\n");
  printf("  -c            = Cleanup on exit (do not leave files)\n");
  printf("  -r            = don't stress root volume\n");
  printf("  -M <number>   = cycle for unmount/mounts testing\n");
  printf("                    default = 0\n");
  printf("  -D            = Data Log on\n");
  printf("  -s            = Force sequential file deletion\n");
  printf("  -x <number>   = cycle for full recursive reads\n");
  printf("                    default = 10\n");
  printf("  -B <number>   = minimim size of files, in blocks\n");
  printf("  -C <number>   = maximum size of files, in blocks\n");
  printf("  -F <number>   = maximum number of files\n");
  printf("  -n <number>   = file name length limit\n");
  printf("                    default = 0, just number files\n");
  printf("\n");
  printf("<file>          = consists of volume entries of the form:\n");
  printf("\n");
  printf("    <mount_point> <volume_name> <load> <width> <depth> <r|w> [h]\n");
  printf("\n");
  printf("           <mount_point>   = mount point of volume\n");
  printf("           <volume_name>   = name of the volume\n");
  printf("           <load>          = # of child processes per vol\n");
  printf("           <width>         = width of child processes subtree\n");
  printf("           <depth>         = depth of child processes subtree\n");
  printf("           r|w             = mount as read-only or read/write\n");
  printf("           h               = optionally mount w/ hd cache\n");
  printf("\n");
  printf("\n");
}


/******************************** Parse() ************************************/
/*                                                                           */
/* This routine parses the command line                                      */
/*                                                                           */
/*****************************************************************************/

int Parse(argc, argv)
int argc;
char **argv;

{
  int i;
  int c;
  int usage;
  extern char *optarg;

  usage = 0;
  while((c = getopt(argc, argv, "HM:T:mt:B:C:F:vDW:sn:cx:")) != EOF) {
    switch (c) {
      case 'H':
        argNoHalt = 1;
        break;
      case 'M':
        argMount = atoi(optarg); 		
        break;
      case 'T':
        argTime += atoi(optarg)*60;
        break;
      case 'm':
        argNoDmesg = 1;
        break;
      case 't':
        argTime += atoi(optarg);
        break;
      case 'B':
	argMinblocks = atoi(optarg);
	break;
      case 'C':
	argMaxblocks = atoi(optarg);
	break;
      case 'F':
	argMaxfiles = atoi(optarg);
	break;
      case 'v':
        argVerbose = 1;
        break;
      case 'D':
        argDataLog = 1;
        break;
      case 'W':
        argWorkDir = optarg;
        if (argWorkDir[0] != '/') {
          usage = 1;
        }
        break;
      case 's':
        argDelRandom = 0;
        break;
      case 'n':
	argNameLength = atoi(optarg);
	break;
      case 'c':
        argNoClean = 0;
        break;
      case 'x':
        argDoFTWRead = atoi(optarg);
        break;
      default:
        usage = 1;
        break;
    }
  }

  return(usage);
}


/********************************** main() ***********************************/
/*                                                                           */
/* This is the main distress entry point.  It is responsible for parsing     */
/* all command-line arguments and verifying them.  It then kicks off the     */
/* actual tests by calling the "Global" routine.                             */
/*                                                                           */
/*****************************************************************************/

int main(argc, argv)
int argc;
char **argv;
{
  int i;
  int n;
  int fd;
  char *w;
  FILE *fp;
  int phys;
  int usage;
  char *file;
  char ro;
  char hd;
  int load;
  int width;
  int depth;
  int myDev;
  char line[256];
  char path[512];
  extern int optind;

#ifndef _SUN
  struct pst_static pst_static;
#endif /* _SUN */

  char mount_point[128];	/* Path of the MDI volume mount point */
  char volname[128];		/* Name of MDI volume */

  umask(022);
  strcpy(path, "PATH=");
  strcat(path, "/etc:/bin:/usr/bin:");
  strcat(path, getenv("PATH"));
  putenv(path);
  mainPid = getpid();
  arg0 = argv[0];
  sync();

  uname(&utsname);
  gethostname(line, sizeof(line));
  hostent = gethostbyname(line);

  if(argc == 1) {
    Usage();
    exit(1);
  }

  usage = Parse(argc, argv);

  if (usage) {
#ifndef _SUN
    atexit(Usage);
#else
    Usage();
#endif /* _SUN */
  }

  if((argMaxblocks - argMinblocks) < 0) {
    printf("DISTRESS:  check -B and -C options!\n");
    if(!usage) {
      usage = 1;
#ifndef _SUN
    atexit(Usage);
#else
    Usage();
#endif /* _SUN */
    }
  }
  if((argMaxblocks > DSIZE)) {
    printf("DISTRESS:  maximum file size must be <= %d blocks\n",DSIZE);
    if(!usage) {
      usage = 1;
#ifndef _SUN
    atexit(Usage);
#else
    Usage();
#endif /* _SUN */
    }
  }

  if (usage) {
    exit(usage);
  }

  if (chdir(argWorkDir) < 0) {
    perror("chdir");
    exit(1);
  }

/*
**  SaveLogs() here if a network is set up, before destroying them
*/

#ifdef _SUN
  (void)system("rm -rf /stress/* /1 /*/[123456789]");
#else
  (void)system("rm -rf stress /1 /*/[123456789]");
#endif /* _SUN */

#ifndef _SUN
  if (swapon("/", 0, 0, 0, 0) < 0 && errno != EALREADY) {
    perror("swapon");
  }
#endif /* _SUN */

#ifndef _SUN
  (void)mkdir("stress", 0777);
#endif /* _SUN */
  (void)mkdir("stress/dev", 0777);
  (void)mkdir("stress/rdev", 0777);
  (void)mkdir("stress/mnt", 0777);
  (void)mkdir("stress/tmp", 0777);
  (void)mkdir("stress/corrupt", 0777);

  pipe(watchdogFds);
  logFp = fopen("stress/log", "w");
  errorsFp = fopen("stress/errors", "w");
  datalogFp = fopen("stress/datalog", "w");
  baseTime = time((time_t *)NULL);

  baseFd = open("/dev/null", O_RDONLY);
  close(baseFd);

  PreFork();
  ioSem = InitSem();
  expectedSem = InitSem();
  errorAddr = ShmAddr(sizeof(*errorAddr));
  expectedAddr = ShmAddr(sizeof(*expectedAddr));

  mountSem = InitSem();

  Inform("%s\n", RCS_ID);

#ifdef _SUN
  if (hostent) {
    Inform("%s %s %s %s\n", hostent->h_name,
           utsname.machine, utsname.sysname, utsname.release);
  } else {
    Inform("%s %s %s %s\n", utsname.nodename, utsname.machine,
                            utsname.sysname, utsname.release);
  }
#else
  if (hostent) {
    Inform("%s %s %s %s %s\n", hostent->h_name,
           inet_ntoa(((struct in_addr *)(hostent->h_addr))->s_addr),
           utsname.machine, utsname.sysname, utsname.release);
  } else {
    Inform("%s %s %s %s\n", utsname.nodename, utsname.machine,
                            utsname.sysname, utsname.release);
  }
#endif /* _SUN */

#ifndef _SUN
  if (pstat(PSTAT_STATIC, &pst_static, sizeof(pst_static), 0, 0) == -1) {
    Perror("PSTAT_STATIC");
  } else {
    phys = pst_static.physical_memory * pst_static.page_size;
    Inform("Physical memory size is %dMB\n", phys/1024/1024);
  }
#endif /* _SUN */

  Inform("%s", ctime(&baseTime));
  line[0] = '\0';
  for (i = 1; i < argc; i++) {
    strcat(line, argv[i]);
    strcat(line, " ");
  }
  Inform("Execution options: %s\n", line);
  Inform("Main pid %d\n", mainPid);
  Inform("\n");

  Inform("Kernel what(1) string:\n");
#ifdef _SUN
  fp = popen("what /vmunix | egrep -i 'hp-ux |patch' | sed 's!B2352A !!'", "r");
#else
  fp = popen("what /hp-ux | egrep -i 'hp-ux |patch' | sed 's!B2352A !!'", "r");
#endif /* _SUN */
  while (fgets(line, sizeof(line), fp)) {
    w = line;
    while (isspace(*w)) {
      w++;
    }
    Inform("  %s", w);
  }
  pclose(fp);
  Inform("\n");

  if (argNoNet) {
    (void)system("touch stress/nosave");
    Inform("Running in non-networked mode.\n");
    Inform("*Not* auto-updating the tests!\n");
    Inform("*Not* saving the error logs!\n");
  } else {
    Inform("Networking with %s\n", server);
  }
  Inform("\n");

  if (optind == argc) {
  } else while (optind < argc) {
    file = argv[optind];
    if (isdigit(file[0])) {
      argDevs[lastDev].load = 3;
      argDevs[lastDev].ro = 0;
      lastDev++;

    } else {
      if (strcmp(file, "-")) {
        fp = fopen(file, "r");
      } else {
        fp = fdopen(dup(0), "r");;
      }

      if (fp) {
        Inform("data file: %s\n",file);
        while (fgets(line, sizeof(line), fp) != NULL) {
	  strcpy(mount_point,"");
	  strcpy(volname,"");
          load = 3;
          ro = 'r';
          hd = ' ';
          n = sscanf(line, "%s %s %d %d %d %c %c", mount_point, volname, &load, &width, &depth, &ro, &hd);

          if (n > 0 && strcmp(mount_point, "#")) {
            Inform("mountpt: %s, volname: %s, load: %d, width: %d, depth: %d, ro: %c, hd: %c\n", 
              mount_point, volname, load, width, depth, ro, hd);
	    strcpy(argDevs[lastDev].path,mount_point);
	    strcpy(argDevs[lastDev].volname,volname);
            argDevs[lastDev].load = load;
            argDevs[lastDev].width = width;
            argDevs[lastDev].depth = depth;
            argDevs[lastDev].ro = (ro != 'w');
            argDevs[lastDev].hd = (hd == 'h');
            lastDev++;
          }
        }
      }
      fclose(fp);
    }

    optind++;
  }

/* JKH:  Need to add a check here to make sure the mount point given is
**       actually a mounted MDI volume.  Don't know how to do this yet,
**       but needs to be put in place of the Inquiry() stuff above that I
**       took out
*/


/*
** JKH:  This big switch below has been taken out because the inquiry
**       has been removed.  None of this code is necessary.
*/


  Inform("\n");

  sync();

  if (lastDev && ! *errorAddr ) {
    Global();
  } else {
    Exit(0);
  }
  /* NOTREACHED */
}


/****************************** Global() *************************************/
/*                                                                           */
/* This is the beginning of the actual distress testing.  This process forks */
/* a test process ("Disk()" or "Tape()" for each device to be tested.  It    */
/* then becomes the watchdog which reads from the watchdogFds pipe and       */
/* checks for timed out processes and prints any dmesg(1) messages from the  */
/* kernel message buffer.                                                    */
/*                                                                           */
/*****************************************************************************/

void Global()
{
  int i;
  int fd;
  char *p;
  int myDev;

  alarm((unsigned)argTime*60);

  srand48((long) 0);
  dataAddr = ShmAddr(sizeof(*dataAddr)+4096);
  for (i = 0; i < sizeof(*dataAddr)+4096; i++) {
    do {
      (*dataAddr)[i] = rand() % 256;
    } while ((*dataAddr)[i] == 0 || (*dataAddr)[i] == 255);
  }
  (void)srand48((long)getpid());

  fd = open("stress/data", O_WRONLY | O_CREAT, 0666);
  if (fd < 0) {
    Perror("open");
  }
  if (write(fd, *dataAddr, sizeof(*dataAddr)+4096) != sizeof(*dataAddr)+4096) {
    Perror("write");
  }
  (void)close(fd);

  for (myDev = 0; myDev < lastDev; myDev++) {

      strcpy(myPath,argDevs[myDev].path);
      strcpy(myVolname,argDevs[myDev].volname);
      myRo = argDevs[myDev].ro;
      myHd = argDevs[myDev].hd;
      myLoad = argDevs[myDev].load;
      myWidth = argDevs[myDev].width;
      myDepth = argDevs[myDev].depth;

      if (myDepth > MAXDEPTH) {
        Log("Subtree depth > max of %d, forcing to 0\n", MAXDEPTH);
        myDepth = 0;
      }

      if (myWidth == 0) {
        i = 0;
      } else if (myWidth < 10) {
        i = 1;
      } else if (myWidth < 100) {
        i = 2;
      } else if (myWidth < 1000) {
        i = 3;
      } else if (myWidth < 10000) {
        i = 4;
      } else if (myWidth < 100000) {
        i = 5;
      } else if (myWidth < 1000000) {
        i = 6;
      } else if (myWidth < 10000000) {
        i = 7;
      } else if (myWidth < 100000000) {
        i = 8;
      }

      if ((myDepth * (i + 1) + argNameLength) > NAMELEN) {
        Log("Possible full file path name is > %d, forcing length and depth to 0\n", NAMELEN);
        myWidth = 0;
        myDepth = 0;
      }


/* JKH:  This call to fork we'll just force--i.e., get rid of the conditional
**       if.
*/

      Fork(Disk, "DISK");
  }

  Watchdog();
}


/*****************************************************************************/
/*****************************************************************************/
/******************************* WATCHDOG ************************************/
/*****************************************************************************/
/*****************************************************************************/


/********************************* nl ****************************************/
/*                                                                           */
/* This is the namelist which holds the name of the kernel message buffer.   */
/*                                                                           */
/*****************************************************************************/

struct nlist nl[2] = {
# ifdef hp9000s200
  { "_Msgbuf" },
# else
  { "msgbuf" },
# endif
  { "" }
};

/***************************** procs / lastProc ******************************/
/*                                                                           */
/* procs is a list of processes whose pid's are registered with the          */
/* watchdog; lastProc is the index of the next empty entry in that array.    */
/* The fields of procs are specifically:                                     */
/*                                                                           */
/*   pid     - the pid of the process to be watched, or 0 for an empty slot  */
/*   ticks   - the number of ticks (seconds) until that process is declared  */
/*             "timed out" and killed                                        */
/*                                                                           */
/*****************************************************************************/

struct {
  pid_t pid;
  int ticks;
} procs[256];

int lastProc;


/***************************** FoundProc() ***********************************/
/*                                                                           */
/* This routine adds (if pid > 0) or removes (if pid < 0) the specified pid  */
/* to or from the list of pids being monitored by the watchdog.  If the pid  */
/* is added to the list (i.e., we just heard from the process again), the    */
/* corresponding "ticks" field is reset to the maximum value.                */
/*                                                                           */
/*****************************************************************************/

void FoundProc(pid)
pid_t pid;
{
  int i;
  int rm;

  rm = 0;
  if (pid < 0) {
    pid = -pid;
    rm = 1;
  }
  for (i = 0; i < lastProc; i++) {
    if (procs[i].pid == pid) {
      if (rm) {
        procs[i].pid = 0;
      } else {
        procs[i].ticks += TIMEOUT;
        if (procs[i].ticks > 3*TIMEOUT) {
          procs[i].ticks = 3*TIMEOUT;
        }
      }
      return;
    }
  }
  if (rm) {
    return;
  }
  for (i = 0; i < lastProc; i++) {
    if (procs[i].pid == 0) {
      procs[i].pid = pid;
      procs[i].ticks = TIMEOUT;
      return;
    }
  }
  procs[lastProc].pid = pid;
  procs[lastProc].ticks = TIMEOUT;
  lastProc++;
}

/***************************** TickProcs() ***********************************/
/*                                                                           */
/* This routine should be called once a second; it decrements the remaining  */
/* time count for all processes which are being monitored by the watchdog.   */
/* if any of these times hit 0, the process is declared "timed out" and      */
/* killed -- first with a SIGTERM and then with a SIGKILL.                   */
/*                                                                           */
/*****************************************************************************/

void TickProcs()
{
  int i;
  int alive;
  pid_t pid;
  int ticks;
  static int all;

  alive = 0;
  for (i = 0; i < lastProc; i++) {
    pid = procs[i].pid;
    if (pid) {
      alive = 1;
      ticks = --procs[i].ticks;
      if (ticks == 0) {
        if (kill(pid, SIGTERM) == 0) {
          Error("Process %d timed out; sending SIGTERM\n", pid);
        }
      } else if (ticks < -TIMEOUT) {
        if (kill(pid, SIGKILL) == 0) {
          Error("Process %d did not die; sending SIGKILL\n", pid);
        }
        procs[i].pid = 0;
        procs[i].ticks = 0;
      }
    }
  }

  if (lastProc && ! alive) {
    all++;
  } else {
    all = 0;
  }

  if (all > TIMEOUT) {
    Error("All processes timed out!!!\n");
    Exit(0);
  }
}

/****************************** Watchdog() ***********************************/
/*                                                                           */
/* This process reads any pid's from the watchdog pipe that were written     */
/* by processes wanting to be monitored.  It then turns on or off the        */
/* monitoring as appropriate.  Any processes that had monitoring turned on   */
/* and which haven't been heard from in the maximum time are declared        */
/* "timed out" and killed.                                                   */
/*                                                                           */
/* This process also prints CHO values every hour and monitors the dmesg(1)  */
/* buffer continuously for any new kernel printf's or msg_printf's.  These   */
/* are logged from /dev/kmem to the log files every second, and the log      */
/* files are sync'd.                                                         */
/*                                                                           */
/*****************************************************************************/

void Watchdog()
{
  int i;
  char c;
  pid_t pid;
  int avail;
  int dmesg;
  int kmem;
  int first;
  int end;
  int begin;
  int same;
  int current;
  int hours;
  char line[MSG_BSIZE+1];
  struct msgbuf msgbuf;
  struct msgbuf oMsgbuf;

  nice(-10);

  dmesg = 1;
#ifdef _SUN
  nlist("/vmunix",nl);
#else
  nlist("/hp-ux", nl);
#endif /* _SUN */
  if (nl[0].n_type == 0) {
#ifdef _SUN
    Log("Cannot nlist /vmunix; continuing without dmesg...\n");
#else
    Error("Cannot nlist /hp-ux; continuing without dmesg...\n");
#endif /* _SUN */
    dmesg = 0;
  } else if ((kmem = open("/dev/kmem", O_RDONLY)) < 0) {
    Error("Cannot open /dev/kmem; continuing without dmesg...\n");
    dmesg = 0;
  }
  if(argNoDmesg) {
    dmesg = 0;
  }
  first = 1;
  current = 0;
  line[current] = '\0';
  hours = 0;

  for (;;) {
    while (ioctl(watchdogFds[0], FIONREAD, &avail) == 0 &&
           avail >= sizeof(pid)) {
      (void)read(watchdogFds[0], &pid, sizeof(pid));
      FoundProc(pid);
    }

    TickProcs();

    if (Time() >= (hours+1)*3600) {
      Inform("%d CHO; %d errors (%s)\n", ++hours, *errorAddr,
                                         utsname.nodename);
    }

    fsync(fileno(errorsFp));
    fsync(fileno(logFp));

    if (dmesg) {
      (void)lseek(kmem, (unsigned)nl[0].n_value, SEEK_SET);
      (void)read(kmem, &msgbuf, sizeof(msgbuf));

      if (first) {
        oMsgbuf = msgbuf;
        first = 0;
      }

      if (msgbuf.msg_magic != MSG_MAGIC) {
        Error("Msgbuf magic number not found; continuing without dmesg...\n");
        dmesg = 0;
      } else {
        if (msgbuf.msg_bufx >= MSG_BSIZE) {
          msgbuf.msg_bufx = 0;
        }

        begin = oMsgbuf.msg_bufx;
        end = msgbuf.msg_bufx;

        same = 1;
        for (i = end; i != begin; i = (i+1)%MSG_BSIZE) {
          if (oMsgbuf.msg_bufc[i] != msgbuf.msg_bufc[i]) {
            begin = (end+1)%MSG_BSIZE;
            same = 0;
            break;
          }
        }

        if (! same) {
          line[current] = '\0';
          Dmesg("%s...\n", line);
          current = 0;
        }

        for (i = begin; i != end; i = (i+1)%MSG_BSIZE) {
          c = msgbuf.msg_bufc[i];
          line[current++] = c;
          if (c == '\n') {
            line[current] = '\0';
            Dmesg("%s", line);
            current = 0;
          }
        }

        oMsgbuf = msgbuf;
      }

      CheckDmesg();
    }

    Sleep(1);
    iter++;
  }
}

/******************************** PetWatchdog() ******************************/
/*                                                                           */
/* This routine registers (if n == 1) or unregisters (if n == -1) the        */
/* calling process with the watchdog.  While registered, the process must    */
/* "pet the watchdog" at least once every TIMEOUT seconds, or else the       */
/* watchdog will grab its neck and tear its little head off...               */
/*                                                                           */
/*****************************************************************************/

void PetWatchdog(n)
int n;
{
  pid_t pid;
  static int depth;

  depth += n;
  if (n < 0 || depth >= 0) {
    pid = getpid();
    if (pid != mainPid) {
      pid *= n;
      (void)write(watchdogFds[1], &pid, sizeof(pid));
    }
  }
}


/*****************************************************************************/
/*****************************************************************************/
/********************************** DISK *************************************/
/*****************************************************************************/
/*****************************************************************************/


/*************************** ...SIZE / FCOUNT ********************************/
/*                                                                           */
/* These constants define:                                                   */
/*                                                                           */
/*   RSIZE      - the size of the raw area at the end of the disk to be      */
/*                stresses by RawStress()                                    */
/*   RISIZE     - the size of the largest raw I/O to do to the raw area of   */
/*                the disk                                                   */
/*   FSIZE      - the size of the files created by FilesystemRW()            */
/*   FCOUNT     - the number of files monitored at once by FilesystemRW()    */
/*                                                                           */
/*****************************************************************************/

#define RSIZE   (4 M)
#define RISIZE  (256 K)

#ifdef  SMALLFILES
#define FSIZE   (255 K)
#else
#define FSIZE	(300 K)
#endif	/* SMALLFILES */

#define FCOUNT  100


/********************************** dskSem ***********************************/
/*                                                                           */
/* This is the per-disk device semaphore.  It is created by the "Disk()"     */
/* process during device initialization.  Getting this semaphore assures     */
/* you are the only process using the *filesystem* -- no assurances are      */
/* made for the raw area afterwards -- see "dskExcl" below.                  */
/*                                                                           */
/*****************************************************************************/

int dskSem;


/************************dskOpenSem / dskCloseSem / dskExcl ******************/
/*                                                                           */
/* These variables are used to acquire complete exclusive access to a disk   */
/* device for functional testing.  They are used as follows:                 */
/*                                                                           */
/*   dskExcl     - 0 if we can get exclusive access to the disk, -1 if we    */
/*                 cannot (because, for example, the OS is swapping to it)   */
/*   dskOpenSem  - magic...                                                  */
/*   dskCloseSem - magic...                                                  */
/*                                                                           */
/*****************************************************************************/



/************************* rcsumsAddr / NRCSUMS ******************************/
/*                                                                           */
/* rcsumsAddr is a pointer to a shared memory segment (shared by all         */
/* processes accessing the same disk) which contains:                        */
/*                                                                           */
/*   nCsums       - the number of 512 byte blocks in the disk raw area       */
/*   csum         - an array of (NRCSUMS) checksums of each of those blocks  */
/*                                                                           */
/*****************************************************************************/



/*************************** lockSem / lockAddr ******************************/
/*                                                                           */
/* lockSem is a semaphore to control access to the shared memory lock table  */
/* (shared by all processes accessing the same disk) pointed to by lockAddr. */
/* The lock table is simply an array of chars, one per 512 byte block in     */
/* the raw disk area, where a non-zero value means a block is in use; zero   */
/* means it is not.                                                          */
/*                                                                           */
/*****************************************************************************/


/*************************** fcsumsAddr / NFCSUMS ****************************/
/*                                                                           */
/* fcsumsAddr is a pointer to a structure which contains:                    */
/*                                                                           */
/*   nCsums       - the number of files currently checksummed on the disk    */
/*   csum         - an array of (NRCSUMS) checksums of each of those  files  */
/*                                                                           */
/* Note that for read-only tests, this structure is kept in shared memory    */
/* (and is shared by all processes accessing the same disk); for read-write  */
/* tests, each process creates its own sub-directory on the disk and         */
/* therefore has its own files and fcsumsAddr structure in local memory.     */
/*                                                                           */
/*****************************************************************************/

/* JKH:  Increasing this number to allow volumes to be filled... */

#define NFCSUMS  8192

struct {
  size_t fsize;
  int csum;
  int num;
} *fcsumsAddr;


/********************************* statfsBuf *********************************/
/*                                                                           */
/* The statfs structure for the filesystem on the disk being tested; used    */
/* to figure out how big it is, whether it is a cd-rom or not, etc.          */
/*                                                                           */
/*****************************************************************************/

struct statfs statfsBuf;


#if 0
/************************ maxFTW / countFTW / skipFTW ************************/
/*                                                                           */
/* These are global parameters to the ChecksumFilesFTW() function called     */
/* by ftw(3).  Specifically, they are:                                       */
/*                                                                           */
/*   maxFTW    - the maximum number of files to walk before aborting         */
/*   skipFTW   - the number of files to skip before beginning checksumming   */
/*   countFTW  - the number of files to checksum                             */
/*                                                                           */
/*****************************************************************************/

int maxFTW;
int countFTW;
int skipFTW;


/**************************** ChecksumFilesFTW() *****************************/
/*                                                                           */
/* This routine is used to do read-only filesystem testing, such as on a     */
/* cd-rom.  It walks the existing filesystem and checksums the files         */
/* specified above (by maxFTW, etc.), comparing them to the checksums which  */
/* were saved in the fcsumsAddr struct.  If there are any errors, they       */
/* are logged.                                                               */
/*                                                                           */
/*****************************************************************************/

/* ARGSUSED */
int ChecksumFilesFTW(path, statBuf, unused)
char *path;
struct stat *statBuf;
int unused;
{
  ssize_t n;
  int fd;
  int csum;

  PetWatchdog(-1);
  PetWatchdog(1);

  /* Don't return -1 for a directory or ftw(3) will puke... */
  if (countFTW >= maxFTW) {
    if (S_ISREG(statBuf->st_mode)) {
      return -1;
    }
    return 0;
  }
  if (skipFTW) {
    skipFTW--;
    countFTW++;
    return 0;
  }
  if (S_ISREG(statBuf->st_mode)) {
    if ((fd = open(path, O_RDONLY)) < 0) {
      Perror("open");
      HaltTests();
    }
    csum = 0;
    while ((n = read(fd, buffer, sizeof(buffer))) > 0) {
      csum += Checksum(0, buffer, (size_t)n);
    }
  } else {
    csum = Checksum(0, buffer, 0);
  }
  if (fcsumsAddr->csum[countFTW]) {
    if (fcsumsAddr->csum[countFTW] != csum) {
      Error("Actual csum %u != saved csum %u\n",
            csum, fcsumsAddr->csum[countFTW]);
      DumpFd(countFTW, fd);
      writeBuf = NULL;
      writeBufLen = 0;
      DumpSym(countFTW, path);
      Corruptions();
      HaltTests();
    }
  } else {
    fcsumsAddr->csum[countFTW] = csum;
  }
  if (S_ISREG(statBuf->st_mode)) {
    (void)close(fd);
  }
  countFTW++;
  return 0;
}
#endif



/***************************** ReadFileFTW() *********************************/
/*                                                                           */
/* This routine reads a given file (if not a directory) and                  */
/* verifies the checksum information. Any errors are logged.                 */
/*                                                                           */
/*****************************************************************************/

int ReadFileFTW(path, statBuf, unused)
char *path;
struct stat *statBuf;
int unused;
{
  ssize_t n;
  ssize_t size;
  int fd;
  int csum;
  size_t fsize;
  char tmp[8];


  PetWatchdog(-1);
  PetWatchdog(1);

  if (S_ISREG(statBuf->st_mode)) {

    if ((fd = open(path, O_RDONLY)) < 0) {
      Perror("open for reading");
      Log("Could not open %s for reading\n", namebuf1);
      return(-1);
    }

    csum = 0;
    size = 0;

    /*
    **  pull fsize and orig_csum from file
    */
    n = read(fd, tmp, 8);
    fcsumsAddr->fsize  = (int) (0x000000ff & (tmp[3]     ));
    fcsumsAddr->fsize += (int) (0x0000ff00 & (tmp[2] <<  8));
    fcsumsAddr->fsize += (int) (0x00ff0000 & (tmp[1] << 16));
    fcsumsAddr->fsize += (int) (0xff000000 & (tmp[0] << 24));
    fsize = fcsumsAddr->fsize;

    fcsumsAddr->csum  = (int) (0x000000ff & (tmp[7]     ));
    fcsumsAddr->csum += (int) (0x0000ff00 & (tmp[6] <<  8));
    fcsumsAddr->csum += (int) (0x00ff0000 & (tmp[5] << 16));
    fcsumsAddr->csum += (int) (0xff000000 & (tmp[4] << 24));


    while ((n = read(fd, buffer, sizeof(buffer))) > 0) {
      csum = Checksum(csum, buffer, (size_t)n);
      size += n;
    }
    if (n < 0) {
      Perror("read");
    } else if (size && size != fsize) {
      Error("File %s, Actual size %ld != request size %ld\n", path, size, fcsumsAddr->fsize);
      return(-1);
    }
    if (fcsumsAddr->csum != csum) {
      Error("Actual csum %u != saved csum %u for file %s\n",
            csum, fcsumsAddr->csum, path);
      return(-1);
    }
    (void)close(fd);

  }

  return(0);
}


/******************************  tmpFTW  *************************************/
/*                                                                           */
/* These are global parameters to the MatchFileFTW() function called         */
/* by ftw(3).  Specifically, they are:                                       */
/*                                                                           */
/*   tmpFTW    - the file sub string to test match                           */
/*   bufnumFTW - the namebuf to copy to                                      */
/*                                                                           */
/*****************************************************************************/

char tmpFTW[10];
int bufnumFTW;


/***************************** MatchFileFTW() ********************************/
/*                                                                           */
/* This routine is used to find a give file in the directory given it's      */
/* _num_ sub string.  It walks the existing filesystem and tests each file   */
/* against the _num_ substring.  If found, that files full path name is      */
/* copied into the appropriate namebuf.                                      */
/*                                                                           */
/*****************************************************************************/

int MatchFileFTW(path, statBuf, unused)
char *path;
struct stat *statBuf;
int unused;
{
  PetWatchdog(-1);
  PetWatchdog(1);

  if (strstr(path, tmpFTW) != NULL) {
    /*
    **  found it!, copy to proper name buf
    */
    if (bufnumFTW == 1) { 
      strcpy(namebuf1, path);
    } else {
      strcpy(namebuf2, path);
    }
    return(-1);
  } else {
    /*
    **  continue search
    */
    return(0);
  }
}



/**************************** Disk() *****************************************/
/*                                                                           */
/* This routine is the main disk test driver.  There is one instance of this */
/* routine for each disk device being tested.  Specifically, it does:        */
/*                                                                           */
/*   - check to see if the disk is already mounted, don't umount it if so    */
/*   - get the disk capacity and figure the filesystem size                  */
/*   - initialize the per-disk semaphores                                    */
/*   - check if disk is in use by swap, etc., if not, prep for raw tests     */
/*   - if the disk is read-only, then initialize the checksum data by        */
/*     reading all of the files once                                         */
/*   - then fork the actual testing processes and wait for them to finish    */
/*                                                                           */
/*****************************************************************************/

void Disk()
{
  int fd;
  int one;
  int zero;
  struct stat buf;		/* For call to stat() */
  struct statfs fsbuf;		/* for call to statfs() */
  unsigned dSize;
  char *fsDir;
  unsigned fsSize;
  unsigned rawOffset;
  int rawSize;
  int alreadyMounted = 1;	/* always 1 for MDI volume mount points */
  char *mountDir;
  char command[CMDLEN];

  fsDir = myPath;

/* JKH:  The following block of code tries to see if the FS is already mounted,
**       and if not mounts it.  In the current interface, the MDI volumes
**       MUST already be mounted, and if they're not, bail out.  At this
**       point, I don't know how to query a file and determine if it's a
**       file system mount point.  The best I can do right now is just
**       make sure the given mount point is in fact a directory.
*/

  if(stat(myPath,&buf))	{	/* Can we stat the file? */
    Perror("stat");
    Log("File %s does not appear to be a valid mount point.\n",myPath);
    HaltTests();
  } else {
    if(!S_ISDIR(buf.st_mode)) {	/* Is the file a directory? */
      Perror("stat");
      Log("File %s does not appear to be a valid mount point.\n",myPath);
      HaltTests();
    }
  }

  /*
  ** The following call to Ismountpoint actually determines whether the
  ** pathname given is that of a true mount point.  If not, bail out.
  */

  if(!Ismountpoint(myPath)) {
    Log("File %s is not a valid mount point!\n",myPath);
    HaltTests();
  }

  /*
  ** JKH:  In this version of distress, fsSize is the size of the filesystem
  ** in BLOCKS, not bytes.  I'm making this change to enable distress to
  ** deal with very big filesystems (> 4GB).
  */

  if(statfs(myPath,&fsbuf)) {	/* can we statfs the mount point? */
    Perror();
    Log("The file %s does not appear to be a valid mount point\n",myPath);
    HaltTests();
  } else {
    fsSize = (unsigned) fsbuf.f_blocks;
  }


  Log("Filesystem size is %u blocks of %u bytes each\n", fsSize,fsbuf.f_bsize);

  dskSem = InitSem();

  for (myLoadNum = 1; myLoadNum <= myLoad; myLoadNum++) {
    Fork(FilesystemStressRW, "FSRW", fsDir, alreadyMounted, fsSize,
		fsbuf.f_bsize);
  }
  myLoadNum = 0;

  Wait();
}




/******************************* PruneTree() *********************************/
/*                                                                           */
/* This routine prunes a given subtree as far up as possible if the subtree  */
/* is empty.                                                                 */
/*                                                                           */
/*****************************************************************************/

void PruneTree(bufnum)
int bufnum;

{
  int done;
  char *c;

  done = 0;
  while (!done) {

    StartStopWatch();
    /*
    **  get dirname
    */
    if (bufnum == 1) {
       if (strcmp(namebuf1, dirFill) == 0) {
         done = 1;
       } else {
         if ((c = rindex(namebuf1, '/')) != NULL) {
           *c = 0;  /* Kludge: force string termination */
         } else {
            done = 1;
         }
       }
    } else {
       if (strcmp(namebuf2, dirFill) == 0) {
         done = 1;
       } else {
         if ((c = rindex(namebuf2, '/')) != NULL) {
           *c = 0;  /* Kludge: force string termination */
         } else {
            done = 1;
         }
       }
    }

    if (!done) {
      if (bufnum == 1) {
        if(rmdir(namebuf1)) {
          done = 1;
        } else {
          DataLog(StopStopWatch(), "rmd", dirFill, namebuf1, 0); 
        }
      } else {
        if(rmdir(namebuf2)) {
          done = 1;
        } else {
          DataLog(StopStopWatch(), "rmd", dirFill, namebuf2, 0); 
        }
      }
    }
  }
}


/***************************** BuildPathBuf() ********************************/
/*                                                                           */
/* This routine builds a path name based on the file number and that files   */
/* name length.  If the name length is zero, a new path is created in given  */
/* namebuf array.  If the name length is non-zero, we will recursively       */
/* search starting from the num.0 directory until we find _num_*  (the files */
/* full path name will be in the namebuf in this case, rather than just the  */
/* path to the directory of the file.)                                       */
/*                                                                           */
/*****************************************************************************/

void BuildPathBuf(bufnum, num, makenew)
int bufnum;
int num;
int makenew;

{
  int i, j, local_depth, numlength;
  int pathnum;
  char tmp[10];


  if (myWidth > 0 && myDepth > 0) {

    if (makenew) {
      /*
      **  Create new random path, create each node if needed
      */
      if (bufnum == 1) {
        sprintf(namebuf1, "");
        strcat(namebuf1, dirFill);
        strcat(namebuf1, "/");
      } else {
        sprintf(namebuf2, "");
        strcat(namebuf2, dirFill);
        strcat(namebuf2, "/");
      }

      local_depth = Random(myDepth);

      StartStopWatch();

      for (i=0; i < local_depth; i++) {

        /*
        **  try to add random sub directory
        */
        pathnum = Random(myWidth);
        sprintf(tmp,"%ld",(long) pathnum);
        if (mkdir(tmp, 0777) == 0 || errno == EEXIST) {
          if (bufnum == 1) {
             strcat(namebuf1, tmp);
             strcat(namebuf1, "/");
          } else {
             strcat(namebuf2, tmp);
             strcat(namebuf2, "/");
          }
        
          /*
          **  change to the new sub directory
          */
          (void) chdir(tmp);
        } else {
          /*
          **  out of spare or something...give up making path
          */
          i = local_depth;
	}

      }

      if (bufnum == 1) {
        DataLog(StopStopWatch(), "mkd", dirFill, namebuf1, 0); 
      } else {
        DataLog(StopStopWatch(), "mkd", dirFill, namebuf2, 0); 
      }

      /*
      **  Change back to this tasks main sub directory
      */
      (void) chdir(dirFill);

    } else {
      /*
      **  Search for file _"num"_*
      */

      StartStopWatch();
      Log("Searching for %d\n", num);

      bufnumFTW = bufnum;
      sprintf(tmpFTW,"_%ld_",(long) num);
      ftw(dirFill, MatchFileFTW, MAXDEPTH);

      if (bufnum == 1) {
        DataLog(StopStopWatch(), "fnd", dirFill, namebuf1, 0); 
      } else {
        DataLog(StopStopWatch(), "fnd", dirFill, namebuf2, 0); 
      }
    }
  }
}


/***************************** BuildNameBuf() ********************************/
/*                                                                           */
/* This routine builds a file name based on the file number.  It will create */
/* a variable length name if argNameLength != 0, otherwise it will just use  */
/* the number itself.                                                        */
/*                                                                           */
/*****************************************************************************/

void BuildNameBuf(bufnum, num)
int bufnum;
int num;

{
  int i, addlength;
  char tmp[10];


  if (bufnum == 1) {
    BuildPathBuf(1, num, 1);
  } else {
    BuildPathBuf(2, num, 1);
  }

  sprintf(tmp,"_%ld_",(long) num);

  if (bufnum == 1) {
     strcat(namebuf1, tmp);
  } else {
     strcat(namebuf2, tmp);
  }

  addlength = Random(argNameLength);

  for (i=0; i < addlength; i++) {
     if (bufnum == 1) {
       strcat(namebuf1, "x");
     } else {
       strcat(namebuf2, "x");
     }
  }
}





/******************************* DeleteFile() ********************************/
/*                                                                           */
/* This routine deletes a file from the current directory                    */
/*                                                                           */
/*****************************************************************************/

void DeleteFile(num, fmin)
int num;
int *fmin;

{
  int delnum;

      /*
      **  First, read and delete a file (ReadFile will log the read)
      */
      delnum = *fmin;
      if (argDelRandom) {
        delnum += Random(num-1 - *fmin);
      } 

      ReadFile(delnum);

      BuildPathBuf(2, delnum, 0);

      StartStopWatch();

      if(unlink(namebuf2)) {
	Perror("unlink");
	Log("Unlink failed on file %s\n",namebuf2);
      }

      DataLog(StopStopWatch(), "del", dirFill, namebuf2, fcsumsAddr->fsize); 

      if (delnum != *fmin) {
        /*  
        **  Then, move fmin to delnum, and log the move 
        */
        BuildPathBuf(1, *fmin, 0);

        StartStopWatch();

        if(rename(namebuf1, namebuf2)) {
          Perror("rename");
          Log("Rename failed on file %s as %s\n", namebuf1, namebuf2);
        }
      
        DataLog(StopStopWatch(), " mv", dirFill, namebuf1, 0); 

        PruneTree(1);

      }
      (*fmin)++;
}


#ifndef TRUE
#define TRUE    1
#define FALSE   0
#endif

/******************************** WriteFile() ********************************/
/*                                                                           */
/* This routine writes a file named "num" in the current directory and       */
/* updates the checksum information for it in the fcsumsAddr struct.         */
/*                                                                           */
/*****************************************************************************/

void WriteFile(num,fmin)
int num;
int *fmin;
{
  int fd;
  int delnum;
  ssize_t n;
  int did_write;
  char tmp[12];

  did_write = TRUE;

  BuildNameBuf(1, num);

  StartStopWatch();

  if((fd = open(namebuf1, O_WRONLY | O_CREAT, 0666)) < 0) {
     if(errno == ENOSPC) {
       Log("In WriteFile, file = %s, ENOSPC\n", namebuf1);
       return;
     }
     Perror("open for writing");
     Log("Could not open %s for writing\n", namebuf1);
     HaltTests();
  }

  fcsumsAddr->fsize = Random(myBlocksize*
		(argMaxblocks-argMinblocks)) + myBlocksize*argMinblocks;

  /*
  **  make sure fsize isn't too large
  */
  if (fcsumsAddr->fsize > (myBlocksize*argMaxblocks - 12)) {
     fcsumsAddr->fsize -= 12;
  }

  /*
  **  try to put num, size and checksum as first part of file
  */
  fcsumsAddr->num = num;
  tmp[0] = ((0xff000000 & (long) fcsumsAddr->num) >> 24) & 0xff;
  tmp[1] = ((0x00ff0000 & (long) fcsumsAddr->num) >> 16) & 0xff;
  tmp[2] = ((0x0000ff00 & (long) fcsumsAddr->num) >>  8) & 0xff;
  tmp[3] = ((0x000000ff & (long) fcsumsAddr->num)      ) & 0xff;

  tmp[4] = ((0xff000000 & (long) fcsumsAddr->fsize) >> 24) & 0xff;
  tmp[5] = ((0x00ff0000 & (long) fcsumsAddr->fsize) >> 16) & 0xff;
  tmp[6] = ((0x0000ff00 & (long) fcsumsAddr->fsize) >>  8) & 0xff;
  tmp[7] = ((0x000000ff & (long) fcsumsAddr->fsize)      ) & 0xff;

  fcsumsAddr->csum = Checksum(0, *dataAddr+(num%NFCSUMS), fcsumsAddr->fsize);
  tmp[8] = ((0xff000000 & (long) fcsumsAddr->csum) >> 24) & 0xff;
  tmp[9] = ((0x00ff0000 & (long) fcsumsAddr->csum) >> 16) & 0xff;
  tmp[10] = ((0x0000ff00 & (long) fcsumsAddr->csum) >>  8) & 0xff;
  tmp[11] = ((0x000000ff & (long) fcsumsAddr->csum)      ) & 0xff;

  n = write(fd, tmp, 12);


  n = write(fd, *dataAddr+(num%NFCSUMS), fcsumsAddr->fsize);
  if (n < 0) {
    if(errno != ENOSPC) {
      Perror("write");
      HaltTests();
    } else {		/* ENOSPC case */ 

      /*
      **  First, read and delete a file (ReadFile will log the read)
      */

      did_write = FALSE;

      DeleteFile(num, fmin);

      /*
      ** This code is included here to skip the checksum step, since no
      ** file was created...
      */


      (void) close(fd);
      return;
    }
  } else {
    if (n != fcsumsAddr->fsize) {
      fcsumsAddr->fsize = n;
      fcsumsAddr->csum = Checksum(0, *dataAddr+(num%NFCSUMS), fcsumsAddr->fsize);

      Log("Filesystem is full; Actual size %d != request size %d, file %s (csum = %x)\n", 
		n, fcsumsAddr->fsize, namebuf1, fcsumsAddr->csum);

#if 0
      /*
      **  try to put new size and checksum as first part of file
      */
      lseek(fd, 0, SEEK_SET);
      sprintf(tmp, "%ld", (long) fcsumsAddr->fsize);
      n = write(fd, tmp, sizeof(long));

      fcsumsAddr->csum = Checksum(0, *dataAddr+(num%NFCSUMS), fcsumsAddr->fsize);
      sprintf(tmp, "%ld", (long) fcsumsAddr->csum);
      n = write(fd, tmp, sizeof(long));
#endif
      /*
      **  try to put num, size and checksum as first part of file
      */
      tmp[0] = ((0xff000000 & (long) num) >> 24) & 0xff;
      tmp[1] = ((0x00ff0000 & (long) num) >> 16) & 0xff;
      tmp[2] = ((0x0000ff00 & (long) num) >>  8) & 0xff;
      tmp[3] = ((0x000000ff & (long) num)      ) & 0xff;

      tmp[4] = ((0xff000000 & (long) fcsumsAddr->fsize) >> 24) & 0xff;
      tmp[5] = ((0x00ff0000 & (long) fcsumsAddr->fsize) >> 16) & 0xff;
      tmp[6] = ((0x0000ff00 & (long) fcsumsAddr->fsize) >>  8) & 0xff;
      tmp[7] = ((0x000000ff & (long) fcsumsAddr->fsize)      ) & 0xff;

      tmp[8] = ((0xff000000 & (long) fcsumsAddr->csum) >> 24) & 0xff;
      tmp[9] = ((0x00ff0000 & (long) fcsumsAddr->csum) >> 16) & 0xff;
      tmp[10] = ((0x0000ff00 & (long) fcsumsAddr->csum) >>  8) & 0xff;
      tmp[11] = ((0x000000ff & (long) fcsumsAddr->csum)      ) & 0xff;

      lseek(fd, 0, SEEK_SET);
      n = write(fd, tmp, 12);

      DataLog(StopStopWatch(), "wrt", dirFill, namebuf1, fcsumsAddr->fsize); 

      /*
      **  First, read and delete a file (ReadFile will log the read)
      */
      did_write = FALSE;

      DeleteFile(num, fmin);
    }
  }

  if (did_write) {
      DataLog(StopStopWatch(), "wrt", dirFill, namebuf1, fcsumsAddr->fsize); 
  }

  (void)close(fd);
}


/******************************* ReadFile() **********************************/
/*                                                                           */
/* This routine reads a file named "num" from the current directory and      */
/* verifies the checksum information for it from the fcsumsAddr struct.  Any */
/* errors are logged.                                                        */
/*                                                                           */
/*****************************************************************************/

void ReadFile(num)
int num;
{
  ssize_t n;
  ssize_t size;
  int fd;
  int csum;
  size_t fsize;
  char tmp[12];
char *c1, *c2;


  BuildPathBuf(1, num, 0);

#if 1
strcpy(namebuf2, namebuf1);
if ((c1 = rindex(namebuf2, '/')) != NULL) {
  c2 = c1;
  c2++;
  strcpy(namebuf1, c2);
  *c1 = 0;  
printf("%s\n", namebuf1);
printf("%s\n", namebuf2);
}
(void) chdir(namebuf2);
#endif


  StartStopWatch();

  if ((fd = open(namebuf1, O_RDONLY)) < 0) {
    Perror("open for reading");
    Log("Could not open %s for reading\n", namebuf1);
    HaltTests();
  }

  csum = 0;
  size = 0;

  /*
  **  pull fsize and orig_csum from file
  */
  n = read(fd, tmp, 12);
  fcsumsAddr->num  = (int) (0x000000ff & (tmp[3]     ));
  fcsumsAddr->num += (int) (0x0000ff00 & (tmp[2] <<  8));
  fcsumsAddr->num += (int) (0x00ff0000 & (tmp[1] << 16));
  fcsumsAddr->num += (int) (0xff000000 & (tmp[0] << 24));

  fcsumsAddr->fsize  = (int) (0x000000ff & (tmp[7]     ));
  fcsumsAddr->fsize += (int) (0x0000ff00 & (tmp[6] <<  8));
  fcsumsAddr->fsize += (int) (0x00ff0000 & (tmp[5] << 16));
  fcsumsAddr->fsize += (int) (0xff000000 & (tmp[4] << 24));
  fsize = fcsumsAddr->fsize;

  fcsumsAddr->csum  = (int) (0x000000ff & (tmp[11]     ));
  fcsumsAddr->csum += (int) (0x0000ff00 & (tmp[10] <<  8));
  fcsumsAddr->csum += (int) (0x00ff0000 & (tmp[9] << 16));
  fcsumsAddr->csum += (int) (0xff000000 & (tmp[8] << 24));


  while ((n = read(fd, buffer, sizeof(buffer))) > 0) {
    csum = Checksum(csum, buffer, (size_t)n);
    size += n;
  }
  if (n < 0) {
    Perror("read");
  } else if (size && size != fsize) {
    Error("File %s, Actual size %ld != request size %ld\n", namebuf1, size, fcsumsAddr->fsize);
    HaltTests();
  }
  if (fcsumsAddr->csum != csum) {
    Error("Actual csum %u != saved csum %u for file %s (orig num = %d)\n",
          csum, fcsumsAddr->csum, namebuf1, fcsumsAddr->num);
    DumpFd(fcsumsAddr->num, fd);
    writeBuf = DumpBuf(fcsumsAddr->num, *dataAddr+(fcsumsAddr->num%NFCSUMS), (size_t)fsize, "write");
    writeBufLen = fsize;
    Corruptions();
    HaltTests();
  }

#if 1
(void) chdir(dirFill);
strcat(namebuf2, "/");
strcat(namebuf2, namebuf1);
DataLog(StopStopWatch(), " rd", dirFill, namebuf2, fcsumsAddr->fsize); 
#else
  DataLog(StopStopWatch(), " rd", dirFill, namebuf1, fcsumsAddr->fsize); 
#endif

  fcsumsAddr->csum = csum;
  (void)close(fd);
}


/*************************** FilesystemStressRW() ****************************/
/*                                                                           */
/* This routine performs read-write filesystem stress on the disk.  It       */
/* does this by:                                                             */
/*                                                                           */
/*   - potentially newfs the disk again (synchronize with other procs!)      */
/*   - make sure the filesystem is mounted                                   */
/*   - create a private directory for each distress process working on       */
/*     this disk                                                             */
/*   - create lots of files in that directory                                */
/*   - as the directory gets too large, blow away the oldest files (after    */
/*     verifying their checksums first from the fcsumsAddr struct)           */
/*   - unmount the filesystem as appropriate                                 */
/*   - then potentially fsck the disk again (and again, synchronize!)        */
/*                                                                           */
/*****************************************************************************/

void FilesystemStressRW(fsDir, alreadyMounted, fsSize, blkSize)
char *fsDir;
int alreadyMounted;
unsigned fsSize;		/* fsSize is in BLOCKS! */
unsigned blkSize;		/* block size in BYTES! */
{
  int end;
  char *p;
  char *cpg;
  int fNum;
  int fCount;
  int fMin;			/* Number of oldest existing file */
  int blockSize;
  int fragSize;
  int loopcount;
  char command[CMDLEN];
  struct statfs fsbuf;
  struct timeval start_time, end_time;
  char buf[16];

  strcpy(dirMount, fsDir);

  strcpy(dirFill, fsDir);
  strcat(dirFill, "/");
  sprintf(buf,"%ld",(long) myLoadNum);
  strcat(dirFill,buf);

  if (alreadyMounted) {
    strcpy(command, "rm -rf ");
    strcat(command, dirFill);
    (void)Exec(command, -1, -1, -1, 1);

    dirFilled = 1;
  }

  fcsumsAddr = (void *)malloc(sizeof(*fcsumsAddr));
  bzero((char *)fcsumsAddr, sizeof(*fcsumsAddr));
  fNum = myWidth;
  fMin = myWidth;

  for (;;) {

    /*
    **  Assume all volumes are mounted at this point
    **  Perform an iteration of write/read testing
    */

    (void)chdir(fsDir);

    if (mkdir(dirFill, 0777) == 0) {
      if (statfs(myPath,&fsbuf) < 0) {
	Perror("statfs");
      }

      myBlocksize = fsbuf.f_bsize;
      fCount = (unsigned) (fsbuf.f_bavail / (myLoad*((argMinblocks +
				argMaxblocks) / 2))) + 1;

      if (argMaxfiles != 0) {
         fCount = argMaxfiles;
      }

      Log("Using %d files\n", fCount);
      fNum = myWidth;
      fMin = myWidth;
    }

    (void)chdir(dirFill);
    Log("Filling directory %s\n", dirFill);

    end = Time() + Random(TIME);
    while (Time() < end) {
      P(dskSem);		/* Get disk semaphore */
      if (fNum >= (fCount + myWidth)) {
        DeleteFile(fNum, &fMin);
      }
      WriteFile(fNum, &fMin);
      fNum++;
      V(dskSem);		/* Release disk semaphore */
    }
    Log("Finished %d files\n", fNum);

    /*
    **  Randomly do a full recursive checksum
    */
    if (argDoFTWRead && (iter % argDoFTWRead == 0)) {
      P(dskSem);		/* Get disk semaphore */
      P(mountSem);
      StartStopWatch();
      Log("Starting FTW Checksum Read of %s\n", dirFill);

      if (ftw(dirFill, ReadFileFTW, MAXDEPTH)) {
        Error("FTW ReadFile failed for directory %s\n", dirFill);
	HaltTests();
      } 
      DataLog(StopStopWatch(), "ftw", dirFill, dirFill, 0); 
      V(mountSem);
      V(dskSem);		/* Release disk semaphore */
    }



    /*
    **  Perform unmount/mount testing
    */
    (void)chdir(argWorkDir);

    if (argMount && (iter % argMount == 0) && Ismountpoint(myPath)) { 	
      P(dskSem);
      P(mountSem);

      StartStopWatch();
      if (MDI_Unmount(fsDir) != 0) {
	Error("Unmount failed!\n");
	HaltTests();
      }
      DataLog(StopStopWatch(), "umt", dirFill, fsDir, 0); 

      Log("filesystem unmounted\n");

      StartStopWatch();
      if (MDI_Mount(myVolname, fsDir) != 0) {
	Error("Mount failed!");
	HaltTests();
      }
      DataLog(StopStopWatch(), " mt", dirFill, myVolname, 0); 

      if (myHd) {
         Log("Filesystem mounted w/ hd cache\n");
      } else {
         Log("Filesystem mounted\n");
      }
      
      V(mountSem);
      V(dskSem);
    }

    Sleep(Random(STIME));

    iter++;
  }
}

#ifndef TRUE
#define TRUE    1
#define FALSE   0
#endif

#ifdef MAXNAME
#undef MAXNAME
#endif /* MAXNAME */

#define MAXNAME   256   /* Maximum length of a pathname */

/*****************************************************************************
** Ismountpoint():  This function takes a pathname as argument and determines
**                  whether or not it is a mount point.
**
** Return Values:  Returns TRUE (nonzero value) if the given file is a mount
**                 point; returns FALSE (0) otherwise.
**
** ALGORITHM:
**
** Stat the file given by the argument pathname.  If stat fails, or if the
** the file is not a directory, return FALSE.
**
** Special case:  if the file is '/' (root), return TRUE, since the root
** directory is a mount point.  This case must be handled separately because
** root's parent is itself, and hence will fail the test given below.
** This method is slightly different from how the find command does it:
** find checks for child inode id = 2, and if parent device is the same
** as child device then we've got a mount point, but I don't like that
** method because it seems to be pretty specific to Unix file systems.
**
** Determine the name of the file's parent.  In normal cases (i.e., absolute
** pathnames) we just work backwards through the pathname and strip off
** characters until we hit a '/'.  If the filename was just given as
** a single file name (no path), we use '..' as the parent.  
**
** Stat the parent.  If stat fails, something is wrong and report a fatal
** error.  Check to see if the device type of the parent is different from
** that of the child:  if so, then we have a mount point.  Otherwise we don't.
*****************************************************************************/

int
Ismountpoint(pathname)
char  *pathname;
{
  struct stat   current_buf;  /* For current file's stat info */
  struct stat   parent_buf;   /* For parent's stat info */
  char    parent_name[MAXNAME];
  char    cur_dir[MAXNAME];
  int     end;
  int     i;

  /*
  ** Stat the argument file, and verify that it is a directory
  */

  if(stat(pathname,&current_buf) != 0) {  /* Stat failed */
    return FALSE;
  }

  if(!S_ISDIR(current_buf.st_mode)) {  /* Not a directory! */
    return FALSE;
  }

  /*
  ** Special case:  root '/' is a mount point.  We have to check
  ** for this case first, because the normal algorithm won't
  ** work for root.  
  */

  if(strcmp(pathname,"/") == 0) {
    return TRUE;
  }

  /*
  ** Parse through the pathname and construct the parent's name
  */

  end = 0;
  for(i = strlen(pathname) - 1; i >= 0; i--) {
    if(pathname[i] == '/')
    {
      end = i;
      break;
    }
  }
  if(i >= 0) {
    if(end == 0)    /* Root is parent! */
    {
      strcpy(parent_name,"/");
    } else {
      strncpy(parent_name,pathname,end);
      parent_name[end] = '\0';
    }
  } else {        /* No path given */
    strcpy(parent_name,"..");
  }

  /*
  ** Stat the parent!
  */

  if(stat(parent_name,&parent_buf) != 0) {  /* Stat failed */
    (void) fprintf(stderr,"ERROR:  stat failed on parent %s\n",
        parent_name);
    exit(1);
  }

  /*
  ** Another special case:  if the path was specified as '.', for
  ** instance, and we're in /, we need to see if the child has
  ** inode value 2.  This number is specific to Unix file systems,
  ** but I believe root '/' is guaranteed to be a Unix file system.
  */

  if(current_buf.st_ino == 2) {
    return TRUE;
  }

  /*
  ** Compare parent and child's device fields, and return a value
  ** accordingly
  */

  if(current_buf.st_dev != parent_buf.st_dev) {
    return TRUE;
  } else  {
    return FALSE;
  }
}



/******************************** MDI_Mount() ********************************/
/*                                                                           */
/* This routine creates system command string specifically for MDI nsrutil   */
/* command line utility that mounts volumes                                  */
/*                                                                           */
/*****************************************************************************/

int MDI_Mount(volumename, mountpoint)
char *volumename;
char *mountpoint;

{
  char command[CMDLEN];

  if (myHd) {
    sprintf(command, 
		 "nsrutil mount %s %s rw syspart 2>&1 >/tmp/nsrutil.mount.log", 
		 volumename, mountpoint);
  } else {
    sprintf(command, 
		 "nsrutil mount %s %s rw 2>&1 >/tmp/nsrutil.mount.log", 
		 volumename, mountpoint);
  }
  if (system(command) != 0) {
    return(1);
  } else {
    return(0);
  }
}



/******************************** MDI_Unmount() ******************************/
/*                                                                           */
/* This routine creates system command string specifically for MDI nsrutil   */
/* command line utility that un-mounts volumes                               */
/*                                                                           */
/*****************************************************************************/

int MDI_Unmount(mountpoint)
char *mountpoint;

{
  char command[CMDLEN];

  sprintf(command, 
		"nsrutil unmount %s 2>&1 >/tmp/nsrutil.umount.log", mountpoint);
  if (system(command) != 0) {
    return(1);
  } else {
    return(0);
  }
}
