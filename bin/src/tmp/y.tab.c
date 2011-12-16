
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C
   
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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.4.1"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Copy the first part of user declarations.  */

/* Line 189 of yacc.c  */
#line 1 "sushi.y"

  
#include <stdio.h>
/*#include "sushi-types.h"*/

#include "sushi-su.h"

#define code2(c1, c2)      code(c1); code(c2)
#define code3(c1, c2, c3)  code(c1); code(c2); code(c3)

uint  LineNum = 1;

int		InDef = 0;
Symbol	*DefSym;

extern int yydebug;



/* Line 189 of yacc.c  */
#line 93 "y.tab.c"

/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif


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
/* Tokens.  */
#define SOTID 258
#define SOLUN 259
#define SOBUF 260
#define SOSEC 261
#define SONUM 262
#define SOHA 263
#define OPTION 264
#define VAR 265
#define SFUNC 266
#define UNDEF 267
#define KEYWORD 268
#define PRINT 269
#define STRING 270
#define WHILE 271
#define IF 272
#define ELSE 273
#define DOTSIZE 274
#define END 275
#define BLTIN 276
#define FOR 277
#define CMD 278
#define FUNCTION 279
#define FUNC 280
#define RETURN 281
#define PROCEDURE 282
#define PROC 283
#define NUMBER 284
#define BUF 285
#define ARG 286
#define BREAK 287
#define CONTINUE 288
#define RSHEQ 289
#define LSHEQ 290
#define XOREQ 291
#define OREQ 292
#define ANDEQ 293
#define DIVEQ 294
#define TIMESEQ 295
#define MINUSEQ 296
#define PLUSEQ 297
#define OR 298
#define AND 299
#define BITOR 300
#define BITXOR 301
#define BITAND 302
#define NE 303
#define EQ 304
#define LE 305
#define LT 306
#define GE 307
#define GT 308
#define RSH 309
#define LSH 310
#define NOT 311
#define UNARYMINUS 312




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 214 of yacc.c  */
#line 20 "sushi.y"

   Symbol   *sym;
   Inst  *inst;
   int   narg;



/* Line 214 of yacc.c  */
#line 251 "y.tab.c"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif


/* Copy the second part of user declarations.  */


/* Line 264 of yacc.c  */
#line 263 "y.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int yyi)
#else
static int
YYID (yyi)
    int yyi;
#endif
{
  return yyi;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)				\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack_alloc, Stack, yysize);			\
	Stack = &yyptr->Stack_alloc;					\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   634

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  72
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  24
/* YYNRULES -- Number of rules.  */
#define YYNRULES  111
/* YYNRULES -- Number of states.  */
#define YYNSTATES  212

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   312

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      63,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      66,    67,    60,    57,    71,    58,     2,    59,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    68,
       2,    34,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    64,     2,    65,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    69,     2,    70,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    61,    62
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     4,     7,    11,    15,    19,    23,    27,
      31,    39,    44,    50,    56,    60,    64,    68,    72,    76,
      80,    84,    88,    92,    96,    98,   100,   103,   105,   107,
     113,   116,   120,   133,   138,   143,   151,   155,   157,   161,
     163,   165,   166,   167,   170,   173,   175,   177,   179,   181,
     187,   189,   194,   200,   204,   210,   216,   221,   226,   230,
     234,   238,   242,   246,   249,   253,   257,   261,   265,   269,
     273,   277,   281,   284,   288,   292,   296,   300,   304,   305,
     312,   313,   320,   322,   324,   327,   331,   335,   340,   342,
     345,   349,   352,   354,   355,   358,   360,   363,   366,   369,
     372,   375,   378,   380,   383,   385,   387,   389,   391,   393,
     394,   396
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int8 yyrhs[] =
{
      73,     0,    -1,    -1,    73,    63,    -1,    73,    83,    63,
      -1,    73,    74,    63,    -1,    73,    75,    63,    -1,    73,
      82,    63,    -1,    73,     1,    63,    -1,    10,    34,    82,
      -1,    30,    93,    64,    82,    65,    34,    82,    -1,    30,
      93,    34,    82,    -1,    30,    93,    34,    30,    93,    -1,
      30,    93,    19,    34,    82,    -1,    10,    43,    82,    -1,
      10,    42,    82,    -1,    10,    41,    82,    -1,    10,    40,
      82,    -1,    10,    39,    82,    -1,    10,    38,    82,    -1,
      10,    37,    82,    -1,    10,    36,    82,    -1,    10,    35,
      82,    -1,    31,    34,    82,    -1,    82,    -1,    26,    -1,
      26,    82,    -1,    32,    -1,    33,    -1,    27,    89,    66,
      95,    67,    -1,    14,    86,    -1,    23,    89,    95,    -1,
      22,    66,    82,    76,    82,    80,    68,    82,    80,    67,
      75,    80,    -1,    78,    77,    75,    80,    -1,    79,    77,
      75,    80,    -1,    79,    77,    75,    80,    18,    75,    80,
      -1,    69,    81,    70,    -1,    68,    -1,    66,    82,    67,
      -1,    16,    -1,    17,    -1,    -1,    -1,    81,    63,    -1,
      81,    75,    -1,    29,    -1,    10,    -1,    31,    -1,    74,
      -1,    24,    89,    66,    95,    67,    -1,    87,    -1,    21,
      66,    82,    67,    -1,    30,    93,    64,    82,    65,    -1,
      30,    93,    19,    -1,    30,    93,    50,    30,    93,    -1,
      30,    93,    49,    30,    93,    -1,    30,    93,    50,    82,
      -1,    30,    93,    49,    82,    -1,    66,    82,    67,    -1,
      82,    57,    82,    -1,    82,    58,    82,    -1,    82,    60,
      82,    -1,    82,    59,    82,    -1,    58,    82,    -1,    82,
      54,    82,    -1,    82,    53,    82,    -1,    82,    52,    82,
      -1,    82,    51,    82,    -1,    82,    50,    82,    -1,    82,
      49,    82,    -1,    82,    45,    82,    -1,    82,    44,    82,
      -1,    61,    82,    -1,    82,    46,    82,    -1,    82,    48,
      82,    -1,    82,    47,    82,    -1,    82,    56,    82,    -1,
      82,    55,    82,    -1,    -1,    25,    94,    84,    66,    67,
      75,    -1,    -1,    28,    94,    85,    66,    67,    75,    -1,
      82,    -1,    15,    -1,    30,    93,    -1,    86,    71,    82,
      -1,    86,    71,    15,    -1,    86,    71,    30,    93,    -1,
      88,    -1,    88,    90,    -1,    88,    90,    92,    -1,    88,
      92,    -1,    11,    -1,    -1,    90,    91,    -1,    91,    -1,
       3,    93,    -1,     4,    93,    -1,     5,    93,    -1,     6,
      93,    -1,     7,    93,    -1,     8,    93,    -1,    93,    -1,
      93,    93,    -1,    29,    -1,    10,    -1,    10,    -1,    24,
      -1,    27,    -1,    -1,    82,    -1,    95,    71,    82,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint8 yyrline[] =
{
       0,    47,    47,    48,    49,    50,    51,    52,    53,    55,
      56,    58,    59,    60,    61,    62,    63,    64,    65,    66,
      67,    68,    69,    70,    76,    77,    78,    79,    80,    81,
      83,    84,    88,    93,    94,    95,   100,   102,   104,   106,
     108,   110,   112,   113,   114,   116,   117,   118,   119,   120,
     122,   123,   124,   125,   126,   127,   128,   129,   130,   131,
     132,   133,   134,   135,   136,   137,   138,   139,   140,   141,
     142,   143,   144,   145,   146,   147,   148,   149,   151,   151,
     153,   153,   156,   157,   158,   159,   160,   161,   163,   167,
     171,   175,   180,   182,   184,   185,   187,   188,   189,   190,
     191,   192,   194,   195,   201,   202,   204,   205,   206,   208,
     209,   210
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "SOTID", "SOLUN", "SOBUF", "SOSEC",
  "SONUM", "SOHA", "OPTION", "VAR", "SFUNC", "UNDEF", "KEYWORD", "PRINT",
  "STRING", "WHILE", "IF", "ELSE", "DOTSIZE", "END", "BLTIN", "FOR", "CMD",
  "FUNCTION", "FUNC", "RETURN", "PROCEDURE", "PROC", "NUMBER", "BUF",
  "ARG", "BREAK", "CONTINUE", "'='", "RSHEQ", "LSHEQ", "XOREQ", "OREQ",
  "ANDEQ", "DIVEQ", "TIMESEQ", "MINUSEQ", "PLUSEQ", "OR", "AND", "BITOR",
  "BITXOR", "BITAND", "NE", "EQ", "LE", "LT", "GE", "GT", "RSH", "LSH",
  "'+'", "'-'", "'/'", "'*'", "NOT", "UNARYMINUS", "'\\n'", "'['", "']'",
  "'('", "')'", "';'", "'{'", "'}'", "','", "$accept", "list", "asgn",
  "stmt", "fBegin", "cond", "while", "if", "end", "stmtlist", "expr",
  "defn", "$@1", "$@2", "prlist", "sfunc", "sbegin", "begin", "sopts",
  "sopt", "sargs", "nVal", "procname", "arglist", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,    61,   289,   290,   291,   292,   293,
     294,   295,   296,   297,   298,   299,   300,   301,   302,   303,
     304,   305,   306,   307,   308,   309,   310,    43,    45,    47,
      42,   311,   312,    10,    91,    93,    40,    41,    59,   123,
     125,    44
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    72,    73,    73,    73,    73,    73,    73,    73,    74,
      74,    74,    74,    74,    74,    74,    74,    74,    74,    74,
      74,    74,    74,    74,    75,    75,    75,    75,    75,    75,
      75,    75,    75,    75,    75,    75,    75,    76,    77,    78,
      79,    80,    81,    81,    81,    82,    82,    82,    82,    82,
      82,    82,    82,    82,    82,    82,    82,    82,    82,    82,
      82,    82,    82,    82,    82,    82,    82,    82,    82,    82,
      82,    82,    82,    82,    82,    82,    82,    82,    84,    83,
      85,    83,    86,    86,    86,    86,    86,    86,    87,    87,
      87,    87,    88,    89,    90,    90,    91,    91,    91,    91,
      91,    91,    92,    92,    93,    93,    94,    94,    94,    95,
      95,    95
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     2,     3,     3,     3,     3,     3,     3,
       7,     4,     5,     5,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     1,     1,     2,     1,     1,     5,
       2,     3,    12,     4,     4,     7,     3,     1,     3,     1,
       1,     0,     0,     2,     2,     1,     1,     1,     1,     5,
       1,     4,     5,     3,     5,     5,     4,     4,     3,     3,
       3,     3,     3,     2,     3,     3,     3,     3,     3,     3,
       3,     3,     2,     3,     3,     3,     3,     3,     0,     6,
       0,     6,     1,     1,     2,     3,     3,     4,     1,     2,
       3,     2,     1,     0,     2,     1,     2,     2,     2,     2,
       2,     2,     1,     2,     1,     1,     1,     1,     1,     0,
       1,     3
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       2,     0,     1,     0,    46,    92,     0,    39,    40,     0,
       0,    93,    93,     0,    25,    93,     0,    45,     0,    47,
      27,    28,     0,     0,     3,     0,    42,    48,     0,     0,
       0,     0,     0,    50,    88,     8,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    83,     0,    48,    82,
      30,     0,     0,   109,     0,   106,   107,   108,    78,    26,
       0,    80,   105,   104,     0,     0,    63,    72,     0,     0,
       5,     6,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     7,     4,     0,     0,     0,     0,     0,     0,
      89,    95,    91,   102,     9,    22,    21,    20,    19,    18,
      17,    16,    15,    14,    84,     0,     0,     0,   110,    31,
     109,     0,   109,     0,    53,     0,     0,     0,     0,    23,
      58,    43,    36,    44,    24,     0,    41,    41,    71,    70,
      73,    75,    74,    69,    68,    67,    66,    65,    64,    77,
      76,    59,    60,    62,    61,    96,    97,    98,    99,   100,
     101,    94,    90,   103,    86,     0,    85,    51,    37,     0,
       0,     0,     0,     0,     0,     0,     0,    11,     0,    57,
       0,    56,     0,    38,    33,    34,    87,    41,   111,    49,
       0,    29,     0,    13,    12,    55,    54,    52,     0,     0,
      79,    81,     0,    41,     0,    10,    35,    41,     0,     0,
      41,    32
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     1,    48,    28,   169,    73,    29,    30,   184,    69,
     134,    32,   121,   123,    50,    33,    34,    53,   100,   101,
     102,   103,    58,   119
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -73
static const yytype_int16 yypact[] =
{
     -73,   183,   -73,   -48,    19,   -73,   232,   -73,   -73,   -47,
     -33,   -73,   -73,    -7,   285,   -73,    -7,   -73,    -6,    15,
     -73,   -73,   285,   285,   -73,   285,   -73,   -29,    10,    -3,
      -3,   488,    28,   -73,   103,   -73,   285,   285,   285,   285,
     285,   285,   285,   285,   285,   285,   -73,    -6,   -73,   508,
      21,   285,   285,   285,    27,   -73,   -73,   -73,   -73,   508,
      34,   -73,   -73,   -73,   -18,   285,   -73,   -73,   394,   207,
     -73,   -73,   285,   129,   129,   285,   285,   285,   285,   285,
     285,   285,   285,   285,   285,   285,   285,   285,   285,   285,
     285,   285,   -73,   -73,    -6,    -6,    -6,    -6,    -6,    -6,
     103,   -73,   -73,    -6,   508,   508,   508,   508,   508,   508,
     508,   508,   508,   508,   -18,   270,   418,   369,   508,    30,
     285,    36,   285,    38,    71,   308,   323,   346,   285,   508,
     -73,   -73,   -73,   -73,   508,   442,   -73,   -73,   524,   539,
     343,   552,   564,   574,   574,   -30,   -30,   -30,   -30,     9,
       9,   -51,   -51,   -73,   -73,   -73,   -73,   -73,   -73,   -73,
     -73,   -73,   -73,   -73,   -73,    -6,   508,   -73,   -73,   285,
     285,   -65,    45,   -57,    49,   285,    -6,   508,    -6,   574,
      -6,   574,   466,   -73,   -73,    99,   -18,   508,   508,   -73,
     129,   -73,   129,   508,   -18,   -18,   -18,    84,   129,    52,
     -73,   -73,   285,   -73,   285,   508,   -73,   508,    55,   129,
     -73,   -73
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -73,   -73,   122,   -62,   -73,   104,   -73,   -73,   -72,   -73,
      -1,   -73,   -73,   -73,   -73,   -73,   -73,    33,   -73,    29,
      37,     0,   117,   -50
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint8 yytable[] =
{
      31,   124,   189,    55,    62,    49,   170,   133,    90,    91,
     191,   136,   137,    59,   170,    35,   125,    56,    64,    51,
      57,    66,    67,    63,    68,    86,    87,    88,    89,    90,
      91,   126,   127,    52,    70,   104,   105,   106,   107,   108,
     109,   110,   111,   112,   113,    54,   128,   114,    60,    65,
     116,   117,   118,    36,    37,    38,    39,    40,    41,    42,
      43,    44,    45,    72,   129,   185,    88,    89,    90,    91,
     171,   135,   173,    71,   138,   139,   140,   141,   142,   143,
     144,   145,   146,   147,   148,   149,   150,   151,   152,   153,
     154,    93,   115,   120,   155,   156,   157,   158,   159,   160,
     122,   170,   172,   163,   174,   175,    94,    95,    96,    97,
      98,    99,   190,    62,   166,   199,   192,   198,   202,   118,
     204,   118,   209,    27,   177,   179,   181,   182,   200,   161,
     201,   206,    63,    61,    74,   208,   203,   162,   211,     4,
       5,     0,     0,     6,     0,     7,     8,   210,     0,     0,
       9,    10,    11,    12,     0,    14,    15,     0,    17,    18,
      19,    20,    21,     0,     0,   186,     0,     0,   187,   188,
       0,     0,     0,     0,   193,     0,   194,     0,   195,     0,
     196,     0,     0,     2,     3,     0,     0,    22,     0,     0,
      23,     0,     0,     4,     5,    25,     0,     6,    26,     7,
       8,   205,     0,   207,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,     4,     5,     0,
       0,     6,     0,     7,     8,     0,     0,     0,     9,    10,
      11,    12,     0,    14,    15,     0,    17,    18,    19,    20,
      21,    22,     4,     5,    23,     0,    24,    46,     0,    25,
       0,     0,    26,     9,     0,     0,    12,     0,     0,     0,
       0,    17,    47,    19,     0,    22,     0,     0,    23,     0,
     131,     0,     0,    25,     0,     0,    26,   132,     0,     0,
       4,     5,     0,     0,     0,   164,     0,     0,     0,     0,
      22,     9,     0,    23,    12,     4,     5,     0,    25,    17,
     165,    19,     0,     0,     0,     0,     9,     0,     0,    12,
       0,     0,     0,     0,    17,    18,    19,     0,     4,     5,
       0,     0,     0,     0,     0,     0,     0,     0,    22,     9,
       0,    23,    12,     4,     5,     0,    25,    17,   176,    19,
       0,     0,     0,    22,     9,     0,    23,    12,     0,     0,
       0,    25,    17,   178,    19,     0,     4,     5,     0,     0,
       0,     0,     0,     0,     0,     0,    22,     9,     0,    23,
      12,     0,     0,     0,    25,    17,   180,    19,     0,     0,
       0,    22,     0,     0,    23,     0,     0,     0,     0,    25,
      78,    79,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    22,     0,     0,    23,     0,     0,
       0,     0,    25,    75,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    86,    87,    88,    89,    90,    91,
       0,     0,     0,     0,     0,     0,     0,   168,    75,    76,
      77,    78,    79,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,    90,    91,     0,     0,     0,     0,     0,
       0,   130,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,     0,
       0,     0,     0,     0,     0,   167,    75,    76,    77,    78,
      79,    80,    81,    82,    83,    84,    85,    86,    87,    88,
      89,    90,    91,     0,     0,     0,     0,     0,     0,   183,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,     0,     0,     0,
       0,   197,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,     0,
       0,    92,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,    76,
      77,    78,    79,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,    90,    91,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    86,    87,    88,    89,    90,    91,
      79,    80,    81,    82,    83,    84,    85,    86,    87,    88,
      89,    90,    91,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,    90,    91,    82,    83,    84,    85,    86,
      87,    88,    89,    90,    91
};

static const yytype_int16 yycheck[] =
{
       1,    19,    67,    10,    10,     6,    71,    69,    59,    60,
      67,    73,    74,    14,    71,    63,    34,    24,    18,    66,
      27,    22,    23,    29,    25,    55,    56,    57,    58,    59,
      60,    49,    50,    66,    63,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    45,    12,    64,    47,    15,    34,
      51,    52,    53,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    66,    65,   137,    57,    58,    59,    60,
     120,    72,   122,    63,    75,    76,    77,    78,    79,    80,
      81,    82,    83,    84,    85,    86,    87,    88,    89,    90,
      91,    63,    71,    66,    94,    95,    96,    97,    98,    99,
      66,    71,    66,   103,    66,    34,     3,     4,     5,     6,
       7,     8,    67,    10,   115,   187,    67,    18,    34,   120,
      68,   122,    67,     1,   125,   126,   127,   128,   190,   100,
     192,   203,    29,    16,    30,   207,   198,   100,   210,    10,
      11,    -1,    -1,    14,    -1,    16,    17,   209,    -1,    -1,
      21,    22,    23,    24,    -1,    26,    27,    -1,    29,    30,
      31,    32,    33,    -1,    -1,   165,    -1,    -1,   169,   170,
      -1,    -1,    -1,    -1,   175,    -1,   176,    -1,   178,    -1,
     180,    -1,    -1,     0,     1,    -1,    -1,    58,    -1,    -1,
      61,    -1,    -1,    10,    11,    66,    -1,    14,    69,    16,
      17,   202,    -1,   204,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    10,    11,    -1,
      -1,    14,    -1,    16,    17,    -1,    -1,    -1,    21,    22,
      23,    24,    -1,    26,    27,    -1,    29,    30,    31,    32,
      33,    58,    10,    11,    61,    -1,    63,    15,    -1,    66,
      -1,    -1,    69,    21,    -1,    -1,    24,    -1,    -1,    -1,
      -1,    29,    30,    31,    -1,    58,    -1,    -1,    61,    -1,
      63,    -1,    -1,    66,    -1,    -1,    69,    70,    -1,    -1,
      10,    11,    -1,    -1,    -1,    15,    -1,    -1,    -1,    -1,
      58,    21,    -1,    61,    24,    10,    11,    -1,    66,    29,
      30,    31,    -1,    -1,    -1,    -1,    21,    -1,    -1,    24,
      -1,    -1,    -1,    -1,    29,    30,    31,    -1,    10,    11,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    58,    21,
      -1,    61,    24,    10,    11,    -1,    66,    29,    30,    31,
      -1,    -1,    -1,    58,    21,    -1,    61,    24,    -1,    -1,
      -1,    66,    29,    30,    31,    -1,    10,    11,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    58,    21,    -1,    61,
      24,    -1,    -1,    -1,    66,    29,    30,    31,    -1,    -1,
      -1,    58,    -1,    -1,    61,    -1,    -1,    -1,    -1,    66,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    59,    60,    58,    -1,    -1,    61,    -1,    -1,
      -1,    -1,    66,    44,    45,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    60,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,    44,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    -1,    -1,    -1,    -1,    -1,
      -1,    67,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    -1,    -1,    67,    44,    45,    46,    47,
      48,    49,    50,    51,    52,    53,    54,    55,    56,    57,
      58,    59,    60,    -1,    -1,    -1,    -1,    -1,    -1,    67,
      44,    45,    46,    47,    48,    49,    50,    51,    52,    53,
      54,    55,    56,    57,    58,    59,    60,    -1,    -1,    -1,
      -1,    65,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    63,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    45,
      46,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    60,
      48,    49,    50,    51,    52,    53,    54,    55,    56,    57,
      58,    59,    60,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    73,     0,     1,    10,    11,    14,    16,    17,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    58,    61,    63,    66,    69,    74,    75,    78,
      79,    82,    83,    87,    88,    63,    34,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    15,    30,    74,    82,
      86,    66,    66,    89,    89,    10,    24,    27,    94,    82,
      89,    94,    10,    29,    93,    34,    82,    82,    82,    81,
      63,    63,    66,    77,    77,    44,    45,    46,    47,    48,
      49,    50,    51,    52,    53,    54,    55,    56,    57,    58,
      59,    60,    63,    63,     3,     4,     5,     6,     7,     8,
      90,    91,    92,    93,    82,    82,    82,    82,    82,    82,
      82,    82,    82,    82,    93,    71,    82,    82,    82,    95,
      66,    84,    66,    85,    19,    34,    49,    50,    64,    82,
      67,    63,    70,    75,    82,    82,    75,    75,    82,    82,
      82,    82,    82,    82,    82,    82,    82,    82,    82,    82,
      82,    82,    82,    82,    82,    93,    93,    93,    93,    93,
      93,    91,    92,    93,    15,    30,    82,    67,    68,    76,
      71,    95,    66,    95,    66,    34,    30,    82,    30,    82,
      30,    82,    82,    67,    80,    80,    93,    82,    82,    67,
      67,    67,    67,    82,    93,    93,    93,    65,    18,    80,
      75,    75,    34,    75,    68,    82,    80,    82,    80,    67,
      75,    80
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
#else
static void
yy_stack_print (yybottom, yytop)
    yytype_int16 *yybottom;
    yytype_int16 *yytop;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}

/* Prevent warnings from -Wmissing-prototypes.  */
#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */


/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*-------------------------.
| yyparse or yypush_parse.  |
`-------------------------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{


    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       `yyss': related to states.
       `yyvs': related to semantic values.

       Refer to the stacks thru separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yytoken = 0;
  yyss = yyssa;
  yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */
  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss_alloc, yyss);
	YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 3:

/* Line 1455 of yacc.c  */
#line 48 "sushi.y"
    { code(STOP); return (1); }
    break;

  case 4:

/* Line 1455 of yacc.c  */
#line 49 "sushi.y"
    { code(STOP); return (1); Prompt(); }
    break;

  case 5:

/* Line 1455 of yacc.c  */
#line 50 "sushi.y"
    { code2(pop, STOP); return (1); }
    break;

  case 6:

/* Line 1455 of yacc.c  */
#line 51 "sushi.y"
    { code(STOP); return (1); }
    break;

  case 7:

/* Line 1455 of yacc.c  */
#line 52 "sushi.y"
    { code2(pop, STOP); return (1); }
    break;

  case 8:

/* Line 1455 of yacc.c  */
#line 53 "sushi.y"
    { yyerrok; }
    break;

  case 9:

/* Line 1455 of yacc.c  */
#line 55 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), Assign); }
    break;

  case 10:

/* Line 1455 of yacc.c  */
#line 57 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (7)].inst); code(SetBufElement); }
    break;

  case 11:

/* Line 1455 of yacc.c  */
#line 58 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (4)].inst); code(SetBuf); }
    break;

  case 12:

/* Line 1455 of yacc.c  */
#line 59 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (5)].inst); code(SetBufEq); }
    break;

  case 13:

/* Line 1455 of yacc.c  */
#line 60 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (5)].inst); code(SetBufSize); }
    break;

  case 14:

/* Line 1455 of yacc.c  */
#line 61 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), PlusEq); }
    break;

  case 15:

/* Line 1455 of yacc.c  */
#line 62 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), MinusEq); }
    break;

  case 16:

/* Line 1455 of yacc.c  */
#line 63 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), TimesEq); }
    break;

  case 17:

/* Line 1455 of yacc.c  */
#line 64 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), DivEq); }
    break;

  case 18:

/* Line 1455 of yacc.c  */
#line 65 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), AndEq); }
    break;

  case 19:

/* Line 1455 of yacc.c  */
#line 66 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), OrEq); }
    break;

  case 20:

/* Line 1455 of yacc.c  */
#line 67 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), XorEq); }
    break;

  case 21:

/* Line 1455 of yacc.c  */
#line 68 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), LshEq); }
    break;

  case 22:

/* Line 1455 of yacc.c  */
#line 69 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (3)].inst); code3(VarPush, (Inst)(yyvsp[(1) - (3)].sym), RshEq); }
    break;

  case 23:

/* Line 1455 of yacc.c  */
#line 70 "sushi.y"
    {
                              DefOnly("$");
                              code2(ArgAssign, (Inst)(yyvsp[(1) - (3)].narg));
                              (yyval.inst) = (yyvsp[(3) - (3)].inst);
                           }
    break;

  case 24:

/* Line 1455 of yacc.c  */
#line 76 "sushi.y"
    { code(pop); }
    break;

  case 25:

/* Line 1455 of yacc.c  */
#line 77 "sushi.y"
    { DefOnly("return"); (yyval.inst) = code(ProcRet); }
    break;

  case 26:

/* Line 1455 of yacc.c  */
#line 78 "sushi.y"
    { DefOnly("return"); (yyval.inst) = (yyvsp[(2) - (2)].inst); code(FuncRet); }
    break;

  case 27:

/* Line 1455 of yacc.c  */
#line 79 "sushi.y"
    { (yyval.inst) = code(BreakCode); }
    break;

  case 28:

/* Line 1455 of yacc.c  */
#line 80 "sushi.y"
    { (yyval.inst) = code(ContinueCode); }
    break;

  case 29:

/* Line 1455 of yacc.c  */
#line 82 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (5)].inst); code3(Call, (Inst)(yyvsp[(1) - (5)].sym), (Inst)(yyvsp[(4) - (5)].narg)); }
    break;

  case 30:

/* Line 1455 of yacc.c  */
#line 83 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); }
    break;

  case 31:

/* Line 1455 of yacc.c  */
#line 84 "sushi.y"
    {
			                        (yyval.inst) = (yyvsp[(2) - (3)].inst);
											code3(Command, (Inst)(yyvsp[(1) - (3)].sym)->u.func, (Inst)(yyvsp[(3) - (3)].narg));
	                           }
    break;

  case 32:

/* Line 1455 of yacc.c  */
#line 89 "sushi.y"
    {
                   (yyval.inst) = (yyvsp[(3) - (12)].inst); ((yyvsp[(4) - (12)].inst))[1] = (Inst)(yyvsp[(8) - (12)].inst);
                   ((yyvsp[(4) - (12)].inst))[2] = (Inst)(yyvsp[(11) - (12)].inst); ((yyvsp[(4) - (12)].inst))[3] = (Inst)(yyvsp[(12) - (12)].inst);
                }
    break;

  case 33:

/* Line 1455 of yacc.c  */
#line 93 "sushi.y"
    { ((yyvsp[(1) - (4)].inst))[1] = (Inst)(yyvsp[(3) - (4)].inst); ((yyvsp[(1) - (4)].inst))[2] = (Inst)(yyvsp[(4) - (4)].inst); }
    break;

  case 34:

/* Line 1455 of yacc.c  */
#line 94 "sushi.y"
    { ((yyvsp[(1) - (4)].inst))[1] = (Inst)(yyvsp[(3) - (4)].inst); ((yyvsp[(1) - (4)].inst))[3] = (Inst)(yyvsp[(4) - (4)].inst); }
    break;

  case 35:

/* Line 1455 of yacc.c  */
#line 95 "sushi.y"
    {
                                    ((yyvsp[(1) - (7)].inst))[1] = (Inst)(yyvsp[(3) - (7)].inst);
                                    ((yyvsp[(1) - (7)].inst))[2] = (Inst)(yyvsp[(6) - (7)].inst);
                                    ((yyvsp[(1) - (7)].inst))[3] = (Inst)(yyvsp[(7) - (7)].inst);
                                 }
    break;

  case 36:

/* Line 1455 of yacc.c  */
#line 100 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (3)].inst); }
    break;

  case 37:

/* Line 1455 of yacc.c  */
#line 102 "sushi.y"
    { (yyval.inst) = code(ForCode); code3(STOP, STOP, STOP);}
    break;

  case 38:

/* Line 1455 of yacc.c  */
#line 104 "sushi.y"
    { code(STOP); (yyval.inst) = (yyvsp[(2) - (3)].inst); }
    break;

  case 39:

/* Line 1455 of yacc.c  */
#line 106 "sushi.y"
    { (yyval.inst) = code3(WhileCode, STOP, STOP); }
    break;

  case 40:

/* Line 1455 of yacc.c  */
#line 108 "sushi.y"
    { (yyval.inst) = code(IfCode); code3(STOP, STOP, STOP); }
    break;

  case 41:

/* Line 1455 of yacc.c  */
#line 110 "sushi.y"
    { code(STOP); (yyval.inst) = progp; }
    break;

  case 42:

/* Line 1455 of yacc.c  */
#line 112 "sushi.y"
    { (yyval.inst) = progp; }
    break;

  case 45:

/* Line 1455 of yacc.c  */
#line 116 "sushi.y"
    { (yyval.inst) = code2(ConstPush, (Inst)(yyvsp[(1) - (1)].narg)); }
    break;

  case 46:

/* Line 1455 of yacc.c  */
#line 117 "sushi.y"
    { (yyval.inst) = code3(VarPush, (Inst)(yyvsp[(1) - (1)].sym), Eval); }
    break;

  case 47:

/* Line 1455 of yacc.c  */
#line 118 "sushi.y"
    { DefOnly("$"); (yyval.inst) = code2(Arg, (Inst)(yyvsp[(1) - (1)].narg)); }
    break;

  case 49:

/* Line 1455 of yacc.c  */
#line 121 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (5)].inst); code3(Call, (Inst)(yyvsp[(1) - (5)].sym), (Inst)(yyvsp[(4) - (5)].narg)); }
    break;

  case 51:

/* Line 1455 of yacc.c  */
#line 123 "sushi.y"
    { (yyval.inst) = (yyvsp[(3) - (4)].inst); code2(BuiltIn, (Inst)(yyvsp[(1) - (4)].sym)->u.func); }
    break;

  case 52:

/* Line 1455 of yacc.c  */
#line 124 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (5)].inst); code(GetBufElement); }
    break;

  case 53:

/* Line 1455 of yacc.c  */
#line 125 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (3)].inst); code(GetBufSize); }
    break;

  case 54:

/* Line 1455 of yacc.c  */
#line 126 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (5)].inst); code(BufCmp); }
    break;

  case 55:

/* Line 1455 of yacc.c  */
#line 127 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (5)].inst); code(BufNotCmp); }
    break;

  case 56:

/* Line 1455 of yacc.c  */
#line 128 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (4)].inst); code(BufIsVal); }
    break;

  case 57:

/* Line 1455 of yacc.c  */
#line 129 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (4)].inst); code(BufIsNotVal); }
    break;

  case 58:

/* Line 1455 of yacc.c  */
#line 130 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (3)].inst); }
    break;

  case 59:

/* Line 1455 of yacc.c  */
#line 131 "sushi.y"
    { code(Add); }
    break;

  case 60:

/* Line 1455 of yacc.c  */
#line 132 "sushi.y"
    { code(Sub); }
    break;

  case 61:

/* Line 1455 of yacc.c  */
#line 133 "sushi.y"
    { code(Mul); }
    break;

  case 62:

/* Line 1455 of yacc.c  */
#line 134 "sushi.y"
    { code(Div); }
    break;

  case 63:

/* Line 1455 of yacc.c  */
#line 135 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); code(Negate); }
    break;

  case 64:

/* Line 1455 of yacc.c  */
#line 136 "sushi.y"
    { code(Gt); }
    break;

  case 65:

/* Line 1455 of yacc.c  */
#line 137 "sushi.y"
    { code(Ge); }
    break;

  case 66:

/* Line 1455 of yacc.c  */
#line 138 "sushi.y"
    { code(Lt); }
    break;

  case 67:

/* Line 1455 of yacc.c  */
#line 139 "sushi.y"
    { code(Le); }
    break;

  case 68:

/* Line 1455 of yacc.c  */
#line 140 "sushi.y"
    { code(Eq); }
    break;

  case 69:

/* Line 1455 of yacc.c  */
#line 141 "sushi.y"
    { code(Ne); }
    break;

  case 70:

/* Line 1455 of yacc.c  */
#line 142 "sushi.y"
    { code(And); }
    break;

  case 71:

/* Line 1455 of yacc.c  */
#line 143 "sushi.y"
    { code(Or); }
    break;

  case 72:

/* Line 1455 of yacc.c  */
#line 144 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); code(Not); }
    break;

  case 73:

/* Line 1455 of yacc.c  */
#line 145 "sushi.y"
    { code(BitOr); }
    break;

  case 74:

/* Line 1455 of yacc.c  */
#line 146 "sushi.y"
    { code(BitAnd); }
    break;

  case 75:

/* Line 1455 of yacc.c  */
#line 147 "sushi.y"
    { code(BitXor); }
    break;

  case 76:

/* Line 1455 of yacc.c  */
#line 148 "sushi.y"
    { code(Lsh); }
    break;

  case 77:

/* Line 1455 of yacc.c  */
#line 149 "sushi.y"
    { code(Rsh); }
    break;

  case 78:

/* Line 1455 of yacc.c  */
#line 151 "sushi.y"
    { (yyvsp[(2) - (2)].sym)->type = FUNCTION; InDef = 1; DefSym = (yyvsp[(2) - (2)].sym);}
    break;

  case 79:

/* Line 1455 of yacc.c  */
#line 152 "sushi.y"
    { code(ProcRet); Define((yyvsp[(2) - (6)].sym)); InDef = 0; }
    break;

  case 80:

/* Line 1455 of yacc.c  */
#line 153 "sushi.y"
    { (yyvsp[(2) - (2)].sym)->type = PROCEDURE; InDef = 1; DefSym = (yyvsp[(2) - (2)].sym);}
    break;

  case 81:

/* Line 1455 of yacc.c  */
#line 154 "sushi.y"
    { code(ProcRet); Define((yyvsp[(2) - (6)].sym)); InDef = 0; }
    break;

  case 82:

/* Line 1455 of yacc.c  */
#line 156 "sushi.y"
    { code(PrExpr); }
    break;

  case 83:

/* Line 1455 of yacc.c  */
#line 157 "sushi.y"
    { (yyval.inst) = code2(prstr, (Inst)(yyvsp[(1) - (1)].sym)); }
    break;

  case 84:

/* Line 1455 of yacc.c  */
#line 158 "sushi.y"
    { code(PrintBuf); }
    break;

  case 85:

/* Line 1455 of yacc.c  */
#line 159 "sushi.y"
    { code(PrExpr); }
    break;

  case 86:

/* Line 1455 of yacc.c  */
#line 160 "sushi.y"
    { code2(prstr, (Inst)(yyvsp[(3) - (3)].sym)); }
    break;

  case 87:

/* Line 1455 of yacc.c  */
#line 161 "sushi.y"
    { code(PrintBuf); }
    break;

  case 88:

/* Line 1455 of yacc.c  */
#line 163 "sushi.y"
    {
                        (yyval.inst) = progp - 1;
                        code2(SCSIFunc, (Inst)((yyvsp[(1) - (1)].sym)->u.func));
                     }
    break;

  case 89:

/* Line 1455 of yacc.c  */
#line 167 "sushi.y"
    {
                        (yyval.inst) = (yyvsp[(2) - (2)].inst) - 1;
                        code2(SCSIFunc, (Inst)((yyvsp[(1) - (2)].sym)->u.func));
                     }
    break;

  case 90:

/* Line 1455 of yacc.c  */
#line 171 "sushi.y"
    {
                        (yyval.inst) = (yyvsp[(2) - (3)].inst) - 1;
                        code2(SCSIFunc, (Inst)((yyvsp[(1) - (3)].sym)->u.func));
                     }
    break;

  case 91:

/* Line 1455 of yacc.c  */
#line 175 "sushi.y"
    {
                        (yyval.inst) = (yyvsp[(2) - (2)].inst) - 1;
                        code2(SCSIFunc, (Inst)((yyvsp[(1) - (2)].sym)->u.func));
                     }
    break;

  case 92:

/* Line 1455 of yacc.c  */
#line 180 "sushi.y"
    { code(SetGlobalTmps); }
    break;

  case 93:

/* Line 1455 of yacc.c  */
#line 182 "sushi.y"
    { (yyval.inst) = progp; }
    break;

  case 96:

/* Line 1455 of yacc.c  */
#line 187 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); code2(AssignGlobal, (Inst)&TmpTID); }
    break;

  case 97:

/* Line 1455 of yacc.c  */
#line 188 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); code2(AssignGlobal, (Inst)&TmpLUN); }
    break;

  case 98:

/* Line 1455 of yacc.c  */
#line 189 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); code2(AssignGlobal, (Inst)&TmpBUF); }
    break;

  case 99:

/* Line 1455 of yacc.c  */
#line 190 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); code2(AssignGlobal, (Inst)&TmpSEC); }
    break;

  case 100:

/* Line 1455 of yacc.c  */
#line 191 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); code2(AssignGlobal, (Inst)&TmpNUM); }
    break;

  case 101:

/* Line 1455 of yacc.c  */
#line 192 "sushi.y"
    { (yyval.inst) = (yyvsp[(2) - (2)].inst); code2(AssignGlobal, (Inst)&TmpHA); }
    break;

  case 102:

/* Line 1455 of yacc.c  */
#line 194 "sushi.y"
    { code2(AssignGlobal, (Inst)&TmpSEC); }
    break;

  case 103:

/* Line 1455 of yacc.c  */
#line 195 "sushi.y"
    {
                        /* the exprs will be pushed */
                        code2(AssignGlobal, (Inst)&TmpNUM);
                        code2(AssignGlobal, (Inst)&TmpSEC);
                     }
    break;

  case 104:

/* Line 1455 of yacc.c  */
#line 201 "sushi.y"
    { (yyval.inst) = code2(ConstPush, (Inst)(yyvsp[(1) - (1)].narg)); }
    break;

  case 105:

/* Line 1455 of yacc.c  */
#line 202 "sushi.y"
    { (yyval.inst) = code3(VarPush, (Inst)(yyvsp[(1) - (1)].sym), Eval); }
    break;

  case 109:

/* Line 1455 of yacc.c  */
#line 208 "sushi.y"
    { (yyval.narg) = 0; }
    break;

  case 110:

/* Line 1455 of yacc.c  */
#line 209 "sushi.y"
    { (yyval.narg) = 1; }
    break;

  case 111:

/* Line 1455 of yacc.c  */
#line 210 "sushi.y"
    { (yyval.narg) = (yyvsp[(1) - (3)].narg) + 1; }
    break;



/* Line 1455 of yacc.c  */
#line 2469 "y.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined(yyoverflow) || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}



/* Line 1675 of yacc.c  */
#line 212 "sushi.y"


