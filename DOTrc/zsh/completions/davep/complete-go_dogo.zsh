#compdef _dogo dogo

# bash version for comparison.
# dp_go_complete()
# {
#         local cur
#         cur=${COMP_WORDS[COMP_CWORD]}
#         COMPREPLY=($(go2env --grep-name-only "^$cur"))
# }
# complete -F dp_go_complete g
# complete -F dp_go_complete dogo



# see /home/davep/.rc/zsh/completions/davep/simple-example.zsh
function _dogo {
    local line

    _arguments -C \
        "-l[Show directory]" \
        "-L[Quick lookup]" \
        "-n[No eval -- UNUSED]" \
	"--no-dirname[Only use the dirname of the expanded abbrev.]" \
        "*::arg:->args"
    # Can I limit to one arg?
}
