// -*- mode: C++; c-file-style: "intel-c-style" -*-

#define COMMAND(NAME)  { #NAME, NAME ## _command }

     struct command commands[] =
     {
       COMMAND (quit),
       COMMAND (help),
       ...
     };

