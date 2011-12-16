
  volatile int forkin   = -1;
  volatile int forkout  = -1;


	    xforkout = xforkin = open (pty_name, O_RDWR | OPEN_BINARY, 0);
            assert (isatty (xforkin));
