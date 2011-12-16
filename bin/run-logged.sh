#!/bin/sh

source script-x

: ${kwa_append:=}               # -a to have tee append to its output.
: ${kwa_tee:=t}

dolat=("$@")

tee_log()
{
    local log=$1
    shift
    local append=$1
    tee ${append} ${log}
}

cat_log_append()
{
    local log=$1
    cat >> ${log}
}

cat_log()
{
    local log=$1
    shift
    local append=$1
    if [ -n "$append" ]
    then
        cat >| ${log}
    else
        cat_log_append ${log}
    fi
}

if [[ "$kwa_tee" =~ [ty1] ]]
then
    logger=tee_log
else
    logger=cat_log
fi

logfile_name=$(mk-logfile-name "$@")

{
    # Let's dump some possibly useful info.
    echo "begin: $(date)"
    pwd
    echo_id logfile_name
    echo "command>$@<"
    echo "==="
    "$@"
    echo "==="
    echo "end: $(date)"
} 2>&1 | ${logger} ${logfile_name} ${kwa_append}

# Protect the log file from accidental deletion.
# Although we'll probably end up using rm -f automatically and losing any
# safety we're trying to add.
chmod a-w ${logfile_name}
