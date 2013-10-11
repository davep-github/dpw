#!/bin/sh
source script-x
set -u
progname="$(basename $0)"
source eexec
if vsetp "${eexec_program-}"    # Did the caller provide a program?
then
    EEXEC_SHIFT=:
else
    eexec_program=$(EExec_parse "$@")
    EEXEC_SHIFT=shift
fi

for op in $eexec_program
do
  $op
  ${EEXEC_SHIFT}
done
unset eexec_program
# Or export eexec_program to propagate eexec info to a called program.
# export eexec_program


: ${replace_default_symlink=}

[ "${1}" = "--ap" ] && {
    shift
    replace_default_symlink="${1}"
    shift
}

dest="${1}"
shift
if (($# > 0))
then
    sb_arg="--tree-root $1"
    shift
else
    sb_arg=''
fi
# The remainder of argv will be extra args to sandbox_relativity

exp=$(~/lib/pylib/tree_root_relativity.py --expand-dest="${dest}" --abbrev-suffix="__ME_src" $sb_arg "$@")

vsetp "${replace_default_symlink}" && {
    exp=$(echo "${exp}" | sed -r "s|/Default_ap_tree/|/${replace_default_symlink}/|")
}

vsetp "${exp}" && echo "${exp}"

