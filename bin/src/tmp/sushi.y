%{
  
#include <stdio.h>
/*#include "sushi-types.h"*/

#include "sushi-su.h"

#define code2(c1, c2)      code(c1); code(c2)
#define code3(c1, c2, c3)  code(c1); code(c2); code(c3)

uint  LineNum = 1;

int		InDef = 0;
Symbol	*DefSym;

extern int yydebug;

%}

%union {
   Symbol   *sym;
   Inst  *inst;
   int   narg;
}
%token   <sym> SOTID SOLUN SOBUF SOSEC SONUM SOHA OPTION
%token   <sym> VAR SFUNC UNDEF KEYWORD PRINT STRING
%token   <sym> WHILE IF ELSE DOTSIZE END BLTIN FOR CMD
%token   <sym> FUNCTION FUNC RETURN PROCEDURE PROC
%token   <narg>   NUMBER BUF ARG BREAK CONTINUE
%type    <inst>   asgn sfunc expr stmt stmtlist prlist fBegin
%type    <inst>   cond while if end nVal begin sopt sopts sargs
%type    <sym> procname sbegin
%type    <narg>   arglist
%right   '=' PLUSEQ MINUSEQ TIMESEQ DIVEQ ANDEQ OREQ XOREQ LSHEQ RSHEQ
%left    OR
%left    AND
%left    BITOR
%left    BITXOR
%left    BITAND
%left    EQ NE
%left    GT GE LT LE
%left    LSH RSH
%left    '+' '-'
%left    '/' '*'
%left    UNARYMINUS NOT
%%
list:     /* empty */
         | list '\n'       { code(STOP); return (1); }
         | list defn '\n'  { code(STOP); return (1); Prompt(); }
         | list asgn '\n'  { code2(pop, STOP); return (1); }
         | list stmt '\n'  { code(STOP); return (1); }
         | list expr '\n'  { code2(pop, STOP); return (1); }
         | list error '\n' { yyerrok; }
         ;
asgn:      VAR '=' expr    { $$ = $3; code3(VarPush, (Inst)$1, Assign); }
         | BUF nVal '[' expr ']' '=' expr
                                       { $$ = $2; code(SetBufElement); }
         | BUF nVal '=' expr           { $$ = $2; code(SetBuf); } 
         | BUF nVal '=' BUF nVal       { $$ = $2; code(SetBufEq); }
         | BUF nVal DOTSIZE '=' expr   { $$ = $2; code(SetBufSize); }
         | VAR PLUSEQ expr    { $$ = $3; code3(VarPush, (Inst)$1, PlusEq); }
         | VAR MINUSEQ expr   { $$ = $3; code3(VarPush, (Inst)$1, MinusEq); }
         | VAR TIMESEQ expr   { $$ = $3; code3(VarPush, (Inst)$1, TimesEq); }
         | VAR DIVEQ expr     { $$ = $3; code3(VarPush, (Inst)$1, DivEq); }
         | VAR ANDEQ expr     { $$ = $3; code3(VarPush, (Inst)$1, AndEq); }
         | VAR OREQ expr      { $$ = $3; code3(VarPush, (Inst)$1, OrEq); }
         | VAR XOREQ expr  { $$ = $3; code3(VarPush, (Inst)$1, XorEq); }
         | VAR LSHEQ expr  { $$ = $3; code3(VarPush, (Inst)$1, LshEq); }
         | VAR RSHEQ expr  { $$ = $3; code3(VarPush, (Inst)$1, RshEq); }
         | ARG '=' expr    {
                              DefOnly("$");
                              code2(ArgAssign, (Inst)$1);
                              $$ = $3;
                           }
   ;
stmt:      expr                  { code(pop); }
         | RETURN                { DefOnly("return"); $$ = code(ProcRet); }
         | RETURN expr           { DefOnly("return"); $$ = $2; code(FuncRet); }
         | BREAK                 { $$ = code(BreakCode); }
         | CONTINUE              { $$ = code(ContinueCode); }
         | PROCEDURE begin '(' arglist ')'
                                 { $$ = $2; code3(Call, (Inst)$1, (Inst)$4); }
         | PRINT prlist          { $$ = $2; }
		   | CMD begin arglist  {
			                        $$ = $2;
											code3(Command, (Inst)$1->u.func, (Inst)$3);
	                           }
         | FOR '(' expr fBegin  expr end ';' expr end ')' stmt end
                {
                   $$ = $3; ($4)[1] = (Inst)$8;
                   ($4)[2] = (Inst)$11; ($4)[3] = (Inst)$12;
                }
         | while cond stmt end   { ($1)[1] = (Inst)$3; ($1)[2] = (Inst)$4; }
         | if cond stmt end      { ($1)[1] = (Inst)$3; ($1)[3] = (Inst)$4; }
         | if cond stmt end ELSE stmt end {
                                    ($1)[1] = (Inst)$3;
                                    ($1)[2] = (Inst)$6;
                                    ($1)[3] = (Inst)$7;
                                 }
         | '{' stmtlist '}'   { $$ = $2; }
         ;
fBegin:	  ';'		{ $$ = code(ForCode); code3(STOP, STOP, STOP);}
			;
cond:      '(' expr ')'    { code(STOP); $$ = $2; }
         ;
while:     WHILE           { $$ = code3(WhileCode, STOP, STOP); }
         ;
if:        IF              { $$ = code(IfCode); code3(STOP, STOP, STOP); }
         ;
end:    /* empty */        { code(STOP); $$ = progp; }
   ;
stmtlist: /* empty */      { $$ = progp; }
         | stmtlist '\n'
         | stmtlist stmt
   ;
expr:      NUMBER    { $$ = code2(ConstPush, (Inst)$1); }
         | VAR       { $$ = code3(VarPush, (Inst)$1, Eval); }
         | ARG       { DefOnly("$"); $$ = code2(Arg, (Inst)$1); }
         | asgn
         | FUNCTION begin '(' arglist ')' 
                     { $$ = $2; code3(Call, (Inst)$1, (Inst)$4); }
         | sfunc
         | BLTIN '(' expr ')' { $$ = $3; code2(BuiltIn, (Inst)$1->u.func); }
         | BUF nVal '[' expr ']' { $$ = $2; code(GetBufElement); }
         | BUF nVal DOTSIZE      { $$ = $2; code(GetBufSize); }
         | BUF nVal EQ BUF nVal  { $$ = $2; code(BufCmp); }
         | BUF nVal NE BUF nVal  { $$ = $2; code(BufNotCmp); }
         | BUF nVal EQ expr   { $$ = $2; code(BufIsVal); }
         | BUF nVal NE expr   { $$ = $2; code(BufIsNotVal); }
         | '(' expr ')'    { $$ = $2; }
         | expr '+' expr      { code(Add); }
         | expr '-' expr      { code(Sub); }
         | expr '*' expr      { code(Mul); }
         | expr '/' expr      { code(Div); }
         | '-' expr %prec UNARYMINUS   { $$ = $2; code(Negate); }
         | expr GT expr    { code(Gt); }
         | expr GE expr    { code(Ge); }
         | expr LT expr    { code(Lt); }
         | expr LE expr    { code(Le); }
         | expr EQ expr    { code(Eq); }
         | expr NE expr    { code(Ne); }
         | expr AND expr      { code(And); }
         | expr OR expr    { code(Or); }
         | NOT expr     { $$ = $2; code(Not); }
         | expr BITOR expr { code(BitOr); }
         | expr BITAND expr   { code(BitAnd); }
         | expr BITXOR expr   { code(BitXor); }
			| expr LSH expr		{ code(Lsh); }
			| expr RSH expr		{ code(Rsh); }
         ;
defn:      FUNC procname      { $2->type = FUNCTION; InDef = 1; DefSym = $2;}
               '(' ')' stmt   { code(ProcRet); Define($2); InDef = 0; }
         | PROC procname      { $2->type = PROCEDURE; InDef = 1; DefSym = $2;}
               '(' ')' stmt   { code(ProcRet); Define($2); InDef = 0; }
         ;
prlist:    expr         { code(PrExpr); }
         | STRING    { $$ = code2(prstr, (Inst)$1); }
         | BUF nVal     { code(PrintBuf); }
         | prlist ',' expr { code(PrExpr); }
         | prlist ',' STRING  { code2(prstr, (Inst)$3); }
         | prlist ',' BUF nVal   { code(PrintBuf); }
         ;
sfunc:     sbegin    {
                        $$ = progp - 1;
                        code2(SCSIFunc, (Inst)($1->u.func));
                     }
         | sbegin sopts  {
                        $$ = $2 - 1;
                        code2(SCSIFunc, (Inst)($1->u.func));
                     }
         | sbegin sopts sargs {
                        $$ = $2 - 1;
                        code2(SCSIFunc, (Inst)($1->u.func));
                     }
         | sbegin sargs    {
                        $$ = $2 - 1;
                        code2(SCSIFunc, (Inst)($1->u.func));
                     }
         ;
sbegin:    SFUNC     { code(SetGlobalTmps); }
         ;
begin:     /* empty */     { $$ = progp; }
         ;
sopts:     sopts sopt
         | sopt
            ;
sopt:      SOTID nVal   { $$ = $2; code2(AssignGlobal, (Inst)&TmpTID); }
         | SOLUN nVal   { $$ = $2; code2(AssignGlobal, (Inst)&TmpLUN); }
         | SOBUF nVal   { $$ = $2; code2(AssignGlobal, (Inst)&TmpBUF); }
         | SOSEC nVal   { $$ = $2; code2(AssignGlobal, (Inst)&TmpSEC); }
         | SONUM nVal   { $$ = $2; code2(AssignGlobal, (Inst)&TmpNUM); }
         | SOHA  nVal   { $$ = $2; code2(AssignGlobal, (Inst)&TmpHA); }
         ;
sargs:     nVal     { code2(AssignGlobal, (Inst)&TmpSEC); }
         | nVal nVal {
                        /* the exprs will be pushed */
                        code2(AssignGlobal, (Inst)&TmpNUM);
                        code2(AssignGlobal, (Inst)&TmpSEC);
                     }
         ;
nVal:      NUMBER { $$ = code2(ConstPush, (Inst)$1); }
         | VAR    { $$ = code3(VarPush, (Inst)$1, Eval); }
         ;
procname:  VAR
         | FUNCTION
         | PROCEDURE
         
arglist:   /* empty */        { $$ = 0; }
         | expr               { $$ = 1; }
         | arglist ',' expr   { $$ = $1 + 1; }
         ;
%%
