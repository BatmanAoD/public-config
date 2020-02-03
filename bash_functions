#!/bin/bash
# The shebang is just to ensure that Vim knows how to highlight this file.

# generic Bash functions

set_title() {
    if [[ -n $1 ]]; then
        newtitle=$1
    else
        newtitle="$(curr_proj)"
    fi
    echo -en "\e]0;${newtitle}\007"
}

here_info() {
    lsd
    set_proj    # TODO: make switching projects more intentional?
    set_title
}

godir() { 
    if [ "$1" != "" ]
    then
        pushd "$1" > /dev/null
        status=$?
        if [[ $status -ne 0 ]]; then
            return $status
        fi
        here_info
    else
        echo "godir: no path given!" >&2
    fi
}

# TODO `*_proj` functions should probably be in .bash_workspaces
set_proj() {
    # TODO: This could be more feature-rich, e.g. handling other VCS systems
    # TODO: Use `projname` more widely?
    git_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ $? -eq 0 ]]; then
        projname="$(basename "$git_dir")"
    else
        projname="$(basename "$(tildepath "$PWD")")"
    fi
}

curr_proj() {
    if [[ -z "$projname" ]]; then
        set_proj
    fi
    echo $projname
}

up() {
    DOWN_DIR=$PWD
    local numdirs
    if [[ -z $1 ]]; then
        godir ../
    else
        if [[ "$1" -eq "$1" ]] 2>/dev/null; then
            numdirs=$1
        else
            numdirs=${#1}
        fi
        pdir=''
        for (( i=1; i<=$numdirs; i++)); do
            pdir="../$pdir"
        done
        godir $pdir
    fi
    UP_DIR=$PWD
}

down() {
    if [[ $UP_DIR != $PWD ]]; then
        echo "Must be in the last directory accessed by 'up'!" >&2
        return 1
    fi
    cd $DOWN_DIR
}

# If the path is under a home dir, replace with the correct ~usrname
tildepath() {
    if [[ -n "$1" ]]; then
        targ="$1"
    else
        targ="$PWD"
    fi
    # To do this, determine who owns it; presumably, if it's under a
    # homedir, that user should own it.
    # NOTE: this will cause an error on nonexistent files.
    # TODO: Will this work with users that have spaces in their names?
    tmp_usr="$(ls -l -d "$targ" | awk '{print $3}')"
    # Figure out what "readlink" outputs for that user's home dir.
    home_parent="$(eval readlink -f ~"${tmp_usr}")"
    # Do the replacement if possible. Otherwise, assume it's not under
    # a home dir.
    echo "${targ/#${home_parent}/~${tmp_usr}}"
}

# get an absolute path
abspath() {
    if [[ -n $1 ]]; then
        targ=$1
    else
        targ=$PWD
    fi
    # TODO: This doesn't work with BSD's `readlink`...if nothing else, I should
    # at least add `brew install coreutils` to the tools section of the
    # `install` script.
    tmp_path=$(readlink -f $targ)
    # If on Windows, get a Windows path
    if $CYGWIN; then
        tmp_path="$(cygpath -w "$tmp_path")"
    elif $WSL; then
        tmp_path="$(wslpath -wa "$tmp_path")"
    # Otherwise, try to substitute out `~<usr>`
    else
        tmp_path="$(tildepath "$tmp_path")"
    fi
    echo $tmp_path
}

swaptwo() {
    local tmpfile
    tmpfile=$(mktemp $TMP/fswapXXXXXXXXX)
    trap "rm -f $tmpfile; trap - RETURN" RETURN
    #TODO for safety, check permissions first
    mv -f $1 $tmpfile
    mv -f $2 $1
    mv -f $tmpfile $1
}

fswap() {
    local src dst files
    src=
    dst=
    files=
    while [[ $# -ne 0 ]]; do
        case $1 in
            --from|-f|--source|-s) src=$2; shift;;
            --to|-t|--dest*|-d) dst=$2; shift;;
            *) files="${files} $1";;
        esac
        shift
    done
    if [[ -z $dst || -z $src ]]; then
        swaptwo $files
    else
        if [[ -n $files ]]; then
            files=$(\ls $src)
        fi
        for fname in $files; do
            swaptwo $src/$fname $dst/$fname
        done
    fi
}

if $CYGWIN; then
    start_xwin ()
    {
        if ! pgrep XWin > /dev/null; then
            startxwin &> $(mktemp /tmp/xwin_stdout_XXXXXX)
        fi
        if pgrep XWin > /dev/null; then # Check for success
            export DISPLAY=localhost:0
        fi
    }

    # adapted from http://stackoverflow.com/a/12661288/1858225
    # TODO: Is this still necessary?
    gvim () 
    { 
        opt='';
        if [ `expr "$*" : '.*tex\>'` -gt 0 ]; then
            opt='--servername LATEX ';
        fi;
        # TODO add support for "--nofork" as synonym for "-f"
        if [ `expr "$*" : '.*-f\>'` -gt 0 ]  ; then
            forknum=0
        else
            forknum=2
        fi
        cyg-wrapper.sh "C:/Progra~2/Vim/vim74/gvim.exe" --binary-opt=-c,--cmd,-T,-t,--servername,--remote-send,--remote-expr --cyg-verbose --fork=$forknum $opt "$@"
    }
fi

# edit a bash function in the current session
# TODO: apparently this doesn't work on home machine...why?
# TODO: on Cygwin, this apparently doesn't catch the case where the function
# is from an RC file
edfunc () {
    mkdir -p $TMP/shellfuncs;
    # Use proc num to decrease (but not elminate) the chance of name
    # collision when funcs from different shell sessions edit different
    # functions with the same name.
    tmp_def_file=$TMP/shellfuncs/edfunc_$1_$$;
    # Keep the primary files around in case I end the session and want to
    # recover a function from a closed session, or in case I want to load
    # a function into a different session.
    ### trap "rm -f $tmp_def_file*; trap - RETURN" RETURN
    # Do, however, delete the other temp files (.new and .bak).
    trap "rm -f $tmp_def_file.*; trap - RETURN" RETURN
    # TODO figure out a way to deal with pre-existing $tmp_def_file.
    if [[ -e $tmp_def_file ]]; then
        echo FOUND OLD $tmp_def_file! >&2
        cat $tmp_def_file
    fi
    type $1 > $tmp_def_file
    # We could easily insert instructions as comments in the tmp file.
    # TODO use declare -f??
    if [[ $? -eq 1 ]]; then
        echo -e "$1 ()\n{\n\n}" > $tmp_def_file
    elif grep -q "$1 is a function" $tmp_def_file; then
        # If function is from an rc file and hasn't already been modified,
        # edit the original rc file(s) and reload.
        diff <((unset -f $1 ; reload >/dev/null; defallfuncs; \
            type $1 2>/dev/null)) ${tmp_def_file} &>/dev/null
        if [[ $? -eq 0 ]]; then
            # mv so that the "rm" trap will delete unnecessary file
            mv $tmp_def_file ${tmp_def_file}.type
            # Need to explicitly tell grep to print filename, since some
            # setups might only have one .*functions* file.
            edline $(grep -H -n -P "$1\s*\(\)" ~/.*functions* |
                awk -F  ":" '{print $2, $1}')
            reload
            return
        else
            tail -n +2 $tmp_def_file >> ${tmp_def_file}.new
            mv -f ${tmp_def_file}{.new,}
        fi
    else
        # TODO: handle aliases of functions?
        echo "ERROR: $1 is not a function!"
        return
    fi
    cp $tmp_def_file{,.bak}
    edit $tmp_def_file
    diff $tmp_def_file{,.bak} >/dev/null 2>&1 
    if [[ $? -eq 1 ]]; then
        . $tmp_def_file
    fi
}

edvar() {
    eval echo \$$1 > $TMP/editvar_$1
    edit $TMP/editvar_$1
    eval export $1=\"`cat $TMP/editvar_$1`\"
    rm $TMP/editvar_$1
}

# check if file $1 contains $2
# TODO use 'comm' instead.
contains() {
    if [[ $(diff $1 $2 | grep -P "^<") == "" ]]; then
        echo $1 contains $2
        return 0
    else
        return 1
    fi;
}

# print a large notification when command completes
loud() {
    eval "$@" ; bigresult $?
}

mkc() { mkdir "$@" ; cd "$@";}

# Easy extract
# I think this is from http://stackoverflow.com/a/27433887/1858225
extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.tar.xz)    tar xJf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
} 

# import/export history (i.e., write history so far, re-read history file)
histout () 
{ 
    if [[ -n $1 ]]; then
        ( HISTFILE=$1;
        history -a );
    else
        history -a;
    fi
}

histin () 
{ 
    # First, save current history in the primary history file.
    histout
    local ORIG_HISTFILE
    if [[ -n $1 ]]; then
        ORIG_HISTFILE=$HISTFILE
        HISTFILE=$1;
    fi
    history -r
    if [[ -n $ORIG_HISTFILE ]]; then
        export HISTFILE=$ORIG_HISTFILE
    fi
}

# Search-and-replace in multiple files
global_repl ()
{
    if [[ "$1" == "-d" ]]; then
        dirname="$2"
        shift 2
    else
        dirname="."
    fi
    if [[ $# -ne 2 ]]; then
        echo "USAGE: global_repl [-d <dir>] <pattern> <replacement>" >&2
        return
    fi
    rmbak_gr "$dirname"
    pattern="$1"
    replacement="$2"
    # rs should be aliased to ack or rg
    rs -l "$pattern" "$dirname" | xargs perl -pi.bak_gr -E "s/$pattern/$replacement/g"
}
alias gr=global_repl
alias rsub=global_repl

# Restore global_repl backups
gr_restore () {
    topdir='.'
    if [[ $# -eq 1 ]]; then
        topdir="$1"
    fi
    for i in $(find "$topdir" -name '*.bak_gr'); do
        mv -f "$i" "${i%.bak_gr}"
    done
}

# Remove backup files created by global_repl
rmbak_gr () {
    topdir='.'
    if [[ $# -eq 1 ]]; then
        topdir="$1"
    fi
    for i in $(find "$topdir" -name '*.bak_gr'); do
        rm "$i"
    done
}

# 'echo' with simple 'tput' magic
say() {
    declare -A tput_sanity_map
    tput_sanity_map[black]="setaf 0"
    tput_sanity_map[red]="setaf 1"
    tput_sanity_map[green]="setaf 2"
    tput_sanity_map[yellow]="setaf 3"
    tput_sanity_map[blue]="setaf 4"
    tput_sanity_map[magenta]="setaf 5"
    tput_sanity_map[cyan]="setaf 6"
    tput_sanity_map[white]="setaf 7"
    tput_sanity_map[bold]=bold
    tput_sanity_map[dim]=dim
    tput_sanity_map[uline]=smul
    echo_opts=
    if [[ $# -eq 0 ]]; then
        echo 'USAGE: say [black|red|green...|bold|dim|uline...] "string"' >&2
        return
    fi
    if [[ $1 == "-h" || $1 == "--help" ]]; then
        echo "Options are:"
        for i in "${!tput_sanity_map[@]}"; do
            echo "$(tput ${tput_sanity_map[$i]})$i$(tput sgr0)"
        done
        return
    fi
    while [[ $# -gt 1 ]]; do
        if [[ "$1" =~ ^- ]]; then
            echo_opts="$echo_opts $1"
        elif [[ -z ${tput_sanity_map[$1]} ]]; then
            break
        else
            tput ${tput_sanity_map[$1]}
        fi
        shift
    done
    # If we did *not* break out of the above loop, this will be equivalent to
    # 'echo $1'
    echo $echo_opts "$@"
    tput sgr0
}

# From https://github.com/kepkin/dev-shell-essentials/blob/master/highlight.sh
highlight() {
    declare -A fg_color_map
    fg_color_map[black]=30
    fg_color_map[red]=31
    fg_color_map[green]=32
    fg_color_map[yellow]=33
    fg_color_map[blue]=34
    fg_color_map[magenta]=35
    fg_color_map[cyan]=36
     
    fg_c=$(echo -e "\e[1;${fg_color_map[$1]}m")
    c_rs=$'\e[0m'
    sed s"/$2/$fg_c\0$c_rs/g"
}

# If sshrc is installed, use generated rc file for ssh shell.
# TODO the logic for generating sshrc should really be put in the 'install'
# script.
# TODO Also, note that sshrc supports 'sshrc.d'.
if hash sshrc 2>/dev/null; then
    ssh_sshrc() {
        SSHRC_CFG="${primary_HOME}/.sshrc"
        echo 'echo "-> sshrc"' > "${SSHRC_CFG}"
        cat $bash_addl_rcfiles >> "${SSHRC_CFG}"
        echo 'echo "<- sshrc"' >> "${SSHRC_CFG}"
        sshrc $@
    }
    # TODO sshrc doesn't work with all target platforms. It would be nice to
    # find a way to detect that and disable it for that target.
    # # Since `rsync`, etc use `ssh`, the specialized version must be an alias
    # # rather than a function to permit suppression of the non-default behavior
    # # by turning off alias-expansion.
    # alias ssh=ssh_sshrc
fi

# The idea here is to provide a way to use `sshrc` with the *local* root
# account, which would make operations as root "friendlier". But providing
# passwordless root access to the user account is not necessarily a good idea.
# TODO: come up with a better way to use shell configs when operating as root.
# if [[ $(whoami) != root ]]; then
#     # This provides a way to become root using ssh instead of `su` or `sudo su`.
#     # It's useful with `sshrc`.
#     # NOTE: It also provides a PASSWORDLESS way to become root! (See below.)
#     # This has some dangers.
#     alias be-root="ssh root@localhost"
#     # NO: this makes autocomplete match two commands, which is annoying.
#     # alias be-su="be-root"
#
#     if [[ -f ~/.ssh/id_rsa.pub ]]; then
#         be-root -o 'PreferredAuthentications=publickey' "exit" 2>/dev/null 1>/dev/null
#         if [[ $? -eq 255 ]]; then
#             # TODO Make this more interactive. (It's "optional" only in the
#             # sense that it asks for a password and can be canceled at that
#             # stage.)
#             ssh-copy-id root@localhost
#         fi
#     fi
# fi

# Given a PID, print the number of threads
numthreads ()
{
    if [[ $# -ne 1 ]]; then
        echo "USAGE: numthreads <PID>" >&2
        return 1
    fi
    
    # NOTE: This ONLY works in Linux 2.7+ (or...something like that.)
    cat /proc/${1}/stat | awk '{print $20}'
}

# Set the title once immediately
set_title    

save_alias () 
{ 
    local suffix tosave;
    while [[ $# -ne 0 ]]; do
        case $1 in 
            --suff* | -s)
                suffix=".$2";
                shift 2
            ;;
            *)
                tosave="$tosave $1";
                shift
            ;;
        esac;
    done;
    alias $tosave >> ~/.bash_aliases$suffix
}

save_function () 
{ 
    local suffix tosave;
    while [[ $# -ne 0 ]]; do
        case $1 in 
            --suff* | -s)
                suffix=".$2";
                shift 2
            ;;
            *)
                tosave="$tosave $1";
                shift
            ;;
        esac;
    done;
    declare -f $tosave >> ~/.bash_functions$suffix
}
# Functions defined by 'save_function'
