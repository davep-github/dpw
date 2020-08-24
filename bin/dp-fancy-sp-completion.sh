# bash completion for sudo(8)                              -*- shell-script -*-

_dp_sp()
{
    local cur prev words cword
    _init_completion || return
    
    local i
    for (( i=1; i <= COMP_CWORD; i++ )); do
        if [[ ${COMP_WORDS[i]} != -* ]]; then
            local root_command=${COMP_WORDS[i]}
            _command_offset $i
            return
        fi
        [[ ${COMP_WORDS[i]} == -@([0-9]|l|ll|r|x|f|v|F|e|L|g|G|d|S) ]] && ((i++))
    done

    case "$prev" in
        -x)
            ## COMPREPLY=( $( compgen -c -- "$cur" ) )
            COMPREPLY=( $( compgen -c -- "$cur" ) )
            return
            ;;
        -X|-f)
            # argument required but no completions available
            return
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-1 -2 -3 -4 -5 -6 -7 -8 -9
            -x -X -f
            -l -ll -r -v -F -e -g -G -d -s' -- "$cur" ) )
        return
    fi
} && complete -F _dp_sp sp

# ex: ts=4 sw=4 et filetype=sh
