/*
 *
 * Title:         SUSHI Lexical Analyzer
 * Product:       Novell 386 Express
 * Part:          SCSI Utilities Shell Interpreter (SUSHI)
 * $Workfile:   LEXER.C  $
 * $Revision: 1.1 $
 * Language:      
 * Author:        David Panariti
 * Description:
 *
 * Entry Points:
 *
 * History:
 *
 * $Log: sushi-lexer.c,v $
 * Revision 1.1  2003/04/18 17:23:42  davep
 * *** empty log message ***
 *
 * 
 *    Rev 1.1   02 Dec 1993 16:31:14   D. C. Hand
 * Set up for new compiler
 * 
 *    Rev 1.0   02 Nov 1993 11:50:56   D.C. Hand
 * RELEASE VERSION 1.4.0
 * 
 *    Rev 1.2   10 Oct 1990 15:11:04   David A. Panariti
 * Support for character constants ('c')
 * 
 * 
 *    Rev 1.1   09 Jul 1990  8:26:32   David A. Panariti
 * 
 *    Rev 1.0   08 May 1990  9:00:08   David A. Panariti
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
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "types.h"
#include "file.h"
#include "su.h"
#ifdef DEBUG
#undef DEBUG
#endif
#include "y.tab"

extern void GetNum();
extern void GetS();
extern char *STREMalloc();
extern int ExecError();
extern void TRACE0();
extern void TRACE2();
#define uint uint32


/*
************************************************************************
*
*
*
************************************************************************
*/
yylex()
{
   int   token;

   token = Doyylex();

   TRACE2("yylex returning[%c, 0x%04x]\n", isprint(token) ? token : '.', token);

   return (token);
}
Doyylex()
{
   char  fileName[80];
   int   c, c2;
   extern uint eatNL;

YYLEXLoop:

   while ((c = Get(fin)) == ' ' || c == '\t')
      ;

   TRACE2("in yylex(), c == `%c' == 0x%02x\n", isprint(c) ? c : '.', c);

   if (c == '$')
   {
      int   n;

      GetNum(fin, &n, 10);

      if (n == 0)
         ExecError("strange $..\n");

      yylval.narg = n;
      return (ARG);
   }
         
   if (c == '@')
   {
      (void)GetS (fin, fileName);
      PushInputStream (fileName);
      goto YYLEXLoop;
   }


   
   if (c == EOF)
   {
      if (PopInputStream())
         goto YYLEXLoop;
      return (0);
   }

   TRACE0("past EOF check\n");

   if (c == '#')
      return (BUF);

   TRACE0("past BUF check\n");

   if (c == '-')
   {
      char  tmp[3];
      Symbol   *s;
      
      if ((c = Get(fin)) == EOF)
         goto YYLEXLoop;

      sprintf(tmp, "-%c", c);
      if ((s = SymLook(tmp)) != (Symbol *)NULL)
         return (s->u.val);
      Unget(c, fin);
      c = '-';
   }

   TRACE0("past `-' check\n");

      
   if (c == '0')
   {
      if ((c = Get(fin)) == EOF)
         goto YYLEXLoop;
      
      if (c == 'x' || c == 'X')
      {
         GetNum (fin, &yylval.narg, 16);
         return (NUMBER);
      }
      Unget(c, fin);
      if (c >= '0' && c < '8')
         GetNum (fin, &yylval.narg, 8);
      else
         yylval.narg = 0;
      return (NUMBER);
   }

   TRACE0("past `0' check\n");
      
   if (isdigit(c))
   {
      Unget(c, fin);
      GetNum (fin, &yylval.narg, 10);
      return (NUMBER);
   }

   TRACE0("past isdigit() check\n");

   if (c == '\'') // char constant???
   {
      if ((c = Get(fin)) == EOF)
         goto YYLEXLoop;

      yylval.narg = Backslash(c);

      if ((c = Get(fin)) == EOF)
         goto YYLEXLoop;

      if (c != '\'')
         ExecError("badly formed character constant\n");

      return (NUMBER);
   }

   if (isalpha(c) || c == '.' || c == '_')
   {
      Symbol   *s;
      char  sBuf[100], *p = sBuf;
      int   cWasDot;

      cWasDot = c == '.';

      do
      {
         if (p >= sBuf + sizeof (sBuf) - 1)
         {
            *p = 0;
            ExecError("name too long: %s\n", sBuf);
         }
         *p++ = c;
      }
      while ((c = Get(fin)) != EOF && (isalnum(c) || c == '_'));
      Unget(c, fin);
      *p = '\0';
      if ((s = SymLook(sBuf)) == (Symbol *)NULL)
         if (!cWasDot)
            s = SymAdd(sBuf, UNDEF, 0);
         else
            ExecError("unknown dot command: %s\n", sBuf);
         
      yylval.sym = s;
      return ((s->type == UNDEF) ? VAR : s->type);
   }

   TRACE0("past isalpha() check\n");

   if (c == '"')
   {
      char  sBuf[100], *p, *StrEMalloc();

      for (p = sBuf; (c = Get(fin)) != '"'; p++)
      {
         if (c == '\n' || c == EOF)
            ExecError("missing quote\n");
         if (p >= sBuf + sizeof (sBuf) - 1)
         {
            *p = '\0';
            ExecError("string too long: %s\n", sBuf);
         }
         *p = Backslash(c);
      }
      *p = 0;
      yylval.sym = (Symbol *)StrEMalloc(strlen(sBuf) + 1);
      strcpy((char *) yylval.sym, sBuf);
      return (STRING);
   }

   TRACE0("past `\"' check\n");

   switch (c)
   {
      case '>':
         if ((c2 = Follow('=', GE, GT)) != GE)
            if ((c2 = Follow('>', RSH, GT)) == RSH)
               c2 = Follow('=', RSHEQ, RSH);
         return (c2);
         break;

      case '<':
         if ((c2 = Follow('=', LE, LT)) != LE)
            if ((c2 = Follow('<', LSH, LT)) == LSH)
               c2 = Follow('=', LSHEQ, LSH);
         return (c2);
         break;

      case '=':
         return (Follow('=', EQ, '='));
         break;
      case '!':
         return (Follow('=', NE, NOT));
         break;

      case '|':
         return (Follow2('|', '=', OR, OREQ, BITOR));
         break;

      case '&':
         return (Follow2('&', '=', AND, ANDEQ, BITAND));
         break;

      case '?':
         yylval.sym = SymLook("print");
         return (yylval.sym->type);

      case '+':
         return (Follow('=', PLUSEQ, '+'));

      case '-':
         return (Follow('=', MINUSEQ, '-'));

      case '*':
         return (Follow('=', TIMESEQ, '*'));

      case '/':
         if (Follow ('/', 0, 1))
            return (Follow ('=', DIVEQ, '/'));

         for (;;)
            if (((c = Get(fin)) == EOF) || (c == '\n'))
               break;

         Unget (c, fin);
         goto YYLEXLoop;
         break;

      case '^':
         return (Follow('=', XOREQ, '^'));

      case '\n':
         LineNum++;
         return ('\n');
         break;

      default:
         return (c);
   }
}

/*
************************************************************************
*
*
*
************************************************************************
*/
Follow(expect, ifYes, ifNo)
int   expect;
int   ifYes;
int   ifNo;
{
   int   c;

   c = Get(fin);

   if (c == expect)
      return(ifYes);
   Unget(c, fin);
   return (ifNo);
}

/*
************************************************************************
*
*
*
************************************************************************
*/
Follow2(c1, c2, isC1, isC2, neither)
int   c1, c2, isC1, isC2, neither;
{
   int   c;

   c = Get(fin);

   if (c == c1)
      return (isC1);
   if (c == c2)
      return (isC2);
   Unget(c, fin);
   return (neither);
}

/*
************************************************************************
*
*
*
************************************************************************
*/
Backslash(c)
int   c;
{
   char     *strchr();
   register char  *p;
   static char transTab[] = "b\bf\fn\nr\rt\t";

   if (c != '\\')
      return (c);

   c = Get(fin);
   
   if (islower(c) && (p = strchr(transTab, c)))
      return (*(p + 1));

   return (c);
}

/*
************************************************************************
*
*
*
************************************************************************
*/

static char digits[] =  "0123456789ABCDEF";

void  GetNum (fin, pNum, base)
FileAccess  *fin;
int         *pNum;
int         base;
{
   char  *pMark;
   char  *p;
   int   c;

   *pNum = 0;
   pMark = digits+base;

   for (;;)
   {
      if ((c = Get (fin)) == EOF)
         break;

      if ((p = strchr (digits, islower (c) ? toupper (c) : c)) == NULL)
         break;

      if (p >= pMark)
         break;

      *pNum = ((*pNum) * base) + (p - digits);
   }

   Unget (c, fin);
}

/*
************************************************************************
*
*
*
************************************************************************
*/

void  GetS (fin, buf)
FileAccess  *fin;
char        *buf;
{
   int   c;

   for (;;)
   {
      if ((c = Get(fin)) == EOF)
         break;

      if (isspace (c))
         break;

      *buf++ = c;
   }

   *buf = 0;
   Unget (c, fin);
}


