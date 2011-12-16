
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     SOTID = 258,
     SOLUN = 259,
     SOBUF = 260,
     SOSEC = 261,
     SONUM = 262,
     SOHA = 263,
     OPTION = 264,
     VAR = 265,
     SFUNC = 266,
     UNDEF = 267,
     KEYWORD = 268,
     PRINT = 269,
     STRING = 270,
     WHILE = 271,
     IF = 272,
     ELSE = 273,
     DOTSIZE = 274,
     END = 275,
     BLTIN = 276,
     FOR = 277,
     CMD = 278,
     FUNCTION = 279,
     FUNC = 280,
     RETURN = 281,
     PROCEDURE = 282,
     PROC = 283,
     NUMBER = 284,
     BUF = 285,
     ARG = 286,
     BREAK = 287,
     CONTINUE = 288,
     RSHEQ = 289,
     LSHEQ = 290,
     XOREQ = 291,
     OREQ = 292,
     ANDEQ = 293,
     DIVEQ = 294,
     TIMESEQ = 295,
     MINUSEQ = 296,
     PLUSEQ = 297,
     OR = 298,
     AND = 299,
     BITOR = 300,
     BITXOR = 301,
     BITAND = 302,
     NE = 303,
     EQ = 304,
     LE = 305,
     LT = 306,
     GE = 307,
     GT = 308,
     RSH = 309,
     LSH = 310,
     NOT = 311,
     UNARYMINUS = 312
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 20 "sushi.y"

   Symbol   *sym;
   Inst  *inst;
   int   narg;



/* Line 1676 of yacc.c  */
#line 117 "sushi.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


