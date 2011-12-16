#include <stdio.h>
#include <pwd.h>
#include <unistd.h>

//     char *
//     getpass(const char *prompt);

int
main(
  int	argc,
  char*	argv[])
{
  char*	p;
  
  p = getpass("Password: ");

  printf("p>%s<\n", p);

  exit(0);
}

