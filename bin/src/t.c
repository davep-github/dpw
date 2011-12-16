#include <stdio.h>

int &
f() {
   int i = 1;
   return i;
}

int
g() {
   int j = 2;
   return j;
}

main() {
   int &ri = f();
   g();
   printf("%d\n", ri);
}
