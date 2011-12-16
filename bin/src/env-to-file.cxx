#include <cstdio>
#include <cstdlib>

int
main(
  int   argc,
  char* argv[])
{
  return (system("env > /tmp/env.davep.out"));
}

