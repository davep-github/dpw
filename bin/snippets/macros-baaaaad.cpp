// -*- mode: C++; c-file-style: "meduseld-c-style" -*- 
// 

#define ENV_OVERRIDE(name)                      \
  {                                             \
    const char* p = getenv(#name);              \
    if (p) {                                    \
      name = p;                                 \
                                                \
    }                                           \
                                                \
  }

#define DEBUG_VAR(var) #var << ">" << var << "<"

// make variadic on newline.
#define DUMP_DEBUG_VAR(var, dstream, newline)   \
  dstream << DEBUG_VAR(var) newline

