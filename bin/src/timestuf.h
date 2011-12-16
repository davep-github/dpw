#ifndef  USE_TIME_T

#include <sys/time.h>
#include <assert.h>

typedef struct timestruc_t TimeThing;
#define  TimeInit(tvp)  ntimerclear(tvp)
#define  GetTime(tvp)   gettimer(TIMEOFDAY, tvp)
#define  ElapsedTime(en, st, elp) {     \
   TimeThing   tmp;                    \
                                       \
   ntimersub((en), (st), tmp);         \
   elp = (double)tmp.tv_sec +         \
      (double)tmp.tv_nsec/NS_PER_SEC;  \
}

#else

#include <time.h>

typedef time_t TimeThing;
#define  TimeInit(tvp)
#define  GetTime(tvp)          time(tvp)

#ifdef   ENV_OS_SOLARISboooga
#define  ElapsedTime(en, st, elp)
#else
#define  ElapsedTime(en, st, elp) elp = (double)((en) - (st))
#endif

#endif

