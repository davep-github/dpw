# -*-Shell-script-*-

#@todo XXX Make a dp-sh-common file.

export DP_RC_VERBOSE=false

# For any zsh-isms
dp_zsh_p()
{
    # NB: For the case when, like now, I'm running zsh on top of bash, there
    # are environmental issues.  E.g. bash environment variables are
    # preserved, like $SHELL = '/bin/bash'. Also, zsh login shell stuff is
    # not set (e.g. like $SHELL != zsh.)
    # Maybe the solution is for me to always run zsh as a login shell.
    [[ "${ZSH_VERSION-}" != '' ]]
}

if dp_zsh_p
then
    DP_EXPORT_FUNC() {
	:
    }
    DP_ZSH_ONLY() {
	"$@"
    }
    DP_BASH_ONLY() {
	:
    }

    DP_BASH_TYPE_t() {
	whence -w
    }

    export DP_ZSH_p=true
    export DP_BASH_p=false
    export DP_SHELL=zsh

else	# BASH

    DP_EXPORT_FUNC() {
	export -f "$@"
    }
    DP_EXPORT_FUNC DP_EXPORT_FUNC
    DP_ZSH_ONLY() {
	:
    }
    DP_EXPORT_FUNC DP_ZSH_ONLY
    DP_BASH_ONLY() {
	"$@"
    }
    DP_EXPORT_FUNC DP_BASH_ONLY
    DP_EXPORT_FUNC dp_zsh_p

    DP_BASH_TYPE_t() {
	type -t "$@"
    }
    DP_EXPORT_FUNC DP_BASH_TYPE_t

    export DP_ZSH_p=true
    export DP_BASH_p=false
    export DP_SHELL=zsh

fi

DP_EXPORT_FUNC DP_EXPORT_FUNC

true
