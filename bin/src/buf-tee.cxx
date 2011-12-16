#include <cstdio>
#include <cstdlib>
#include <string>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

const char* log_file_name = "/var/log/rc-run.log";

int log_file_fd = -1;

char    log_file_buffer[16 << 20];
size_t  log_file_index = 0;

typedef void (*put_func_t)(int);

put_func_t  put_func = 0;

void
put_to_file(
  int   ch)
{
  char  buf[1];
  buf[0] = ch;
  
  if (write(log_file_fd, buf, 1) != 1) {
    fprintf(stderr, "put_to_file(), write failed, errno: %d, >%s<\n",
            errno, strerror(errno));
    
  }
}

void
flush_buffer(
  void)
{
  int i = 0;
  while (i < log_file_index) {
    put_to_file(log_file_buffer[i++]);
  }
  log_file_index = 0;
}

void
put_in_buffer(
  int   ch)
{
  if (log_file_index < sizeof(log_file_buffer)) {
    log_file_buffer[log_file_index++] = ch;
  }
}

void
put_to_buf(
  int   ch)
{
  put_in_buffer(ch);
  
  log_file_fd = open(log_file_name, O_WRONLY|O_CREAT|O_TRUNC, 0644);
  
  if (log_file_fd >= 0) {       // can open
    flush_buffer();
    put_func = put_to_file;
  }
}



main(
  int   argc,
  char* argv[])
{

  if (argc > 1)
    log_file_name = argv[1];
  
  put_func = put_to_buf;
  
  int   ch;
  
  while ((ch = getchar()) != EOF) {
    putchar(ch);                // tee to stdout
    (*put_func)(ch);
  }

  if (log_file_index > 0) {
    fprintf(stderr, "buffer is not empty, index: %ld, log_file_fd == %d\n",
            log_file_index,
            log_file_fd);
    fprintf(stderr, "buffer>%s<\n", log_file_buffer);
    
    //flush_buffer();               // works if buffer is empty, no need to check
  }

  if (log_file_fd >= 0) {
    close(log_file_fd);
  }
  
  exit(0);
}
