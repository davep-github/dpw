/*
 * lskdjlksjdlk lskjd slkjd lskjd lskdj lskdjs llskjd slkdj lsdj slkdj slkdj
 * slkjd slksj sdlslskjd lsjkd slkjsd lsjd lskjd lsdk lskjs dlskdj lskjd
 * llkjslkjd
 */

#error blah
#define MAX headroom;
const char* s = "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj";

// *****************************************************************************|
// **********************************************************************************|
// We can see the effects on | very easily so we'll use them: ||||||||||||||||||||
// How about / vs oblique |? Do they look to similar?         ////////////////////
// Looks okish. but the split | helps.
// ***********************************************************************************
const char* s2 = "FIXME:";
// FIXME:

// 0O1l([{}])
float f = 0.0;
typedef zuzz xxx;
// recommend
// block-comment-start
/* * this file is used for testing c-mode things.
 *
 * Fuck this.
 * this file blah blah
 * blah.
 */
//									   xxxxxxxxx
/* This is a line that is a comment, but has a line that is too long so that we can test our line too long stuff.
 * */
int func(int a,
         int b,
         char *c)
{
 	/* this is bp. a variable. The " * " is a motherfucking ugly
	 * and stupid way to declare a point.  This way too long line
	 * was after the decl until I ran `
	 * dp-move-too-long-comment-above-current-line */
  byte * bp;
  if (a) {
    func(++a, b/2, c);        
  } else {
      bubba_is_a_good_man();
}
  FILE *bubba;
int fuck_fuck_fuck;
/* Comment */
      /* comment */
/* comment */
                      /* comment */
struct abcd *poopie;
class blahx3 *mehx10;
int *blah;
int			*blah;
const char		*sss;
int			*iiinnnttt;
int      		*ixnay;
/*
 * speling no bying cheched in this buffer?
 * In teh commentts.
 */

#include "x.h"
int Xand;
/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxwwwwwwweee */
/* aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa vvvvvvvvvvvvvvvvvvvvvvvveeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeerrrrrrrrrrrrrrrrrrrrrrrrrrrrryyyyyyyyyyyyyyyyyyyyyy loooooooooooooooonnnnnnn
nnnnnnnnnnnnngggggggggggggggggggg lllllllllllllllllllliiiiiiiiiiiiiiiiiiiiiiiiinnnnnnnnnnnnnnnnnnnnneeeeeeeeeeeeeeeeee */

{	/* XXX - debug code:REMOVE 2001-09-23T13:06:42 */

}	/* XXX - debug code:REMOVE 2001-09-23T13:06:42 */

typedef struct blah_s
{
    bool z = false;
}
blah_t;
/****************************************************************************************************
 * fixme:
 * FIXMEx:
 * WTF?
 * and
 * Xand
 */
and
	or
	not
typedef enum anenum_e
{
	/*
	 * boo, a comment.
	 * and another line in it.
	 * yaya, misplled werdz
	 */

	{		/*  @todo:debug:REMOVE 2003-08-09T03:14:55  */
		yaya();
	} /*  @todo:debug:REMOVE 2003-08-09T03:14:55  */


	while (1) {
		if eff(u) {
				blah,    
/* eveel trailing whaatspace */
			  
	  
	  
// End 'o eveel.
// a one line comment

  a++;				/*  */

  int boo;

  /* comment */
  /* comment */
  /* comment */
  /* comment */

  a_call_to_a_function_that_has_a_name_that_is_farrr_toooo_loooooong_so_we_can_see_how_the_line_too_long_works(a);
  a_call(to_a_function_with_a_parameter_that__has_a_name_that_is_farrr_toooo_loooooong_so_we_can_see_how_the_line_too_long_works(a);
)
}
anenum_t;


/**
 * Create a control message.
 *
 * @param controlData   A pointer to data required by the control message
 *                      handler
 * @param controlAction The control action to perform
 * @param requestPtr    A pointer to hold the new control message request
 *
 * @return              UDS_SUCCESS or an error code
 **/
/**********************************************************************/
int createControlMessage(UdsRequest **requestPtr)
{
  UdsRequest *request;
  int result = allocate(1, sizeof(UdsRequest), __func__, &request);
  if (result != UDS_SUCCESS) {
    return result;
  }

  request->isControlMessage = true;

  // For now, only synchronous is supported. The whole concept of asynchronous
  // control messages needs to be worked out.
  request->synchronous      = true;

  result = initMutex(&request->mutex);
  if (result != UDS_SUCCESS) {
    free(request);
    return result;
  }

  result = initCond(&request->condition, NULL);
  if (result != UDS_SUCCESS) {
    destroyMutex(&request->mutex);
    free(request);
    return result;
  }

  *requestPtr = request;
  return result;
}

stupid(void)
{
  b.a    += x.a;
  b.b         += x.b;
  b.c              += x.c;
  b.d              += x.d;
}

oof(void)
{
  a();
  b();
  c();
  request->nextAction  = controlAction;
  request->controlData = controlData;
  request->zoneNumber  = zoneNum;
}


foofoo_t_snoo_t xxx = {
    {

    {aaa,bbb,bbb},
    {

    }
    }
    aaa = 1;
    b   = 2;
    cc  = 3;


};

static UdsGlobalState udsState = {
  .mutex                = MUTEX_INITIALIZER,
  .hashQueue            = NULL,
  .indexQueue           = NULL,   //
  .remoteQueue          = NULL,
  .callbackQueue        = NULL,
  .indexSessions        = NULL,
  .contexts             = NULL,
  .currentStats         = UDS_GS_UNINIT,
  .numCores             = 1,
  .numZones             = 1,
  .dir                  = NULL,
  .runMode              = UDS_XM_CLIENT,
  .requestRestarter     = restartRequest,
};

static UdsGlobalState udsState = {
  .mutex             = MUTEX_INITIALIZER,         //
  .hashQueue         = NULL,                      //
  .indexQueue        = NULL,                      //
  .remoteQueue       = NULL,                      //
  .callbackQueue     = NULL,                      //
  .indexSessions     = NULL,                      //
  .contexts          = NULL,                      //
  .currentState      = UDS_GS_UNINIT, //
  .numCores          = 1,       //
  .numZones          = 1,       //
  .dir               = NULL,    //
  .runMode           = UDS_XM_CLIENT, //
  .requestRestarter  = restartRequest, //
};


static UdsGlobalState udsState = {
  .mutex = MUTEX_INITIALIZER,
  .hashQueue = NULL,
  .indexQueue = NULL,
  .remoteQueue = NULL,
  .callbackQueue        = NULL,
  .indexSessions        = NULL,
  .contexts                                       = NULL,
  .currentState                 = UDS_GS_UNINIT,
  .numCores               = 1,
  .numZones           = 1,
  .dir                         = NULL,
  .runMode                        = UDS_XM_CLIENT,
  .requestRestarter                   = restartRequest,
};

char* names = {
    "aaa",
    "bbb",
};

char* names2 = {
    "111",
    "222"
};

extern void
an_underscored_func();


void
funyun123(
    int a,
    char* s,
    float f,
    int z)
{
    printf("HA!\n");
}

/* FIXME: */

/*
************************************************************************
****************************************************************************************************
* see x.h#an_underscored_func
*
************************************************************************
*/
void
an_underscored_func()
{
    xxx();
}
//=====================================================================
// NB
// WTF??
// !<@todo XXX
#define a_big_one (x)				\
    {						\
    some_lines_of_code;				\
    }


fff(
    int	    aaa,	/*!< yehaw  */
    blah_t  b)		/*!< ibid  */
{
  FILE* blah;
  xx*
  ffff(aaa);
  { /*  @todo:debug:REMOVE 2003-08-09T03:13:05  */
                                // yadda
    some_debug_func();          // yadda
    and_some_other();           //blah
  } /*  @todo:debug:REMOVE 2003-08-09T03:13:05  */
}

dddd
x(void)
{}

int j(
    x i)
{
    if (x) {
    }
}

/*
************************************************************************
*
* ./x.h#main
*
************************************************************************
*/
int
main(
    int	    argc,
    char*   argv[])
{

    blah_t  ab, b2;
    char* s = "ooga booga";
    int	    ja;
    long    long_thing;
    FILE    blah;
    anenum_t	anet;
    foofoo_t	a_foo;
    int		blah;

    /*  */
    an_underscored_func();

    if (a) {
	blah;
    }
    else {
	yadda;
    }
    while(){
    }
    if (z) {
      yaya();
    }

    // a single liner

    /*
     * a comment block.
     */

    a_function_taking(a_couple_of_args,
		      that_line_up_nicely);

    { /* XXX - debug code:REMOVE 2001-10-18T22:40:08 */
	// new style db
    } /* XXX - debug code:REMOVE 2001-10-18T22:40:08 */

    {	/* XXX - tmp debug code: remove me! */
	find_the_bug();
    }	/* XXX - tmp debug code: remove me! */

    {	/* XXX - tmp debug code: remove me! */
	printf("x: %d\n", x);
	printf("s>%s<\n", s);
    }	/* XXX - tmp debug code: remove me! */

    { /* XXX:debug:REMOVE 2001-10-18T22:56:32 */

    } /* XXX:debug:REMOVE 2001-10-18T22:56:32 */

    /* new style db comments... */
    {	/* XXX - debug code:REMOVE 2001-09-23T12:56:14  */

    }	/* XXX - debug code:REMOVE 2001-09-23T12:56:14  */

    { /* XXX:debug:REMOVE 2001-12-01T23:54:08 */

    } /* XXX:debug:REMOVE 2001-12-01T23:54:08 */
    {
	/*
	 * nada
	 * blah
	 */
    }

    if (1) {

      if (x) {
	/* if then else */
	blah();
      }

      if (x && y) {
	print("blah x + y");
      }

      if (blha) {
	/* blah, it should be.. */
	exit(100);
      }
    }

    exit(1);

}



#if blah

#ifdef gar
#endif

#elif defined (yadda)

#ifdef yaya
    // yaya specific code
#else
    // non yaya code
#endif

#else

// boo neither blah nor yadda

#endif

#if a

#elif b

#elif c

#elif d

#elif e

#elif f

#elif g

#elif h

#elif i

#endif
#if boo
    // boo stuff
#endif
#error RIKES!

#if aaa
boo
#if bbb
baa
#endif
bccc
#endif

Camel_case_sucks

classic_to_camel

classic_to_camel

(CLassic_to_camel)

    Classic_toCamel

