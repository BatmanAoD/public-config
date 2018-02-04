#!/bin/bash
# The shebang is just to ensure that Vim knows how to highlight this file.

alias expand='echo '
alias expand='xargs '

# Allow aliases with `sudo` and `xargs`
alias sudo='sudo '
alias xargs='xargs '

if [[ "$(uname)" = "Linux" ]]
then
   alias ls="ls -F --color --dereference-command-line-symlink-to-dir"
else
   alias ls="ls -F"
fi
alias ll="ls -lA"
alias cp="cp -i"
alias cpall="cp -av"
alias mv="mv -i"
# stderred doesn't work with 'rm' for some reason. Unfortunately, this alias
# doesn't fix the behavior for uses of 'rm' in scripts.
alias mkdir="mkdir -p"
alias rm="tmpnostderred rm"
alias lsplain="ls --format=single-column --indicator-style=none --color=none"
alias lf="ls -d "
alias ldir="ls -d "
alias chomd=chmod
alias follow="clear && tail -F -n +0"

# Find a script to generically open files
if $WINDOWS; then
    # TODO: handle multiple files, other args?
    win-open () {
        start "$(cygpath -w "$1")"
    }
    alias open=win-open
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

# This is more useful than >&2 when using stderred. (use with | )
alias toerr="perl -n -e 'print STDERR \$_; \$lines = \$.;' -e 'END { exit \$lines }'"

# because sometimes stderred causes bad behavior
alias nostderred='export LD_PRELOAD= ; '
alias norederr='nostderred '
alias tmpnostderred='LD_PRELOAD= '
alias tmpnorederr='tmpnostderred '

# import/export history (i.e., write history so far, re-read history file)
alias savehist=histout
alias histsave=histout
alias loadhist=histin
alias histload=histin

# Overridden by Avago config to have better network awareness
alias absp=abspath

# because I do this all the time
alias ignore='grep -v'
alias ig=ignore

alias quickpgrep='pgrep -fl'
alias qpgrep=quickpgrep
alias qpg=qpgrep

alias ff=findfiles
# default is stupid
alias find='find -H'

alias psearch=pathsearch

alias cd=go
#alias cd='pushd $PWD &> /dev/null; cd'

alias lstmp="ls $TMP"
alias ltmp="ls $TMP"
alias rmtmp="test -d $TMP && rm -Rf $TMP/*"

alias listify=" tr ' ' '\n' "
alias unlistify=" tr '\n' ' ' "
alias blockify=unlistify
alias unblockify=listify

# The ongoing quest to standardize my quitting procedure for all applications,
# allowing me to take advantage of all this muscle memory...
alias quit="exit"
alias :q="exit"
alias :bd="exit"
alias QQQ="exit"

# avoid accidentally messing up shell with control characters when using
# cat on binary files
alias cat='cat -v'
# this function is...less useful than I'd hoped, because '-A' usually just 
# looks silly.
# alias cat=qcat

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

alias ehco=echo

alias goog=google
alias gsearch=google

alias edit='$NEWWINDOW_EDIT_CMD'
alias ed=edit
alias e=edit
alias v=vim
alias subed='sublime_text'
# gview won't work remotely without xauth
alias gv='gview '
#overwite after setting up CB funcs
alias qed=ednew

alias gmake="gmake -s"
# Use '-U' because otherwise this causes unacceptable slowdown in dirs with
# lots of entries.
alias lsd='echo "DIR:" && pwd && echo "*    *    *    *" && ls -U'
alias cls='clear; clear; clear; lsd'
alias cwd='lsd'
alias home="go ~"
# 'sleep' is to prevent error from being printed after the cmd prompt, which
# makes it look like the command is hanging.
alias back="popd > /dev/null 2> >(toerr) && lsd || sleep 0.2"

# lock screen
alias lockscreen='xlock -mode random'
alias locscr=lockscreen
alias lockscr=lockscreen
alias lscr=lockscreen

# because I always forget about repos
alias yum='yum --enablerepo="*"'
alias sinstall='sudo yum --enablerepo="*" install'
alias yuminst=sinstall
alias yuminstall=sinstall
alias sudoinstall=sinstall

# editing without tabs -- OLD; current vimrc solution is better
# alias ednotabs='edit -S <(echo -e "call Nousetabs()\n")'
# alias ednt=ednotabs
# alias batchnotabs='$EDITOR -S <(echo -e "call Nousetabs()\n")'

# edit vimrc
alias edvi="edit ~/.vimrc*"

# crontab uses VISUAL, but this only works in batch mode.
alias edcron="VISUAL=\"$EDITOR\" crontab -e"

# convenient way to add/edit bash stuff
# Note that VISUAL is by default set up to use the -f option,
# so we don't need to use EDITOR
alias edrc="$EDITOR ~/.bash_rcbase && reload"
alias edal="$EDITOR ~/.bash_aliases* && reload"
alias edfx="$EDITOR ~/.bash_functions* && reload"
alias edpriv="$EDITOR ~/private-config/bash* && reload"

# configure i3 setup
# TODO: when I switch to generating this, edit source instead
alias edi3='edit ~/.i3/config'

# Other config-related aliases
if [[ -n "$CONFIG_DIR" ]]; then
    alias gocfg="go $CONFIG_DIR/.git"
    alias pullcfg="(cd $CONFIG_DIR; git pull)"
    alias pushcfg="(cd $CONFIG_DIR; git commit -a; git push)"
fi
# TODO consider doing the same for private config

# generic i3 commands
alias qi=i3-msg

# create arbitrary workspace
alias qwks='i3-msg workspace'
alias iwks=qwks
# move to arbitrary workspace
alias ic='qi workspace'
alias qc='ic'

# Requires google docs commandline tools to be installed
alias gdoc='google docs edit --editor="$EDITOR"'

# some funcs and aliases aren't immediately loaded. Define these.
# (Every function that defines new functions should be added to the
# functions_with_defs variable; these should be separated with semicolons.)
alias defallfuncs='eval ${functions_with_defs}'

# add $TMP/ex to path, which is where temporary executables are
# ongoingly
alias tmppath="export PATH=\$TMP/ex:\$PATH"
# one-time only
alias tmpex="PATH=\$TMP/ex:\$PATH "

# make some aliases for "doge"-style git.
function dogegit() {
    alias much=git
    alias many=git
    alias so=git
    alias very=git
    alias such=git
    alias wow='git status'
    # These are (currently) BC-specific aliases.
    alias amaze='git lg'
    alias excite='git wfb'
}

# If 'ack-grep' is installed, invoke it using `ack`.
type ack &>/dev/null
if [[ $? -ne 0 ]]; then
    type ack-grep &>/dev/null
    if [[ $? -eq 0 ]]; then
        alias ack=ack-grep
    fi
fi

# If we're using Bash on Windows, always print Unix-style path separators in ripgrep.
if $WINDOWS; then
    # TODO: Why is `//` required instead of `/`? See
    # https://github.com/BurntSushi/ripgrep/issues/275
    alias rg='rg --path-separator //'
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
