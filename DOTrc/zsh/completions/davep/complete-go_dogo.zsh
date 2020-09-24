#compdef _dogo dogo

# see /home/davep/.rc/zsh/completions/davep/simple-example.zsh
function _dogo {
    local line

    _arguments -C \
	"-i[I am complete-go_dogo.zsh]" \
        "-l[Show directory]" \
        "-L[Quick lookup]" \
        "-n[No eval -- UNUSED]" \
	"--no-dirname[Only use the dirname of the expanded abbrev.]" \
        "*::arg:->args"
    # Can I limit to one arg?
}
