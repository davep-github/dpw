#include <stdio.h>
#include <ctype.h>

/*
***********************************************************************
*
* 
*
***********************************************************************
*/
void  HexDump(
unsigned char	*data,
unsigned long	num)
{
   int            i;
   unsigned char  buf[16];
   long           oldNum;

   while (num)
   {
       printf("%p: ", data);

      oldNum = num;

      for (i = 0; i < 16 && num; i++, num--)
         printf("%02x%c", data[i] & 0xff, (i == 7) ? '-' : ' ');

      for (; i < 16; i++)
         printf("   ");

      printf("| ");

      for (i = 0; i < 16 && oldNum; i++, oldNum--)
         printf("%c", isprint(data[i]) ? data[i] : '.');

      for (; i < 16; i++)
         printf(" ");

      printf("\n");

		data += 16;
   }
}
