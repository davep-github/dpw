#define DEBUG_SHOW_VAR(var) #var << ">" << var << "<"

// make variadic on newline.
// Why did I do the newline this way?
#define DEBUG_VAR_NAME_AND_VAL_WTF(var, dstream, newline)       \
  dstream << "sa: " << DEBUG_SHOW_VAR(var) newline

#define DEBUG_VAR_NAME_AND_VAL(dstream, var)    \
  dstream << "sa: " << DEBUG_SHOW_VAR(var)

#define DEBUG_VAR_LOG(v)                        \
  DEBUG_VAR_NAME_AND_VAL(log_stream, v)

#define DEBUG_VAR_ERR(v)                        \
  DEBUG_VAR_NAME_AND_VAL(error_stream, v)

#define DEBUG_VAR_DEV(v)                        \
  DEBUG_VAR_NAME_AND_VAL(dev_stream, v)

#define DEBUG_VAR_TRACE(v)                      \
  DEBUG_VAR_NAME_AND_VAL(trace_stream, v)

#define DEBUG_VAR_STAT(v)                       \
  DEBUG_VAR_NAME_AND_VAL(status_stream, v)

#define DEBUG_VAR_UI(v)                         \
  DEBUG_VAR_NAME_AND_VAL(ui_stream, v)
