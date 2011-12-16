/* A Bison parser, made from sushi.y
   by GNU bison 1.35.  */

#define YYBISON 1  /* Identify Bison output.  */

# define	SOTID	257
# define	SOLUN	258
# define	SOBUF	259
# define	SOSEC	260
# define	SONUM	261
# define	SOHA	262
# define	OPTION	263
# define	VAR	264
# define	SFUNC	265
# define	UNDEF	266
# define	KEYWORD	267
# define	PRINT	268
# define	STRING	269
# define	WHILE	270
# define	IF	271
# define	ELSE	272
# define	DOTSIZE	273
# define	END	274
# define	BLTIN	275
# define	FOR	276
# define	CMD	277
# define	FUNCTION	278
# define	FUNC	279
# define	RETURN	280
# define	PROCEDURE	281
# define	PROC	282
# define	NUMBER	283
# define	BUF	284
# define	ARG	285
# define	BREAK	286
# define	CONTINUE	287
# define	PLUSEQ	288
# define	MINUSEQ	289
# define	TIMESEQ	290
# define	DIVEQ	291
# define	ANDEQ	292
# define	OREQ	293
# define	XOREQ	294
# define	LSHEQ	295
# define	RSHEQ	296
# define	OR	297
# define	AND	298
# define	BITOR	299
# define	BITXOR	300
# define	BITAND	301
# define	EQ	302
# define	NE	303
# define	GT	304
# define	GE	305
# define	LT	306
# define	LE	307
# define	LSH	308
# define	RSH	309
# define	UNARYMINUS	310
# define	NOT	311

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


#line 20 "sushi.y"
#ifndef YYSTYPE
typedef union {
   Symbol   *sym;
   Inst  *inst;
   int   narg;
} yystype;
# define YYSTYPE yystype
# define YYSTYPE_IS_TRIVIAL 1
#endif
#ifndef YYDEBUG
# define YYDEBUG 0
#endif



#define	YYFINAL		212
#define	YYFLAG		-32768
#define	YYNTBASE	72

/* YYTRANSLATE(YYLEX) -- Bison token number corresponding to YYLEX. */
#define YYTRANSLATE(x) ((unsigned)(x) <= 311 ? yytranslate[x] : 95)

/* YYTRANSLATE[YYLEX] -- Bison token number corresponding to YYLEX. */
static const char yytranslate[] =
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
       2,     2,     2,     2,     2,     2,     1,     3,     4,     5,
       6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,    45,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      61,    62
};

#if YYDEBUG
static const short yyprhs[] =
{
       0,     0,     1,     4,     8,    12,    16,    20,    24,    28,
      36,    41,    47,    53,    57,    61,    65,    69,    73,    77,
      81,    85,    89,    93,    95,    97,   100,   102,   104,   110,
     113,   117,   130,   135,   140,   148,   152,   154,   158,   160,
     162,   163,   164,   167,   170,   172,   174,   176,   178,   184,
     186,   191,   197,   201,   207,   213,   218,   223,   227,   231,
     235,   239,   243,   246,   250,   254,   258,   262,   266,   270,
     274,   278,   281,   285,   289,   293,   297,   301,   302,   309,
     310,   317,   319,   321,   324,   328,   332,   337,   339,   342,
     346,   349,   351,   352,   355,   357,   360,   363,   366,   369,
     372,   375,   377,   380,   382,   384,   386,   388,   390,   391,
     393
};
static const short yyrhs[] =
{
      -1,    72,    63,     0,    72,    82,    63,     0,    72,    73,
      63,     0,    72,    74,    63,     0,    72,    81,    63,     0,
      72,     1,    63,     0,    10,    34,    81,     0,    30,    92,
      64,    81,    65,    34,    81,     0,    30,    92,    34,    81,
       0,    30,    92,    34,    30,    92,     0,    30,    92,    19,
      34,    81,     0,    10,    35,    81,     0,    10,    36,    81,
       0,    10,    37,    81,     0,    10,    38,    81,     0,    10,
      39,    81,     0,    10,    40,    81,     0,    10,    41,    81,
       0,    10,    42,    81,     0,    10,    43,    81,     0,    31,
      34,    81,     0,    81,     0,    26,     0,    26,    81,     0,
      32,     0,    33,     0,    27,    88,    66,    94,    67,     0,
      14,    85,     0,    23,    88,    94,     0,    22,    66,    81,
      75,    81,    79,    68,    81,    79,    67,    74,    79,     0,
      77,    76,    74,    79,     0,    78,    76,    74,    79,     0,
      78,    76,    74,    79,    18,    74,    79,     0,    69,    80,
      70,     0,    68,     0,    66,    81,    67,     0,    16,     0,
      17,     0,     0,     0,    80,    63,     0,    80,    74,     0,
      29,     0,    10,     0,    31,     0,    73,     0,    24,    88,
      66,    94,    67,     0,    86,     0,    21,    66,    81,    67,
       0,    30,    92,    64,    81,    65,     0,    30,    92,    19,
       0,    30,    92,    49,    30,    92,     0,    30,    92,    50,
      30,    92,     0,    30,    92,    49,    81,     0,    30,    92,
      50,    81,     0,    66,    81,    67,     0,    81,    57,    81,
       0,    81,    58,    81,     0,    81,    60,    81,     0,    81,
      59,    81,     0,    58,    81,     0,    81,    51,    81,     0,
      81,    52,    81,     0,    81,    53,    81,     0,    81,    54,
      81,     0,    81,    49,    81,     0,    81,    50,    81,     0,
      81,    45,    81,     0,    81,    44,    81,     0,    62,    81,
       0,    81,    46,    81,     0,    81,    48,    81,     0,    81,
      47,    81,     0,    81,    55,    81,     0,    81,    56,    81,
       0,     0,    25,    93,    83,    66,    67,    74,     0,     0,
      28,    93,    84,    66,    67,    74,     0,    81,     0,    15,
       0,    30,    92,     0,    85,    71,    81,     0,    85,    71,
      15,     0,    85,    71,    30,    92,     0,    87,     0,    87,
      89,     0,    87,    89,    91,     0,    87,    91,     0,    11,
       0,     0,    89,    90,     0,    90,     0,     3,    92,     0,
       4,    92,     0,     5,    92,     0,     6,    92,     0,     7,
      92,     0,     8,    92,     0,    92,     0,    92,    92,     0,
      29,     0,    10,     0,    10,     0,    24,     0,    27,     0,
       0,    81,     0,    94,    71,    81,     0
};

#endif

#if YYDEBUG
/* YYRLINE[YYN] -- source line where rule number YYN was defined. */
static const short yyrline[] =
{
       0,    47,    48,    49,    50,    51,    52,    53,    55,    56,
      58,    59,    60,    61,    62,    63,    64,    65,    66,    67,
      68,    69,    70,    76,    77,    78,    79,    80,    81,    83,
      84,    88,    93,    94,    95,   100,   102,   104,   106,   108,
     110,   112,   113,   114,   116,   117,   118,   119,   120,   122,
     123,   124,   125,   126,   127,   128,   129,   130,   131,   132,
     133,   134,   135,   136,   137,   138,   139,   140,   141,   142,
     143,   144,   145,   146,   147,   148,   149,   151,   151,   153,
     153,   156,   157,   158,   159,   160,   161,   163,   167,   171,
     175,   180,   182,   184,   185,   187,   188,   189,   190,   191,
     192,   194,   195,   201,   202,   204,   205,   206,   208,   209,
     210
};
#endif


#if (YYDEBUG) || defined YYERROR_VERBOSE

/* YYTNAME[TOKEN_NUM] -- String name of the token TOKEN_NUM. */
static const char *const yytname[] =
{
  "$", "error", "$undefined.", "SOTID", "SOLUN", "SOBUF", "SOSEC", "SONUM", 
  "SOHA", "OPTION", "VAR", "SFUNC", "UNDEF", "KEYWORD", "PRINT", "STRING", 
  "WHILE", "IF", "ELSE", "DOTSIZE", "END", "BLTIN", "FOR", "CMD", 
  "FUNCTION", "FUNC", "RETURN", "PROCEDURE", "PROC", "NUMBER", "BUF", 
  "ARG", "BREAK", "CONTINUE", "'='", "PLUSEQ", "MINUSEQ", "TIMESEQ", 
  "DIVEQ", "ANDEQ", "OREQ", "XOREQ", "LSHEQ", "RSHEQ", "OR", "AND", 
  "BITOR", "BITXOR", "BITAND", "EQ", "NE", "GT", "GE", "LT", "LE", "LSH", 
  "RSH", "'+'", "'-'", "'/'", "'*'", "UNARYMINUS", "NOT", "'\\n'", "'['", 
  "']'", "'('", "')'", "';'", "'{'", "'}'", "','", "list", "asgn", "stmt", 
  "fBegin", "cond", "while", "if", "end", "stmtlist", "expr", "defn", 
  "@1", "@2", "prlist", "sfunc", "sbegin", "begin", "sopts", "sopt", 
  "sargs", "nVal", "procname", "arglist", 0
};
#endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives. */
static const short yyr1[] =
{
       0,    72,    72,    72,    72,    72,    72,    72,    73,    73,
      73,    73,    73,    73,    73,    73,    73,    73,    73,    73,
      73,    73,    73,    74,    74,    74,    74,    74,    74,    74,
      74,    74,    74,    74,    74,    74,    75,    76,    77,    78,
      79,    80,    80,    80,    81,    81,    81,    81,    81,    81,
      81,    81,    81,    81,    81,    81,    81,    81,    81,    81,
      81,    81,    81,    81,    81,    81,    81,    81,    81,    81,
      81,    81,    81,    81,    81,    81,    81,    83,    82,    84,
      82,    85,    85,    85,    85,    85,    85,    86,    86,    86,
      86,    87,    88,    89,    89,    90,    90,    90,    90,    90,
      90,    91,    91,    92,    92,    93,    93,    93,    94,    94,
      94
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN. */
static const short yyr2[] =
{
       0,     0,     2,     3,     3,     3,     3,     3,     3,     7,
       4,     5,     5,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     1,     1,     2,     1,     1,     5,     2,
       3,    12,     4,     4,     7,     3,     1,     3,     1,     1,
       0,     0,     2,     2,     1,     1,     1,     1,     5,     1,
       4,     5,     3,     5,     5,     4,     4,     3,     3,     3,
       3,     3,     2,     3,     3,     3,     3,     3,     3,     3,
       3,     2,     3,     3,     3,     3,     3,     0,     6,     0,
       6,     1,     1,     2,     3,     3,     4,     1,     2,     3,
       2,     1,     0,     2,     1,     2,     2,     2,     2,     2,
       2,     1,     2,     1,     1,     1,     1,     1,     0,     1,
       3
};

/* YYDEFACT[S] -- default rule to reduce with in state S when YYTABLE
   doesn't specify something else to do.  Zero means the default is an
   error. */
static const short yydefact[] =
{
       1,     0,     0,    45,    91,     0,    38,    39,     0,     0,
      92,    92,     0,    24,    92,     0,    44,     0,    46,    26,
      27,     0,     0,     2,     0,    41,    47,     0,     0,     0,
       0,     0,    49,    87,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    82,     0,    47,    81,    29,
       0,     0,   108,     0,   105,   106,   107,    77,    25,     0,
      79,   104,   103,     0,     0,    62,    71,     0,     0,     4,
       5,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     6,     3,     0,     0,     0,     0,     0,     0,    88,
      94,    90,   101,     8,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    83,     0,     0,     0,   109,    30,   108,
       0,   108,     0,    52,     0,     0,     0,     0,    22,    57,
      42,    35,    43,    23,     0,    40,    40,    70,    69,    72,
      74,    73,    67,    68,    63,    64,    65,    66,    75,    76,
      58,    59,    61,    60,    95,    96,    97,    98,    99,   100,
      93,    89,   102,    85,     0,    84,    50,    36,     0,     0,
       0,     0,     0,     0,     0,     0,    10,     0,    55,     0,
      56,     0,    37,    32,    33,    86,    40,   110,    48,     0,
      28,     0,    12,    11,    53,    54,    51,     0,     0,    78,
      80,     0,    40,     0,     9,    34,    40,     0,     0,    40,
      31,     0,     0
};

static const short yydefgoto[] =
{
       1,    47,    27,   168,    72,    28,    29,   183,    68,   133,
      31,   120,   122,    49,    32,    33,    52,    99,   100,   101,
     102,    57,   118
};

static const short yypact[] =
{
  -32768,   182,   -61,   584,-32768,   231,-32768,-32768,   -59,   -50,
  -32768,-32768,    -9,   271,-32768,    -9,-32768,    -7,   -15,-32768,
  -32768,   271,   271,-32768,   271,-32768,   -37,    -2,    -8,    -8,
     467,     2,-32768,   102,-32768,   271,   271,   271,   271,   271,
     271,   271,   271,   271,   271,-32768,    -7,-32768,   487,   -11,
     271,   271,   271,    -4,-32768,-32768,-32768,-32768,   487,     1,
  -32768,-32768,-32768,    -5,   271,-32768,-32768,   373,   206,-32768,
  -32768,   271,   128,   128,   271,   271,   271,   271,   271,   271,
     271,   271,   271,   271,   271,   271,   271,   271,   271,   271,
     271,-32768,-32768,    -7,    -7,    -7,    -7,    -7,    -7,   102,
  -32768,-32768,    -7,   487,   487,   487,   487,   487,   487,   487,
     487,   487,   487,    -5,   256,   397,   348,   487,    19,   271,
       3,   271,     5,    32,   295,   310,   325,   271,   487,-32768,
  -32768,-32768,-32768,   487,   421,-32768,-32768,   503,   518,   532,
     545,   557,   577,   577,    -3,    -3,    -3,    -3,   -27,   -27,
     -12,   -12,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
  -32768,-32768,-32768,-32768,    -7,   487,-32768,-32768,   271,   271,
     -58,    24,   -43,    25,   271,    -7,   487,    -7,   577,    -7,
     577,   445,-32768,-32768,    50,    -5,   487,   487,-32768,   128,
  -32768,   128,   487,    -5,    -5,    -5,    38,   128,    31,-32768,
  -32768,   271,-32768,   271,   487,-32768,   487,    33,   128,-32768,
  -32768,   101,-32768
};

static const short yypgoto[] =
{
  -32768,   103,   -62,-32768,    74,-32768,-32768,   -72,-32768,    -1,
  -32768,-32768,-32768,-32768,-32768,-32768,    -6,-32768,    12,    16,
       0,   104,   -94
};


#define	YYLAST		637


static const short yytable[] =
{
      30,    54,    34,    61,    48,    53,   132,    50,    59,   188,
     135,   136,    58,   169,   123,    55,    51,    63,    56,    64,
      65,    66,    62,    67,   190,   170,    69,   172,   169,   124,
      87,    88,    89,    90,   103,   104,   105,   106,   107,   108,
     109,   110,   111,   112,   125,   126,   113,    89,    90,   115,
     116,   117,    85,    86,    87,    88,    89,    90,    71,   127,
     114,    70,   119,   128,   184,    92,   174,   121,   197,   171,
     134,   173,   201,   137,   138,   139,   140,   141,   142,   143,
     144,   145,   146,   147,   148,   149,   150,   151,   152,   153,
     169,   189,   191,   154,   155,   156,   157,   158,   159,   203,
     208,   212,   162,    73,    26,    93,    94,    95,    96,    97,
      98,   160,    61,   165,   198,   161,     0,     0,   117,    60,
     117,     0,     0,   176,   178,   180,   181,   199,     0,   200,
     205,    62,     0,     0,   207,   202,     0,   210,     3,     4,
       0,     0,     5,     0,     6,     7,   209,     0,     0,     8,
       9,    10,    11,     0,    13,    14,     0,    16,    17,    18,
      19,    20,     0,     0,   185,     0,     0,   186,   187,     0,
       0,     0,     0,   192,     0,   193,     0,   194,     0,   195,
       0,     0,   211,     2,     0,     0,    21,     0,     0,     0,
      22,     0,     3,     4,    24,     0,     5,    25,     6,     7,
     204,     0,   206,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,     3,     4,     0,     0,
       5,     0,     6,     7,     0,     0,     0,     8,     9,    10,
      11,     0,    13,    14,     0,    16,    17,    18,    19,    20,
      21,     3,     4,     0,    22,    23,    45,     0,    24,     0,
       0,    25,     8,     0,     0,    11,     0,     0,     0,     0,
      16,    46,    18,     0,    21,     0,     3,     4,    22,   130,
       0,   163,    24,     0,     0,    25,   131,     8,     0,     0,
      11,     3,     4,     0,     0,    16,   164,    18,     0,    21,
       0,     0,     8,    22,     0,    11,     0,    24,     0,     0,
      16,    17,    18,     0,     0,     3,     4,     0,     0,     0,
       0,     0,     0,     0,    21,     0,     8,     0,    22,    11,
       3,     4,    24,     0,    16,   175,    18,     0,     0,    21,
       0,     8,     0,    22,    11,     3,     4,    24,     0,    16,
     177,    18,     0,     0,     0,     0,     8,     0,     0,    11,
       0,     0,     0,    21,    16,   179,    18,    22,     0,     0,
       0,    24,     0,     0,     0,     0,     0,     0,    21,     0,
       0,     0,    22,     0,     0,     0,    24,     0,     0,     0,
       0,     0,     0,    21,     0,     0,     0,    22,     0,     0,
       0,    24,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    86,    87,    88,    89,    90,     0,
       0,     0,     0,     0,     0,     0,   167,    74,    75,    76,
      77,    78,    79,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,    90,     0,     0,     0,     0,     0,     0,
     129,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,     0,     0,
       0,     0,     0,     0,   166,    74,    75,    76,    77,    78,
      79,    80,    81,    82,    83,    84,    85,    86,    87,    88,
      89,    90,     0,     0,     0,     0,     0,     0,   182,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,     0,     0,     0,     0,
     196,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,     0,     0,
      91,    74,    75,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    75,    76,
      77,    78,    79,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,    90,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    86,    87,    88,    89,    90,    77,
      78,    79,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    35,    36,
      37,    38,    39,    40,    41,    42,    43,    44,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90
};

static const short yycheck[] =
{
       1,    10,    63,    10,     5,    11,    68,    66,    14,    67,
      72,    73,    13,    71,    19,    24,    66,    17,    27,    34,
      21,    22,    29,    24,    67,   119,    63,   121,    71,    34,
      57,    58,    59,    60,    35,    36,    37,    38,    39,    40,
      41,    42,    43,    44,    49,    50,    46,    59,    60,    50,
      51,    52,    55,    56,    57,    58,    59,    60,    66,    64,
      71,    63,    66,    64,   136,    63,    34,    66,    18,    66,
      71,    66,    34,    74,    75,    76,    77,    78,    79,    80,
      81,    82,    83,    84,    85,    86,    87,    88,    89,    90,
      71,    67,    67,    93,    94,    95,    96,    97,    98,    68,
      67,     0,   102,    29,     1,     3,     4,     5,     6,     7,
       8,    99,    10,   114,   186,    99,    -1,    -1,   119,    15,
     121,    -1,    -1,   124,   125,   126,   127,   189,    -1,   191,
     202,    29,    -1,    -1,   206,   197,    -1,   209,    10,    11,
      -1,    -1,    14,    -1,    16,    17,   208,    -1,    -1,    21,
      22,    23,    24,    -1,    26,    27,    -1,    29,    30,    31,
      32,    33,    -1,    -1,   164,    -1,    -1,   168,   169,    -1,
      -1,    -1,    -1,   174,    -1,   175,    -1,   177,    -1,   179,
      -1,    -1,     0,     1,    -1,    -1,    58,    -1,    -1,    -1,
      62,    -1,    10,    11,    66,    -1,    14,    69,    16,    17,
     201,    -1,   203,    21,    22,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    10,    11,    -1,    -1,
      14,    -1,    16,    17,    -1,    -1,    -1,    21,    22,    23,
      24,    -1,    26,    27,    -1,    29,    30,    31,    32,    33,
      58,    10,    11,    -1,    62,    63,    15,    -1,    66,    -1,
      -1,    69,    21,    -1,    -1,    24,    -1,    -1,    -1,    -1,
      29,    30,    31,    -1,    58,    -1,    10,    11,    62,    63,
      -1,    15,    66,    -1,    -1,    69,    70,    21,    -1,    -1,
      24,    10,    11,    -1,    -1,    29,    30,    31,    -1,    58,
      -1,    -1,    21,    62,    -1,    24,    -1,    66,    -1,    -1,
      29,    30,    31,    -1,    -1,    10,    11,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    58,    -1,    21,    -1,    62,    24,
      10,    11,    66,    -1,    29,    30,    31,    -1,    -1,    58,
      -1,    21,    -1,    62,    24,    10,    11,    66,    -1,    29,
      30,    31,    -1,    -1,    -1,    -1,    21,    -1,    -1,    24,
      -1,    -1,    -1,    58,    29,    30,    31,    62,    -1,    -1,
      -1,    66,    -1,    -1,    -1,    -1,    -1,    -1,    58,    -1,
      -1,    -1,    62,    -1,    -1,    -1,    66,    -1,    -1,    -1,
      -1,    -1,    -1,    58,    -1,    -1,    -1,    62,    -1,    -1,
      -1,    66,    44,    45,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    68,    44,    45,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    59,    60,    -1,    -1,    -1,    -1,    -1,    -1,
      67,    44,    45,    46,    47,    48,    49,    50,    51,    52,
      53,    54,    55,    56,    57,    58,    59,    60,    -1,    -1,
      -1,    -1,    -1,    -1,    67,    44,    45,    46,    47,    48,
      49,    50,    51,    52,    53,    54,    55,    56,    57,    58,
      59,    60,    -1,    -1,    -1,    -1,    -1,    -1,    67,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    -1,    -1,    -1,    -1,
      65,    44,    45,    46,    47,    48,    49,    50,    51,    52,
      53,    54,    55,    56,    57,    58,    59,    60,    -1,    -1,
      63,    44,    45,    46,    47,    48,    49,    50,    51,    52,
      53,    54,    55,    56,    57,    58,    59,    60,    45,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    59,    60,    46,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    47,
      48,    49,    50,    51,    52,    53,    54,    55,    56,    57,
      58,    59,    60,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    49,    50,    51,    52,
      53,    54,    55,    56,    57,    58,    59,    60,    34,    35,
      36,    37,    38,    39,    40,    41,    42,    43,    51,    52,
      53,    54,    55,    56,    57,    58,    59,    60
};
/* -*-C-*-  Note some compilers choke on comments on `#line' lines.  */
#line 3 "/usr/local/share/bison/bison.simple"

/* Skeleton output parser for bison,

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002 Free Software
   Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* This is the parser code that is written into each bison parser when
   the %semantic_parser declaration is not specified in the grammar.
   It was written by Richard Stallman by simplifying the hairy parser
   used when %semantic_parser is specified.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

#if ! defined (yyoverflow) || defined (YYERROR_VERBOSE)

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# if YYSTACK_USE_ALLOCA
#  define YYSTACK_ALLOC alloca
# else
#  ifndef YYSTACK_USE_ALLOCA
#   if defined (alloca) || defined (_ALLOCA_H)
#    define YYSTACK_ALLOC alloca
#   else
#    ifdef __GNUC__
#     define YYSTACK_ALLOC __builtin_alloca
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning. */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
# else
#  if defined (__STDC__) || defined (__cplusplus)
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   define YYSIZE_T size_t
#  endif
#  define YYSTACK_ALLOC malloc
#  define YYSTACK_FREE free
# endif
#endif /* ! defined (yyoverflow) || defined (YYERROR_VERBOSE) */


#if (! defined (yyoverflow) \
     && (! defined (__cplusplus) \
	 || (YYLTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short yyss;
  YYSTYPE yyvs;
# if YYLSP_NEEDED
  YYLTYPE yyls;
# endif
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAX (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# if YYLSP_NEEDED
#  define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE) + sizeof (YYLTYPE))	\
      + 2 * YYSTACK_GAP_MAX)
# else
#  define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE))				\
      + YYSTACK_GAP_MAX)
# endif

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  register YYSIZE_T yyi;		\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (0)
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAX;	\
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif


#if ! defined (YYSIZE_T) && defined (__SIZE_TYPE__)
# define YYSIZE_T __SIZE_TYPE__
#endif
#if ! defined (YYSIZE_T) && defined (size_t)
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T)
# if defined (__STDC__) || defined (__cplusplus)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# endif
#endif
#if ! defined (YYSIZE_T)
# define YYSIZE_T unsigned int
#endif

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		-2
#define YYEOF		0
#define YYACCEPT	goto yyacceptlab
#define YYABORT 	goto yyabortlab
#define YYERROR		goto yyerrlab1
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
      yychar1 = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { 								\
      yyerror ("syntax error: cannot back up");			\
      YYERROR;							\
    }								\
while (0)

#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Compute the default location (before the actions
   are run).

   When YYLLOC_DEFAULT is run, CURRENT is set the location of the
   first token.  By default, to implement support for ranges, extend
   its range to the last symbol.  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)       	\
   Current.last_line   = Rhs[N].last_line;	\
   Current.last_column = Rhs[N].last_column;
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#if YYPURE
# if YYLSP_NEEDED
#  ifdef YYLEX_PARAM
#   define YYLEX		yylex (&yylval, &yylloc, YYLEX_PARAM)
#  else
#   define YYLEX		yylex (&yylval, &yylloc)
#  endif
# else /* !YYLSP_NEEDED */
#  ifdef YYLEX_PARAM
#   define YYLEX		yylex (&yylval, YYLEX_PARAM)
#  else
#   define YYLEX		yylex (&yylval)
#  endif
# endif /* !YYLSP_NEEDED */
#else /* !YYPURE */
# define YYLEX			yylex ()
#endif /* !YYPURE */


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
} while (0)
/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
#endif /* !YYDEBUG */

/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   SIZE_MAX < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#if YYMAXDEPTH == 0
# undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif

#ifdef YYERROR_VERBOSE

# ifndef yystrlen
#  if defined (__GLIBC__) && defined (_STRING_H)
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
#   if defined (__STDC__) || defined (__cplusplus)
yystrlen (const char *yystr)
#   else
yystrlen (yystr)
     const char *yystr;
#   endif
{
  register const char *yys = yystr;

  while (*yys++ != '\0')
    continue;

  return yys - yystr - 1;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined (__GLIBC__) && defined (_STRING_H) && defined (_GNU_SOURCE)
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
#   if defined (__STDC__) || defined (__cplusplus)
yystpcpy (char *yydest, const char *yysrc)
#   else
yystpcpy (yydest, yysrc)
     char *yydest;
     const char *yysrc;
#   endif
{
  register char *yyd = yydest;
  register const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif
#endif

#line 315 "/usr/local/share/bison/bison.simple"


/* The user can define YYPARSE_PARAM as the name of an argument to be passed
   into yyparse.  The argument should have type void *.
   It should actually point to an object.
   Grammar actions can access the variable by casting it
   to the proper pointer type.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
#  define YYPARSE_PARAM_ARG void *YYPARSE_PARAM
#  define YYPARSE_PARAM_DECL
# else
#  define YYPARSE_PARAM_ARG YYPARSE_PARAM
#  define YYPARSE_PARAM_DECL void *YYPARSE_PARAM;
# endif
#else /* !YYPARSE_PARAM */
# define YYPARSE_PARAM_ARG
# define YYPARSE_PARAM_DECL
#endif /* !YYPARSE_PARAM */

/* Prevent warning if -Wstrict-prototypes.  */
#ifdef __GNUC__
# ifdef YYPARSE_PARAM
int yyparse (void *);
# else
int yyparse (void);
# endif
#endif

/* YY_DECL_VARIABLES -- depending whether we use a pure parser,
   variables are global, or local to YYPARSE.  */

#define YY_DECL_NON_LSP_VARIABLES			\
/* The lookahead symbol.  */				\
int yychar;						\
							\
/* The semantic value of the lookahead symbol. */	\
YYSTYPE yylval;						\
							\
/* Number of parse errors so far.  */			\
int yynerrs;

#if YYLSP_NEEDED
# define YY_DECL_VARIABLES			\
YY_DECL_NON_LSP_VARIABLES			\
						\
/* Location data for the lookahead symbol.  */	\
YYLTYPE yylloc;
#else
# define YY_DECL_VARIABLES			\
YY_DECL_NON_LSP_VARIABLES
#endif


/* If nonreentrant, generate the variables here. */

#if !YYPURE
YY_DECL_VARIABLES
#endif  /* !YYPURE */

int
yyparse (YYPARSE_PARAM_ARG)
     YYPARSE_PARAM_DECL
{
  /* If reentrant, generate the variables here. */
#if YYPURE
  YY_DECL_VARIABLES
#endif  /* !YYPURE */

  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Lookahead token as an internal (translated) token number.  */
  int yychar1 = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack. */
  short	yyssa[YYINITDEPTH];
  short *yyss = yyssa;
  register short *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  register YYSTYPE *yyvsp;

#if YYLSP_NEEDED
  /* The location stack.  */
  YYLTYPE yylsa[YYINITDEPTH];
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;
#endif

#if YYLSP_NEEDED
# define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)
#else
# define YYPOPSTACK   (yyvsp--, yyssp--)
#endif

  YYSIZE_T yystacksize = YYINITDEPTH;


  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
#if YYLSP_NEEDED
  YYLTYPE yyloc;
#endif

  /* When reducing, the number of symbols on the RHS of the reduced
     rule. */
  int yylen;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;
#if YYLSP_NEEDED
  yylsp = yyls;
#endif
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed. so pushing a state here evens the stacks.
     */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short *yyss1 = yyss;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  */
# if YYLSP_NEEDED
	YYLTYPE *yyls1 = yyls;
	/* This used to be a conditional around just the two extra args,
	   but that might be undefined if yyoverflow is a macro.  */
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yyls1, yysize * sizeof (*yylsp),
		    &yystacksize);
	yyls = yyls1;
# else
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yystacksize);
# endif
	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyoverflowlab;
# else
      /* Extend the stack our own way.  */
      if (yystacksize >= YYMAXDEPTH)
	goto yyoverflowlab;
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
	yystacksize = YYMAXDEPTH;

      {
	short *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyoverflowlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);
# if YYLSP_NEEDED
	YYSTACK_RELOCATE (yyls);
# endif
# undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
#if YYLSP_NEEDED
      yylsp = yyls + yysize - 1;
#endif

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyssp >= yyss + yystacksize - 1)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (yychar <= 0)		/* This means end of input. */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more */

      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yychar1 = YYTRANSLATE (yychar);

#if YYDEBUG
     /* We have to keep this `#if YYDEBUG', since we use variables
	which are defined only if `YYDEBUG' is set.  */
      if (yydebug)
	{
	  YYFPRINTF (stderr, "Next token is %d (%s",
		     yychar, yytname[yychar1]);
	  /* Give the individual parser a way to print the precise
	     meaning of a token, for further debugging info.  */
# ifdef YYPRINT
	  YYPRINT (stderr, yychar, yylval);
# endif
	  YYFPRINTF (stderr, ")\n");
	}
#endif
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */
  YYDPRINTF ((stderr, "Shifting token %d (%s), ",
	      yychar, yytname[yychar1]));

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
#if YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  yystate = yyn;
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

     Otherwise, the following line sets YYVAL to the semantic value of
     the lookahead token.  This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

#if YYLSP_NEEDED
  /* Similarly for the default location.  Let the user run additional
     commands if for instance locations are ranges.  */
  yyloc = yylsp[1-yylen];
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
#endif

#if YYDEBUG
  /* We have to keep this `#if YYDEBUG', since we use variables which
     are defined only if `YYDEBUG' is set.  */
  if (yydebug)
    {
      int yyi;

      YYFPRINTF (stderr, "Reducing via rule %d (line %d), ",
		 yyn, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (yyi = yyprhs[yyn]; yyrhs[yyi] > 0; yyi++)
	YYFPRINTF (stderr, "%s ", yytname[yyrhs[yyi]]);
      YYFPRINTF (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif

  switch (yyn) {

case 2:
#line 48 "sushi.y"
{ code(STOP); return (1); ;
    break;}
case 3:
#line 49 "sushi.y"
{ code(STOP); return (1); Prompt(); ;
    break;}
case 4:
#line 50 "sushi.y"
{ code2(pop, STOP); return (1); ;
    break;}
case 5:
#line 51 "sushi.y"
{ code(STOP); return (1); ;
    break;}
case 6:
#line 52 "sushi.y"
{ code2(pop, STOP); return (1); ;
    break;}
case 7:
#line 53 "sushi.y"
{ yyerrok; ;
    break;}
case 8:
#line 55 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, Assign); ;
    break;}
case 9:
#line 57 "sushi.y"
{ yyval.inst = yyvsp[-5].inst; code(SetBufElement); ;
    break;}
case 10:
#line 58 "sushi.y"
{ yyval.inst = yyvsp[-2].inst; code(SetBuf); ;
    break;}
case 11:
#line 59 "sushi.y"
{ yyval.inst = yyvsp[-3].inst; code(SetBufEq); ;
    break;}
case 12:
#line 60 "sushi.y"
{ yyval.inst = yyvsp[-3].inst; code(SetBufSize); ;
    break;}
case 13:
#line 61 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, PlusEq); ;
    break;}
case 14:
#line 62 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, MinusEq); ;
    break;}
case 15:
#line 63 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, TimesEq); ;
    break;}
case 16:
#line 64 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, DivEq); ;
    break;}
case 17:
#line 65 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, AndEq); ;
    break;}
case 18:
#line 66 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, OrEq); ;
    break;}
case 19:
#line 67 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, XorEq); ;
    break;}
case 20:
#line 68 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, LshEq); ;
    break;}
case 21:
#line 69 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code3(VarPush, (Inst)yyvsp[-2].sym, RshEq); ;
    break;}
case 22:
#line 70 "sushi.y"
{
                              DefOnly("$");
                              code2(ArgAssign, (Inst)yyvsp[-2].narg);
                              yyval.inst = yyvsp[0].inst;
                           ;
    break;}
case 23:
#line 76 "sushi.y"
{ code(pop); ;
    break;}
case 24:
#line 77 "sushi.y"
{ DefOnly("return"); yyval.inst = code(ProcRet); ;
    break;}
case 25:
#line 78 "sushi.y"
{ DefOnly("return"); yyval.inst = yyvsp[0].inst; code(FuncRet); ;
    break;}
case 26:
#line 79 "sushi.y"
{ yyval.inst = code(BreakCode); ;
    break;}
case 27:
#line 80 "sushi.y"
{ yyval.inst = code(ContinueCode); ;
    break;}
case 28:
#line 82 "sushi.y"
{ yyval.inst = yyvsp[-3].inst; code3(Call, (Inst)yyvsp[-4].sym, (Inst)yyvsp[-1].narg); ;
    break;}
case 29:
#line 83 "sushi.y"
{ yyval.inst = yyvsp[0].inst; ;
    break;}
case 30:
#line 84 "sushi.y"
{
			                        yyval.inst = yyvsp[-1].inst;
											code3(Command, (Inst)yyvsp[-2].sym->u.func, (Inst)yyvsp[0].narg);
	                           ;
    break;}
case 31:
#line 89 "sushi.y"
{
                   yyval.inst = yyvsp[-9].inst; (yyvsp[-8].inst)[1] = (Inst)yyvsp[-4].inst;
                   (yyvsp[-8].inst)[2] = (Inst)yyvsp[-1].inst; (yyvsp[-8].inst)[3] = (Inst)yyvsp[0].inst;
                ;
    break;}
case 32:
#line 93 "sushi.y"
{ (yyvsp[-3].inst)[1] = (Inst)yyvsp[-1].inst; (yyvsp[-3].inst)[2] = (Inst)yyvsp[0].inst; ;
    break;}
case 33:
#line 94 "sushi.y"
{ (yyvsp[-3].inst)[1] = (Inst)yyvsp[-1].inst; (yyvsp[-3].inst)[3] = (Inst)yyvsp[0].inst; ;
    break;}
case 34:
#line 95 "sushi.y"
{
                                    (yyvsp[-6].inst)[1] = (Inst)yyvsp[-4].inst;
                                    (yyvsp[-6].inst)[2] = (Inst)yyvsp[-1].inst;
                                    (yyvsp[-6].inst)[3] = (Inst)yyvsp[0].inst;
                                 ;
    break;}
case 35:
#line 100 "sushi.y"
{ yyval.inst = yyvsp[-1].inst; ;
    break;}
case 36:
#line 102 "sushi.y"
{ yyval.inst = code(ForCode); code3(STOP, STOP, STOP);;
    break;}
case 37:
#line 104 "sushi.y"
{ code(STOP); yyval.inst = yyvsp[-1].inst; ;
    break;}
case 38:
#line 106 "sushi.y"
{ yyval.inst = code3(WhileCode, STOP, STOP); ;
    break;}
case 39:
#line 108 "sushi.y"
{ yyval.inst = code(IfCode); code3(STOP, STOP, STOP); ;
    break;}
case 40:
#line 110 "sushi.y"
{ code(STOP); yyval.inst = progp; ;
    break;}
case 41:
#line 112 "sushi.y"
{ yyval.inst = progp; ;
    break;}
case 44:
#line 116 "sushi.y"
{ yyval.inst = code2(ConstPush, (Inst)yyvsp[0].narg); ;
    break;}
case 45:
#line 117 "sushi.y"
{ yyval.inst = code3(VarPush, (Inst)yyvsp[0].sym, Eval); ;
    break;}
case 46:
#line 118 "sushi.y"
{ DefOnly("$"); yyval.inst = code2(Arg, (Inst)yyvsp[0].narg); ;
    break;}
case 48:
#line 121 "sushi.y"
{ yyval.inst = yyvsp[-3].inst; code3(Call, (Inst)yyvsp[-4].sym, (Inst)yyvsp[-1].narg); ;
    break;}
case 50:
#line 123 "sushi.y"
{ yyval.inst = yyvsp[-1].inst; code2(BuiltIn, (Inst)yyvsp[-3].sym->u.func); ;
    break;}
case 51:
#line 124 "sushi.y"
{ yyval.inst = yyvsp[-3].inst; code(GetBufElement); ;
    break;}
case 52:
#line 125 "sushi.y"
{ yyval.inst = yyvsp[-1].inst; code(GetBufSize); ;
    break;}
case 53:
#line 126 "sushi.y"
{ yyval.inst = yyvsp[-3].inst; code(BufCmp); ;
    break;}
case 54:
#line 127 "sushi.y"
{ yyval.inst = yyvsp[-3].inst; code(BufNotCmp); ;
    break;}
case 55:
#line 128 "sushi.y"
{ yyval.inst = yyvsp[-2].inst; code(BufIsVal); ;
    break;}
case 56:
#line 129 "sushi.y"
{ yyval.inst = yyvsp[-2].inst; code(BufIsNotVal); ;
    break;}
case 57:
#line 130 "sushi.y"
{ yyval.inst = yyvsp[-1].inst; ;
    break;}
case 58:
#line 131 "sushi.y"
{ code(Add); ;
    break;}
case 59:
#line 132 "sushi.y"
{ code(Sub); ;
    break;}
case 60:
#line 133 "sushi.y"
{ code(Mul); ;
    break;}
case 61:
#line 134 "sushi.y"
{ code(Div); ;
    break;}
case 62:
#line 135 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code(Negate); ;
    break;}
case 63:
#line 136 "sushi.y"
{ code(Gt); ;
    break;}
case 64:
#line 137 "sushi.y"
{ code(Ge); ;
    break;}
case 65:
#line 138 "sushi.y"
{ code(Lt); ;
    break;}
case 66:
#line 139 "sushi.y"
{ code(Le); ;
    break;}
case 67:
#line 140 "sushi.y"
{ code(Eq); ;
    break;}
case 68:
#line 141 "sushi.y"
{ code(Ne); ;
    break;}
case 69:
#line 142 "sushi.y"
{ code(And); ;
    break;}
case 70:
#line 143 "sushi.y"
{ code(Or); ;
    break;}
case 71:
#line 144 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code(Not); ;
    break;}
case 72:
#line 145 "sushi.y"
{ code(BitOr); ;
    break;}
case 73:
#line 146 "sushi.y"
{ code(BitAnd); ;
    break;}
case 74:
#line 147 "sushi.y"
{ code(BitXor); ;
    break;}
case 75:
#line 148 "sushi.y"
{ code(Lsh); ;
    break;}
case 76:
#line 149 "sushi.y"
{ code(Rsh); ;
    break;}
case 77:
#line 151 "sushi.y"
{ yyvsp[0].sym->type = FUNCTION; InDef = 1; DefSym = yyvsp[0].sym;;
    break;}
case 78:
#line 152 "sushi.y"
{ code(ProcRet); Define(yyvsp[-4].sym); InDef = 0; ;
    break;}
case 79:
#line 153 "sushi.y"
{ yyvsp[0].sym->type = PROCEDURE; InDef = 1; DefSym = yyvsp[0].sym;;
    break;}
case 80:
#line 154 "sushi.y"
{ code(ProcRet); Define(yyvsp[-4].sym); InDef = 0; ;
    break;}
case 81:
#line 156 "sushi.y"
{ code(PrExpr); ;
    break;}
case 82:
#line 157 "sushi.y"
{ yyval.inst = code2(prstr, (Inst)yyvsp[0].sym); ;
    break;}
case 83:
#line 158 "sushi.y"
{ code(PrintBuf); ;
    break;}
case 84:
#line 159 "sushi.y"
{ code(PrExpr); ;
    break;}
case 85:
#line 160 "sushi.y"
{ code2(prstr, (Inst)yyvsp[0].sym); ;
    break;}
case 86:
#line 161 "sushi.y"
{ code(PrintBuf); ;
    break;}
case 87:
#line 163 "sushi.y"
{
                        yyval.inst = progp - 1;
                        code2(SCSIFunc, (Inst)(yyvsp[0].sym->u.func));
                     ;
    break;}
case 88:
#line 167 "sushi.y"
{
                        yyval.inst = yyvsp[0].inst - 1;
                        code2(SCSIFunc, (Inst)(yyvsp[-1].sym->u.func));
                     ;
    break;}
case 89:
#line 171 "sushi.y"
{
                        yyval.inst = yyvsp[-1].inst - 1;
                        code2(SCSIFunc, (Inst)(yyvsp[-2].sym->u.func));
                     ;
    break;}
case 90:
#line 175 "sushi.y"
{
                        yyval.inst = yyvsp[0].inst - 1;
                        code2(SCSIFunc, (Inst)(yyvsp[-1].sym->u.func));
                     ;
    break;}
case 91:
#line 180 "sushi.y"
{ code(SetGlobalTmps); ;
    break;}
case 92:
#line 182 "sushi.y"
{ yyval.inst = progp; ;
    break;}
case 95:
#line 187 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code2(AssignGlobal, (Inst)&TmpTID); ;
    break;}
case 96:
#line 188 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code2(AssignGlobal, (Inst)&TmpLUN); ;
    break;}
case 97:
#line 189 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code2(AssignGlobal, (Inst)&TmpBUF); ;
    break;}
case 98:
#line 190 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code2(AssignGlobal, (Inst)&TmpSEC); ;
    break;}
case 99:
#line 191 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code2(AssignGlobal, (Inst)&TmpNUM); ;
    break;}
case 100:
#line 192 "sushi.y"
{ yyval.inst = yyvsp[0].inst; code2(AssignGlobal, (Inst)&TmpHA); ;
    break;}
case 101:
#line 194 "sushi.y"
{ code2(AssignGlobal, (Inst)&TmpSEC); ;
    break;}
case 102:
#line 195 "sushi.y"
{
                        /* the exprs will be pushed */
                        code2(AssignGlobal, (Inst)&TmpNUM);
                        code2(AssignGlobal, (Inst)&TmpSEC);
                     ;
    break;}
case 103:
#line 201 "sushi.y"
{ yyval.inst = code2(ConstPush, (Inst)yyvsp[0].narg); ;
    break;}
case 104:
#line 202 "sushi.y"
{ yyval.inst = code3(VarPush, (Inst)yyvsp[0].sym, Eval); ;
    break;}
case 108:
#line 208 "sushi.y"
{ yyval.narg = 0; ;
    break;}
case 109:
#line 209 "sushi.y"
{ yyval.narg = 1; ;
    break;}
case 110:
#line 210 "sushi.y"
{ yyval.narg = yyvsp[-2].narg + 1; ;
    break;}
}

#line 705 "/usr/local/share/bison/bison.simple"


  yyvsp -= yylen;
  yyssp -= yylen;
#if YYLSP_NEEDED
  yylsp -= yylen;
#endif

#if YYDEBUG
  if (yydebug)
    {
      short *yyssp1 = yyss - 1;
      YYFPRINTF (stderr, "state stack now");
      while (yyssp1 != yyssp)
	YYFPRINTF (stderr, " %d", *++yyssp1);
      YYFPRINTF (stderr, "\n");
    }
#endif

  *++yyvsp = yyval;
#if YYLSP_NEEDED
  *++yylsp = yyloc;
#endif

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;

#ifdef YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (yyn > YYFLAG && yyn < YYLAST)
	{
	  YYSIZE_T yysize = 0;
	  char *yymsg;
	  int yyx, yycount;

	  yycount = 0;
	  /* Start YYX at -YYN if negative to avoid negative indexes in
	     YYCHECK.  */
	  for (yyx = yyn < 0 ? -yyn : 0;
	       yyx < (int) (sizeof (yytname) / sizeof (char *)); yyx++)
	    if (yycheck[yyx + yyn] == yyx)
	      yysize += yystrlen (yytname[yyx]) + 15, yycount++;
	  yysize += yystrlen ("parse error, unexpected ") + 1;
	  yysize += yystrlen (yytname[YYTRANSLATE (yychar)]);
	  yymsg = (char *) YYSTACK_ALLOC (yysize);
	  if (yymsg != 0)
	    {
	      char *yyp = yystpcpy (yymsg, "parse error, unexpected ");
	      yyp = yystpcpy (yyp, yytname[YYTRANSLATE (yychar)]);

	      if (yycount < 5)
		{
		  yycount = 0;
		  for (yyx = yyn < 0 ? -yyn : 0;
		       yyx < (int) (sizeof (yytname) / sizeof (char *));
		       yyx++)
		    if (yycheck[yyx + yyn] == yyx)
		      {
			const char *yyq = ! yycount ? ", expecting " : " or ";
			yyp = yystpcpy (yyp, yyq);
			yyp = yystpcpy (yyp, yytname[yyx]);
			yycount++;
		      }
		}
	      yyerror (yymsg);
	      YYSTACK_FREE (yymsg);
	    }
	  else
	    yyerror ("parse error; also virtual memory exhausted");
	}
      else
#endif /* defined (YYERROR_VERBOSE) */
	yyerror ("parse error");
    }
  goto yyerrlab1;


/*--------------------------------------------------.
| yyerrlab1 -- error raised explicitly by an action |
`--------------------------------------------------*/
yyerrlab1:
  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      /* return failure if at end of input */
      if (yychar == YYEOF)
	YYABORT;
      YYDPRINTF ((stderr, "Discarding token %d (%s).\n",
		  yychar, yytname[yychar1]));
      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */

  yyerrstatus = 3;		/* Each real token shifted decrements this */

  goto yyerrhandle;


/*-------------------------------------------------------------------.
| yyerrdefault -- current state does not do anything special for the |
| error token.                                                       |
`-------------------------------------------------------------------*/
yyerrdefault:
#if 0
  /* This is wrong; only states that explicitly want error tokens
     should shift them.  */

  /* If its default is to accept any token, ok.  Otherwise pop it.  */
  yyn = yydefact[yystate];
  if (yyn)
    goto yydefault;
#endif


/*---------------------------------------------------------------.
| yyerrpop -- pop the current state because it cannot handle the |
| error token                                                    |
`---------------------------------------------------------------*/
yyerrpop:
  if (yyssp == yyss)
    YYABORT;
  yyvsp--;
  yystate = *--yyssp;
#if YYLSP_NEEDED
  yylsp--;
#endif

#if YYDEBUG
  if (yydebug)
    {
      short *yyssp1 = yyss - 1;
      YYFPRINTF (stderr, "Error: state stack now");
      while (yyssp1 != yyssp)
	YYFPRINTF (stderr, " %d", *++yyssp1);
      YYFPRINTF (stderr, "\n");
    }
#endif

/*--------------.
| yyerrhandle.  |
`--------------*/
yyerrhandle:
  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yyerrdefault;

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    goto yyerrdefault;

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrpop;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrpop;

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;
#if YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

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

/*---------------------------------------------.
| yyoverflowab -- parser overflow comes here.  |
`---------------------------------------------*/
yyoverflowlab:
  yyerror ("parser stack overflow");
  yyresult = 2;
  /* Fall through.  */

yyreturn:
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  return yyresult;
}
#line 212 "sushi.y"

