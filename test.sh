#!/bin/bash
#
# get_completions() Author: Brian Beffa <brbsix@gmail.com>
# Original source: https://brbsix.github.io/2015/11/29/accessing-tab-completion-programmatically-in-bash/
# License: LGPLv3 (http://www.gnu.org/licenses/lgpl-3.0.txt)

get_completions(){
    local completion COMP_CWORD COMP_LINE COMP_POINT COMP_WORDS COMPREPLY=()

    # load bash-completion if necessary
    declare -F _completion_loader &>/dev/null || {
        source /usr/share/bash-completion/bash_completion
    }

    COMP_LINE=$*
    COMP_POINT=${#COMP_LINE}

    eval set -- "$@"

    COMP_WORDS=("$@")

    # add '' to COMP_WORDS if the last character of the command line is a space
    [[ ${COMP_LINE[@]: -1} = ' ' ]] && COMP_WORDS+=('')

    # index of the last word
    COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

    # determine completion function
    completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')

    # run _completion_loader only if necessary
    [[ -n $completion ]] || {

        # load completion
        _completion_loader "$1"

        # detect completion
        completion=$(complete -p "$1" 2>/dev/null | awk '{print $(NF-1)}')

    }

    # ensure completion was detected
    [[ -n $completion ]] || return 1

    # execute completion function
    "$completion"

    # print completions to stdout
    printf '%s\n' "${COMPREPLY[@]}" | LC_ALL=C sort
}

# load bash-completion helper functions
source /home/aj/git/convox/convox-completion/convox

# array of words in command line
COMP_WORDS=(convox p)

# index of the word containing cursor position
COMP_CWORD=1

# command line
COMP_LINE='convox p'

# index of cursor position
COMP_POINT=${#COMP_LINE}

# execute completion function
# FYI: _xfunc is a helper function for loading and calling functions from
#      dynamically loaded completion files that may not have been sourced yet
#_xfunc convox _convox
#__convox_complete convox _convox

# to print completions to stdout
printf '%s\n' "${COMPREPLY[@]}"

test_root_completions() {
    expected="api
apps
build
builds
certs
deploy
doctor
env
exec
h
help
help
init
install
instances
login
logs
proxy
ps
rack
racks
registries
releases
resources
run
scale
services
ssl
start
switch
uninstall
update"
    all_comps=$(get_completions 'convox ')
    if [[ $all_comps == $expected ]]; then
        echo "it worked"
    else
        echo "it didn't work"
    fi
}

test_root_completions
