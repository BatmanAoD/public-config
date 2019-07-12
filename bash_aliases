#!/bin/bash
# The shebang is just to ensure that Vim knows how to highlight this file.

alias expand='echo '

# Allow aliases with `sudo` and `xargs`
alias sudo='sudo '
alias xargs='xargs '

# GNU utilities are more feature-rich.
if [[ -n "$CONFIG_DIR" ]]; then
    while read util; do
        if hash g$util 2>/dev/null; then
            alias ${util}=g$util;
        fi
    done < "$CONFIG_DIR/coreutils_list"
fi

if ls --version 2>/dev/null | grep -w GNU -q ; then
   alias ls="ls -F --color --dereference-command-line-symlink-to-dir"
   alias lsplain="ls --format=single-column --indicator-style=none --color=none"
else
   alias ls="ls -F"
   alias lsplain="\ls | column  -c"
fi
alias ll="ls -lA"
alias cp="cp -i"
alias cpall="cp -av"
alias mv="mv -i"
alias mkdir="mkdir -p"
alias lf="ls -d "
alias ldir="ls -d "
alias chomd=chmod
alias follow="clear && tail -F -n +0"

# because sometimes preloaded libraries (e.g. stderred) causes bad behavior
if ! $MAC_OSX; then
    alias nopreload='LD_PRELOAD= '
else
    alias nopreload='DYLD_INSERT_LIBRARIES= '
fi
# stderred doesn't work with 'rm' for some reason.
alias rm="nopreload rm"

# Find a script to generically open files
if $WINDOWS; then
    # TODO: handle multiple files, other args?
    win-open () {
        start "$(cygpath -w "$1")"
    }
    alias open=win-open
elif $MAC_OSX; then
    # Mac OS X already has an 'open' command that behaves appropriately.
    :
# On *NIX, xdg-open is the most generic and modern
elif hash xdg-open 2>/dev/null; then
    alias open=xdg-open
# Gnome-specific:
# gvfs-open might be replacing gnome-open...?
elif hash gvfs-open 2>/dev/null; then
    alias open=gvfs-open
elif hash gnome-open 2>/dev/null; then
    alias open=gnome-open
# KDE-specific:
elif hash kde-open 2>/dev/null; then
    alias open=kde-open
# TODO warn if an open utility can't be found?
fi

# the "-p" option for `history` is a bit like an "eval" for ! events.
alias histeval='history -p'
alias heval=histeval

if 
# This is more useful than >&2 when using stderred. (use with | )
alias toerr="perl -n -e 'print STDERR \$_; \$lines = \$.;' -e 'END { exit \$lines }'"

# Overridden by Avago config to have better network awareness
alias absp=abspath

# default is stupid
alias find='find -H'

alias cd=godir

# The ongoing quest to standardize my quitting procedure for all applications,
# allowing me to take advantage of all this muscle memory...
alias :q="exit"

alias lesspage="export PAGER='less -n -Q' "
alias tmplesspage="PAGER='less -n -Q' "
alias more="$PAGER"
alias moer="$PAGER"
alias mroe="$PAGER"
alias mreo="$PAGER"
alias meor="$PAGER"
alias mero="$PAGER"
alias mor="$PAGER"
alias mo="$PAGER"
alias less="$PAGER"
alias p="$PAGER"

alias edit='$NEWWINDOW_EDIT_CMD'
alias ed=edit
alias e=edit

alias gmake="gmake -s"
# Use '-U' because otherwise this causes unacceptable slowdown in dirs with
# lots of entries.
alias lsd='echo "DIR:" && pwd && echo "*    *    *    *" && ls -U'
alias cls='clear; clear; clear; lsd'
alias home="godir ~"
alias back="popd >/dev/null && here_info"

# edit all vimrc-related files
alias edvi="edit ~/.vimrc*"

# convenient way to add/edit bash stuff
# Note that VISUAL is by default set up to use the -f option,
# so we don't need to use EDITOR
alias edrc="$VISUAL ~/.bash_rcbase && reload"
alias edal="$VISUAL ~/.bash_aliases* && reload"
alias edfx="$VISUAL ~/.bash_functions* && reload"
alias edpriv="$VISUAL ~/private-config/bash* && reload"

# Other config-related aliases
if [[ -n "$CONFIG_DIR" ]]; then
    alias gocfg="godir $CONFIG_DIR/.git"
    alias pullcfg="(cd $CONFIG_DIR; git pull)"
    alias pushcfg="(cd $CONFIG_DIR; git commit -a; git push)"
fi
# TODO consider doing the same for private config

# TODO: How to check if running i3?
# ...or, is there a better way to generically interact with a window manager?
if false; then
    # generic i3 commands
    alias qi=i3-msg

    # create arbitrary workspace
    alias qwks='i3-msg workspace'
    alias iwks=qwks
    # move to arbitrary workspace
    alias ic='qi workspace'
    alias qc='ic'
fi

# some funcs and aliases aren't immediately loaded. Define these.
# (Every function that defines new functions should be added to the
# functions_with_defs variable; these should be separated with semicolons.)
alias defallfuncs='eval ${functions_with_defs}'

# make some aliases for "doge"-style git.
function dogegit() {
    alias much=git
    alias many=git
    alias so=git
    alias very=git
    alias such=git
    alias wow='git status'
    # From my gitconfig
    alias amaze='git lg'
    alias excite='git lg2'
}

# If 'ack-grep' is installed, invoke it using `ack`.
type ack &>/dev/null
if [[ $? -ne 0 ]]; then
    type ack-grep &>/dev/null
    if [[ $? -eq 0 ]]; then
        alias ack=ack-grep
    fi
fi

# "recursive search" - pick the best available grep tool
type rg &>/dev/null
if [[ $? -eq 0 ]]; then
    alias rs=rg
else
    type ack &>/dev/null
    if [[ $? -eq 0 ]]; then
        alias rs=ack
    fi
fi

# Find leftover git conflict markers
alias findconflicts="rs '^<<<<<<|^=======$|^>>>>>>>'"

type bat &>/dev/null
if [[ $? -eq 0 ]]; then
    alias cat='bat --theme="DarkNeon"'
    # OneHalfLight and OneHalfDark are the only readable themes on Git-Bash on
    # Windows.
    # TODO figure out a way to pick the theme intelligently...
    # alias mdcat="bat --theme=OneHalfLight --plain"
    alias mdcat="bat --theme=DarkNeon --plain"
else
    # avoid accidentally messing up shell with control characters when using
    # cat on binary files
    alias cat='cat -v'
    alias mdcat=\cat
    # this function is...less useful than I'd hoped, because '-A' usually just
    # looks silly.
    # alias cat=qcat
fi

alias save_func=save_function
alias savefunction=save_function
alias savefunc=save_function
alias savfunc=save_function
alias sfunc=save_function

alias savealias=save_alias
alias savalias=save_alias
alias salias=save_alias
# Aliases added by the "save_alias" function
