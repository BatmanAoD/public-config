# echo aliases
alias expand='echo '

if [[ "$(uname)" = "Linux" ]]
then
   alias ls="ls -F --color"
else
   alias ls="ls -F"
fi
alias ll="ls -lA"
alias cp="cp -i"
alias cpall="cp -av"
alias mv="mv -i"
alias mkdir="mkdir -p"
alias lsplain="ls --format=single-column --indicator-style=none --color=none"
alias lf="ls -d "
alias ldir="ls -d "
alias chomd=chmod
alias follow="clear && tail -F -n +0"

# the "-p" option for `history` is a bit like an "eval" for ! events.
alias histeval='history -p'
alias heval=histeval

# Overridden by Avago config to have better network awareness
alias absp=abspath

# because I do this all the time
alias ignore='grep -v'
alias ig=ignore

# normal pgrep is not that great
alias qpgrep=quickpgrep
alias qpg=qpgrep

alias ff=findfiles
# default is stupid
alias find='find -H'

alias psearch=pathsearch

alias cd='pushd $PWD &> /dev/null; cd'

alias lstmp="ls $TMP"
alias ltmp="ls $TMP"
alias rmtmp="test -d $TMP && rm -Rf $TMP/*"

alias listify=" tr ' ' '\n' "
alias unlistify=" tr '\n' ' ' "
alias blockify=unlistify
alias unblockify=listify

alias quit="exit"
alias :q="exit"
alias QQQ="exit"

# avoid accidentally messing up shell with control characters when using
# cat on binary files
alias cat="cat -v"
# TODO: write a function wrapper around 'cat' that checks whether a file is
# binary and, if so, uses -A (which is more comprehensive than -v); otherwise,
# don't add any options

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

alias edit='$VISUAL'
alias ed=edit
alias e=edit
alias v=vim
alias editall="xargs $VISUAL"
alias subed='sublime_text'
# gview won't work remotely without xauth
alias gv='gview '
#overwite after setting up CB funcs
alias qed=ednew

alias gmake="gmake -s"
alias lsd='echo "DIR:"; pwd; echo "*    *    *    *"; ls -U '
alias cls='clear; clear; clear; lsd'
alias cwd='lsd'
alias reload='unalias -a ; source ~/.bashrc '
alias home="go ~"
alias back='eval go $(dirs +1); popd -n &> /dev/null ; popd -n &> /dev/null'

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

# because crontab uses $VISUAL for some reason...which doesn't work.
alias edcron="VISUAL=\"$EDITOR\" crontab -e"

# convenient way to add/edit bash stuff
alias edrc="$EDITOR ~/.bashrc && reload"
alias edal="$EDITOR ~/.bash_aliases* && reload"
alias edfx="$EDITOR ~/.bash_functions* && reload"

# configure i3 setup
# TODO: when I switch to generating this, edit source instead
alias edi3='edit ~/.i3/config'

# arbitrary workspace
alias qwks='i3-msg workspace'
alias iwks=qwks

# generic i3 commands
alias qi=i3-msg

# TODO this could be more generic, though it's not technically Avago-specific
alias vrestart='vncserver -geometry 1280x1024   -pixelformat  RGB888'
alias swin='~/bin/start_synergy'
# how do I disown this proc?
alias svnc='~/bin/start_vnc &'
# because x0vncserver conflicts with synergy...
# but for now I'm not using x0vncserver
alias spause='pkill synergy; echo "press ENTER to resume Synergy."; read cont; swin'
# while using VNC, turn monitors on/off
alias xon='xset dpms force on'
alias xoff='xset dpms force off'

