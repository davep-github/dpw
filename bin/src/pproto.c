#include <stdio.h>

main(
int   argc,
char  *argv[])
{
   char  buf[1024], *p;
   int   lineNum;
   int   curLine = 1;
   int   parenCount;
   int   c;

   if (argc != 2)
   {
      fprintf(stderr, "pproto: usage: pproto lineNum\n");
      fprintf(stderr, "\tskips to lineNum and emits stripped function prototype.\n");
      exit(1);
   }

   lineNum = atoi(argv[1]);

   /* "seek" to our line number */
   for (curLine = 1; curLine < lineNum; curLine++)
      if (fgets(buf, sizeof(buf) - 2, stdin) == NULL)
         exit(1);

   parenCount = 0;

   printf("extern ");

   while ((c = getchar()) != EOF)
   {
      switch (c)
      {
         case '(':
            parenCount++;
            if (parenCount == 1)
               printf(" PROTODecl (");
            putchar(c);
            break;

         case ')':
            parenCount--;
            putchar(c);
            if (parenCount == 0)
				{
               printf(");\n\n");
					exit(0);
				}
            break;

         case '/':
            if ((c = getchar()) != '*')
            {
               ungetc(c, stdin);
               putchar("/");
               break;
            }
            while (1)
            {
               while ((c = getchar()) != '*')
                  ;
               if ((c = getchar()) == '/')
                  break;
               ungetc(c, stdin);
            }
            break;

         default:
            putchar(c);
            break;
      }
   }

   exit(c != EOF);
}
