#ifndef SU_H_INCLUDED
#define SU_H_INCLUDED
/*
 *
 * Title:       SUSHI Main definition file
 * Product:     Novell 386 Express
 * Part:        SCSI Utilities Shell Interpreter (SUSHI)
 * $Workfile:   SU.H  $
 * $Revision: 1.1 $
 * Language:    
 * Author:      David Panariti
 * Description:
 *
 * Entry Points:
 *
 * History:
 *
 * $Log: sushi-su.h,v $
 * Revision 1.1  2003/04/18 17:23:42  davep
 * *** empty log message ***
 *
 * 
 *    Rev 1.1   02 Dec 1993 16:31:40   D. C. Hand
 * Set up for new compiler
 * 
 *    Rev 1.0   02 Nov 1993 11:50:38   D.C. Hand
 * RELEASE VERSION 1.4.0
 * 
 *    Rev 1.3   30 Jul 1991  8:28:16   James E. Duke
 * Added pause function.
 * 
 *    Rev 1.2   06 Mar 1991 16:09:12   James E. Duke
 * Added function prototypes.
 * 
 *    Rev 1.1   09 Jul 1990  8:32:36   David A. Panariti
 * Reflects changes for new COMMANDs
 * 
 * 
 *    Rev 1.0   08 May 1990  9:01:46   David A. Panariti
 * Initial revision.
 *
 * (C) Copyright 1990  Micro Design International, Inc.
 *     ALL RIGHTS RESERVED
 */

/***************************************************************************
*                                                                          *
*                            * N O T I C E *                               *
*                                                                          *
*  THIS PROGRAM BELONGS TO Micro Design International, Inc.  IT IS         *
*  CONSIDERED A TRADE SECRET AND IS NOT TO BE DIVULGED OR USED BY          *
*  PARTIES WHO HAVE NOT RECEIVED WRITTEN AUTHORIZATION FROM THE OWNER.     *
*                                                                          *
***************************************************************************/

typedef int    (*Inst)();
#define STOP      ((Inst)0)

typedef struct Buf
{
   uint32  size;
   char  *buf;
}
   Buf;

typedef struct Symbol
{
   struct Symbol  *next;
   struct Symbol  *symTab;
   
   char     *name;
   uint32     type;

   union
   {
      int   val;
      int   (*func)();
      int   (*definition)();
      char  *str;
   }
      u;
}
   Symbol;

   
Symbol   *SymAdd();
Symbol   *SymLook();
Symbol   *GetStringSym();

typedef union Datum
{
   int      val;
   Symbol   *sym;
}
   Datum;


extern uint32 TmpTID;
extern uint32 TmpLUN;
extern uint32 TmpBUF;
extern uint32 TmpSEC;
extern uint32 TmpNUM;
extern uint32 TmpHA;

extern uint32 TID;
extern uint32 LUN;
extern uint32 BUF;
extern uint32 SEC;
extern uint32 NUM;
extern uint32 HA;

extern int     InDef;
extern Symbol  *DefSym;

extern uint32 LineNum;

extern int  gargc;
extern char **gargv;
extern Inst *progp, *pc;

extern void ProcRet(), Call(), DefOnly(), ArgAssign(), FuncRet(), Arg(),
      Define(), BreakCode(), ContinueCode();

extern void SetBufElement(), GetBufElement();
extern void SetBuf(), SetBufEq(), SetBufSize();
extern void GetBufSize(), PrintBuf();
extern void BufCmp(), BufIsVal(), BufIsNotVal(), BufNotCmp();

extern void SCSIFunc();

extern void AssignGlobal();
extern void BuiltIn();
extern void Command();
extern void Eval();
extern int  SUSHISRand(), SUSHIAbort();
extern uint32  SUSHIRand();
extern uint32 SUSHIDelay();
extern void   SUSHIPause();
extern void SUSHIQuit(), SymbolTableDump();
extern int  SUSHICls();
extern int  StringPrint(int bufNo);
extern void VarPush();
extern void ConstPush();
extern void Print(), prstr(), PrExpr();
extern Inst *code(), *progbase;
extern Datum   pop();
extern void Assign();
extern void PlusEq(), MinusEq(), TimesEq(), DivEq(), AndEq(), OrEq();
extern void XorEq(), LshEq(), RshEq();
extern void Add(), Sub(), Mul(), Div(), Eq(), Ne(), Le(), Ge(),
      Gt(), Lt(), BitAnd(), BitOr(), BitXor(), Lsh(), Rsh();
extern void Negate(), And(), Or(), Not();
extern void WhileCode(), IfCode(), ForCode();

extern Buf  *GetBuf();
extern void ResizeBuf();
extern void Execute();
extern void ControlCPressed ();
extern void SetGlobalTmps ();
extern uint32  BufferAddress ();
# define SOTID 257
# define SOLUN 258
# define SOBUF 259
# define SOSEC 260
# define SONUM 261
# define SOHA 262
# define OPTION 263
# define VAR 264
# define SFUNC 265
# define UNDEF 266
# define KEYWORD 267
# define PRINT 268
# define STRING 269
# define WHILE 270
# define IF 271
# define ELSE 272
# define DOTSIZE 273
# define END 274
# define BLTIN 275
# define FOR 276
# define CMD 277
# define FUNCTION 278
# define FUNC 279
# define RETURN 280
# define PROCEDURE 281
# define PROC 282
# define NUMBER 283
# define BUF 284
# define ARG 285
# define BREAK 286
# define CONTINUE 287
# define PLUSEQ 288
# define MINUSEQ 289
# define TIMESEQ 290
# define DIVEQ 291
# define ANDEQ 292
# define OREQ 293
# define XOREQ 294
# define LSHEQ 295
# define RSHEQ 296
# define OR 297
# define AND 298
# define BITOR 299
# define BITXOR 300
# define BITAND 301
# define EQ 302
# define NE 303
# define GT 304
# define GE 305
# define LT 306
# define LE 307
# define LSH 308
# define RSH 309
# define UNARYMINUS 310
# define NOT 311

#endif

