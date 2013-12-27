################################################################################
# File:             .bashrc
# Description:      Bash shell environment file; should be target of symlink
#                       ~/.bashrc
################################################################################

    # TODO: figure out a way to add auto-updating version info (using git?)

    # Set the default umask
    umask 002

    # Only execute if interactive
    test "${-#*i}" != "$-" || return 0

    # Print a message
    # TODO include version info?
    echo "-> bashrc"

    # Do profile if asked.  Used when invoking a shell via remsh, since
    # this isnt a bona fide login
    test "${DO_PROFILE}" != "" && . ${HOME}/.bash_profile

#    # Set up CDPATH; this is interesting, but probably dangerous
#    export CDPATH=".:~"

    # Set information about the history files
    export histchars='!^'  # Get comments saved in history
    HISTDIR=${HOME}/.hist
    HISTFILE_BASH="${HISTDIR}/bash/hist_xxxxxx"
    export CBHISTFILE="${HISTDIR}/cb/hist_xxxxxx"
    export IEDHISTFILE="${HISTDIR}/ied/hist_xxxxxx"
    export HISTFILE="${HISTFILE_BASH}"
    export HISTSIZE=65536
    export HISTFILESIZE=${HISTSIZE}
    HISTCONTROL=ignoredups:erasedups
    shopt -s histappend
    shopt -s checkhash
    if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
        shopt -s globstar
        shopt -s autocd
    fi
    # bind Space:magic-space

    # use Vim as pager.
    # export PAGER='view -S ~/.vimpager'
    if [[ -e ${HOME}/bin/vimpager ]]; then
        PAGER=$(readlink -f ${HOME}/bin/vimpager)
    else
        PAGER="less -n -Q"
    fi
    export PAGER

    # I'd expect there to be a way to do this in my gitconfig, but...maybe not?
    export GIT_ASKPASS=

    # create a personal-use tmp dir
    # for now, Avago is the only place with an NFS setup that
    # makes this useful.
    export TMP="/tmp/personal_tmp"
    mkdir -p $TMP

    # Create the needed history directories
    if ! test -d $(dirname ${CBHISTFILE}); then
         mkdir -p $(dirname ${CBHISTFILE})
    fi
    if ! test -d $(dirname ${IEDHISTFILE}); then
         mkdir -p $(dirname ${IEDHISTFILE})
    fi
    if ! test -d $(dirname ${HISTFILE}); then
         mkdir -p $(dirname ${HISTFILE})
    fi

    # Set up options
#    set -u                  # attempting to expand unset variables is an error
    set -o monitor             # enable job control
    set -o vi                    # vi command-line editing
    if [[ -n $DISPLAY ]]; then
        export VISUAL="gvim"
        export EDITOR="gvim -f"
    else
        export VISUAL=vim
        export EDITOR="vim"
    fi
    export PEDITOR=$EDITOR
    export EDOVER=$VISUAL
    set -o ignoreeof          # do not let CNTL-D exit the shell
    shopt -s checkwinsize    # Reset LINES and COLUMNS after each command

    bind Space:magic-space # ...for some reason this can't come earlier...?

    # Set the prompt
    PS1='\h|\W> '    
    # Make it cyan
    PS1="\[\e[0;36m\]${PS1}\[\e[m\]"
    # Export it
    export PS1

    # Uncomment the following line to share history in all windows.
    # PROMPT_COMMAND="history -a;history -c;history -r"

    # unset LANG so that some commands may run faster
    # .....?
    # unset LANG

    # Make less display colors and not clear the screen
    # ....not reeeeeally sure what this does...
    # export LESS="-XR"

    # Load completion function
    if [ -r /etc/bash_completion ]; then
         . /etc/bash_completion
    fi

    # Load aliases
    if [ -r ${HOME}/.bash_aliases.personal ]; then
        . ${HOME}/.bash_aliases.personal
    fi

    # Load functions
    if [[ -r ${HOME}/.bash_functions.personal ]]
    then
        . ${HOME}/.bash_functions.personal
    fi

    # Avago-specific
    if [[ -r ${HOME}/.bash_avago ]]; then
        . ${HOME}/.bash_avago
    fi

    # Print a message
    echo "<- bashrc"
