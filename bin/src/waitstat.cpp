#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <iostream>
#include <sstream>
#include <sys/wait.h>
#include <limits.h>
#include <assert.h>
#include <string>
#include <vector>

// #include "divers.h"

int cxx_strerror(
    int errnum,
    std::string& msg_out)
{
    char msg_buf[1024];
    char* msgp;
    int rc;

    errnum = abs(errnum);
#if (_POSIX_C_SOURCE >= 200112L || _XOPEN_SOURCE >= 600) && ! _GNU_SOURCE
    // XSI-compliant?
    rc = strerror_r(errnum, msg_buf, sizeof(msg_buf));
    if (rc != 0) {
        rc = errno;
    }
    msgp = msg_buf;
#else
    msgp = strerror_r(errnum, msg_buf, sizeof(msg_buf));
    rc = 0;
#endif
    msg_out = msgp;
    return rc;
}

std::string expand_wait_status(int status)
{
    status = abs(status);
    std::ostringstream expansion;
    if (WIFEXITED(status)) {
        int rc = WEXITSTATUS(status);
        // This errno has another def, but it seems to mean command not
        // found in this context.
        if (rc == 127) {
            expansion << "exited: command not found.";
        } else {
            std::string err_msg;
            cxx_strerror(rc, err_msg);
            expansion << "exited, errno: " << rc << ": " << err_msg;
        }
    } else if (WIFSIGNALED(status)) {
        expansion << "killed by signal: " << WTERMSIG(status);
    } else if (WIFSTOPPED(status)) {
        expansion << "stopped by signal: " << WSTOPSIG(status);
    } else if (WIFCONTINUED(status)) {
        expansion << "continued";
    }
    return expansion.str();
}

int main(
    int argc,
    char* argv[])
{
    if (argc < 2) {
        std::cerr << "Usage: waitstat <status-from-wait(2)>..." << std::endl;
        return 1;
    }

    for (int i = 1; i < argc; ++i) {
        int status = strtol(argv[i], NULL, 0);
        std::cout << expand_wait_status(status) << std::endl;
    }
    return 0;
}
