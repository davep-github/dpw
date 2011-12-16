#include <cstdio>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


void
dump_environ(
  void)
{
  extern char**   environ;
  int             i;

  for(i = 0; environ[i]; ++i) {
    printf("%s\n", environ[i]);
  }
}
  

int
main(
  int   argc,
  char* argv[])
{
  int fd_err;
  int fd_out;

  const char* kget_path;

  if (argc > 1)
    kget_path = argv[1];
  else
    kget_path = "/usr/kde/3.3/bin/kget";    
  
  const char* ofile = "/tmp/kget.davep.stdout";
  if ((fd_out = open(ofile, O_RDWR|O_CREAT|O_TRUNC, 0660)) < 0) {
    perror("Cannot open stdout file");
  } else {
    close(1);                   // stdout
    dup2(fd_out, 1);
  }

  ofile = "/tmp/kget.davep.stderr";
  if ((fd_err = open(ofile, O_RDWR|O_CREAT|O_TRUNC, 0660)) < 0) {
    perror("Cannot open stderr file");
  } else {
    close(2);                    // stderr
    dup2(fd_err, 2);
  }

  dump_environ();
  printf("exec'ing>%s<\n", kget_path);
  printf("===============================================================\n");
  fsync(fd_out);
  fsync(fd_err);
  sleep(2);
  
  return(execl(kget_path, kget_path, 0));
}



  
    
  
