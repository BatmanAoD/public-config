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

    # Set a path to my personal machine.
    # TODO make this...better.
    # This could probably be done by creating a list of "known" machines, 
    # ordered by some kind of "priority", and then checking each to see if
    # it's accessible on the path, then stopping when I find one.
    # Priority probably doesn't matter, since I don't think there will be
    # cases when I could potentially find multiple machines I "know".
    if [[ -d /net/erard ]]; then
        PERSONALMACHINEPATH=/net/erard
    else
        # use whatever local machine I'm on
        PERSONALMACHINEPATH=
    fi

    stderred_path=${PERSONALMACHINEPATH}/usr/lib/stderred

    if [[ -d ${stderred_path}  && \
          -r ${stderred_path}/build/libstderred.so ]]; then
        export LD_PRELOAD="${stderred_path}/build/libstderred.so${LD_PRELOAD:+:$LD_PRELOAD}"
    else
        echo "stderred not installed!" >&2
        echo "Get stderred from https://github.com/sickill/stderred" >&2
    fi

    # Do profile if asked.  Used when invoking a shell via remsh, since
    # this isnt a bona fide login
    test "${DO_PROFILE}" != "" && . ${HOME}/.bash_profile

#    # Set up CDPATH; this is interesting, but probably dangerous
#    export CDPATH=".:~"

    # Set information about the history files
    export histchars='!^'  # Get comments saved in history
    HISTDIR=${HOME}/.hist
    #TODO figure out what the heck is going on here.
    # Also, remove the reference to CB.
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
    # Disabled for now because it's actually really annoying.
    # TODO: if I can figure out how to get VIM to do colors correctly, then
    # I can just implement it myself without all the annoyances built in
    # by whoever programmed this thing.
    # export PAGER='view -S ~/.vimpager'
    # TODO: make a list of things that bug me about this thing, because I can't
    # actually remember why I stopped using it.
    #   * numbers not on by default, even though 'set nu' is in vimrc
    if [[ -e ${HOME}/bin/vimpager ]]; then
        PAGER=$(readlink -f ${HOME}/bin/vimpager)
    else
      PAGER="less -n -Q"
    fi
    export PAGER

    # I'd expect there to be a way to do this in my gitconfig, but...maybe not?
    export GIT_ASKPASS=

    # create a personal-use tmp dir
    export TMP="${PERSONALMACHINEPATH}/tmp/personal_tmp"
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
    # set -u                # attempting to expand unset variables is an error
    set -o monitor          # enable job control
    set -o vi               # vi command-line editing

    # If one of EDITOR or VISUAL is set to a non-default value, use that value
    # to set the value of the other variable as well.
    DEFAULT_TERMINAL_EDITOR=vim
    DEFAULT_VISUAL_EDITOR="gvim -f"
    DEFAULT_EDITOR_PATTERN="^(vi|$DEFAULT_TERMINAL_EDITOR|$DEFAULT_VISUAL_EDITOR)?\$"
    if [[ -n $VISUAL && $EDITOR =~ $DEFAULT_EDITOR_PATTERN ]]; then
        echo "Using non-default value for both EDITOR and VISUAL: '$VISUAL'"
        EDITOR=$VISUAL
    elif [[ ! $EDITOR =~ $DEFAULT_EDITOR_PATTERN && -z $VISUAL ]]; then
        echo "Using non-default value for both EDITOR and VISUAL: '$EDITOR'"
        VISUAL=$EDITOR
    elif [[ -n $VISUAL ]]; then
        echo "Using non-default values for EDITOR and VISUAL:"
        echo "EDITOR='$EDITOR'"
        echo "VISUAL='$VISUAL'"
    fi
    # If VISUAL is still not set, assign my preferred values to both EDITOR and
    # VISUAL.
    if [[ -z $VISUAL ]]; then
        if [[ -n $DISPLAY ]]; then
            # always run in foreground unless '&' is used; useful with bash shortcut
            # to edit command in editor
            # TODO: make this work with cscope??
            export VISUAL="gvim -f"
            export EDITOR="gvim -f"
        else
            export VISUAL=vim
            export EDITOR=vim
        fi
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
    if [[ -r /etc/bash_completion ]]; then
         . /etc/bash_completion
    fi

    # Load aliases
    if [[ -f ${HOME}/.bash_aliases ]]; then
        . ${HOME}/.bash_aliases
    fi

    # Load functions
    if [[ -f ${HOME}/.bash_functions ]]
    then
        . ${HOME}/.bash_functions
    fi

    # Avago-specific
    if [[ -r ${HOME}/.bash_avago ]]; then
        . ${HOME}/.bash_avago
    fi

    # Print a message
    echo "<- bashrc"
