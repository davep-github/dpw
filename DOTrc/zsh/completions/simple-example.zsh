#compdef _hello hello
# -*- mode: sh; -*-


# Imagine you have a program with an interface like the following

# hello -h | --help
# hello quietly [--silent] <message>
# hello loudly [--repeat=<number>] <message>

# This imaginary program has two command quietly and loudly that each have
# distinct arguments you can pass to them – ideally we’d like the completion
# script to complete -h, --help, quietly, and loudly when no commands are
# supplied, and once either quietly or loudly has been entered it should give
# context specific completions for those.

# The following zsh script provides completions for the program as
# described. In the rest of the post I’ll give an explanation of the general
# outline of the script and dive into some of the more interesting parts.

# see /home/davep/.rc/zsh/completions/davep/simple-example.zsh
function _hello {
    local line

    _arguments -C \
        "-h[Show help information]" \
        "--h[Show help information]" \
        "1: :(quietly loudly)" \
        "*::arg:->args"

    case $line[1] in
        loudly)
            _hello_loudly
        ;;
        quietly)
            _hello_quietly
        ;;
    esac
}

function _hello_quietly {
    _arguments \
        "--silent[Dont output anything]"
}

function _hello_loudly {
    _arguments \
        "--repeat=[Repat the <message> any number of times]"
}


