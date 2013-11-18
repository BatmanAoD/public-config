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
    bind Space:magic-space

    # use Vim as pager.
    # export PAGER='view -S ~/.vimpager'
    if [[ -e ${HOME}/bin/vimpager ]]; then
        PAGER=$(readlink -f ${HOME}/bin/vimpager)
    else
        PAGER="less -n -Q"
    fi
    export PAGER

    # create a personal-use tmp dir
    # for now, Avago is the only place with an NFS setup that
    # makes this useful.
    export TMP="${TMP}/tmp/personal_tmp"
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
    if [ "$DISPLAY" != "" ]; then
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

    # Fix backspace problems in vi when remotely logged into HP-UX
    if test "$(uname)x" = "HP-UXx"; then
        stty erase "^?"
    fi

    # Set the prompt
    PS1='\h|\W> '    
    # Make it cyan
    # appears to let it get overwritten....
    PS1="\[\e[0;36m\]${PS1}\[\e[m\]"
    # Export it
    export PS1

    # Uncomment the following line to share history in all windows.
    # PROMPT_COMMAND="history -a;history -c;history -r"

    # Set the DISPLAY variable
    if [[ -z ${DISPLAY} ]]; then
        TERMINAL=$(last -n 1 -a ${LOGNAME} 2> /dev/null | head -n 1)
        NON_TERMINAL=$(last -n 1 -R ${LOGNAME} 2> /dev/null | head -n 1)
        if [[ "${TERMINAL}" != "${NON_TERMINAL} " ]]
        then
            export TERMINAL=$(echo ${TERMINAL} | awk '{print $NF}')
            export DISPLAY=${TERMINAL}:0.0
        else
            unset TERMINAL
            unset DISPLAY
        fi
        unset NON_TERMINAL
    fi

    # unset LANG so that some command may run faster
    # Reference: /etc/rc.config.d/LANG
    unset LANG

     # Make less display colors and not clear the screen
    export LESS="-XR"

    # Load completion function
    if [ ${BASH_VERSINFO[0]} -eq 2 ] && [[ ${BASH_VERSINFO[1]} > 04 ]] || [ ${BASH_VERSINFO[0]} -gt 2 ]; then
         if [ -r /etc/bash_completion ]; then
              . /etc/bash_completion
         fi
    fi

    # Load aliases
    if [ -f ${HOME}/.bash_aliases.personal ]; then
        . ${HOME}/.bash_aliases.personal
    fi

    # Load functions
    if [[ -f ${HOME}/.bash_functions.personal ]]
    then
        . ${HOME}/.bash_functions.personal
    fi

    # Avago-specific
    if dnsdomainname | grep -q avago; then
        . ${HOME}/.bash_avago
    fi

    # Print a message
    echo "<- bashrc"
