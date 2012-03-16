// -*- mode: C++; c-file-style: "intel-c-style" -*-
// Meh. Why save this?  Why comment about it instead of deleting it?
// realization: I've spend more time commenting than it would ever take to
// recreate it.
void dump_xxxv(
    int xxxc,
    char** xxxv,
    const char* msg=0)
{
    if (msg) {
        log_stream << msg;
    }

    log_stream << "xxxc: " << xxxc << std::endl;
    for (int i=0; i < xxxc; ++i) {
        log_stream << "i: " << i << "...";
        DEBUG_VAR_LOG(xxxv[i]) << endl;
    }
}

