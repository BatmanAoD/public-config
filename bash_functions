#!/bin/bash
# The shebang is just to ensure that Vim knows how to highlight this file.

# generic Bash functions

go() { 
    if [ "$1" != "" ]
    then
        pushd "$1" &> /dev/null
        if [[ $? -ne 0 ]]; then
            echo "go: error! Possibly invalid directory." >&2
            return 1
        fi
    lsd
    else
        echo "go: no path given!" >&2
    fi
}

up() {
    DOWN_DIR=$PWD
    local numdirs
    if [[ -z $1 ]]; then
        go ../
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
        go $pdir
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

# get an absolute path
abspath() {
    if [[ -n $1 ]]; then
        targ=$1
    else
        targ=$PWD
    fi
    tmp_path=$(readlink -f $targ)
    # If on Windows, get a Windows path
    if $CYGWIN; then
        tmp_path=$(cygpath -w $tmp_path)
    # Otherwise, try to substitute out `~<usr>`
    else
        # If this is under a home dir, replace with the correct ~usrname
        # To do this, determine who owns it; presumably, if it's under a
        # homedir, that user should own it.
        # NOTE: this will cause an error on nonexistent files.
        tmp_usr=$(ls -l -d $targ | awk '{print $3}')
        # Figure out what "readlink" outputs for that user's home dir.
        home_parent=$(eval readlink -f ~${tmp_usr})
        # Do the replacement if possible. Otherwise, assume it's not under
        # a home dir.
        tmp_path=${tmp_path/#${home_parent}/~${tmp_usr}}
    fi
    echo $tmp_path
}

# set `cat` options based on filetype
# I...can't remember why I thought '-A' was a good idea.
# To cat binary files in the default 'cat' style (i.e. without the '-A'
# option), just use '-u' (which is usually ignored by cat).
qcat() {
    # default opt for ASCII files
    catopts='-v'
    for file in $@; do
        # if explicit opts are given, just do the cat.
        if [[ $file == -* ]]; then
            catopts=
            break
        fi
        if ! grep -q 'text\|script' <(file -L -p $file); then
            catopts='-A'
            # don't break, because *any* options provided should override
            # mine.
         fi
     done
     \cat $catopts $@
 }

# myglobfunc () {
#     if [[ -n $1 ]]; then rootdir=$1; else rootdir='.'; fi
#     if [[ -n $2 ]]; then childdir='-path *$2'; else childdir=''; fi
#     find -H $rootdir -type f $childdir
# }
# because I can't just name a '**', as far as I can tell...
# disabled for now because I don't actually like this function that much yet.
# alias '**'=myglobfunc

# Somewhat similar to the above, but use zsh since that's what I really want.
zeval () {
    echo $@ | zsh
}
alias z*='zeval echo'

# TODO write a function that will watch the timestamp of an exe and wait until
# it changes.
# This is useful while waiting for something to compile.
# use inotifywait--but make sure it's installed before creating this function!
# comp_wait ()
# {
#     if [[ -z $1 ]]; then
#         exe=trantor;
#     else
#         exe=$1;
#     fi;
#     alias tmp_do_ll="lsplain -l $(which $exe)"
#     llstr=$(tmp_do_ll)
#     if echo $llstr | grep "no $exe in"; then
#         init="00:00"
#     else
#         init=$(echo $llstr | awk '{print $8}');
#     fi
#     while [[ $ | awk '{print $8}') == $init ]]; do
#         sleep 1;
#     done
#     unalias tmp_do_ll
# }

# Old version (see aliases for new version):
#quickpgrep() {
#    # for some reason neither $@ and $* works with the {var:1} trick.
#    argstr=$@
#    ps -ef | grep "[${1:0:1}]${argstr:1}"
#}

# Somehow this keeps getting unset. TODO: figure out why. For now,
# I'll just run this check every time I start a new Bash session or
# do a 'reload', and if Caps_Lock is set, I'll un-set it. This is
# terribly hacky.
fixkeys() {
    # On the off-chance that the gnome-settings-daemon is what's causing
    # this problem...
    ps -ef | grep [g]nome-settings
    if [[ $? -eq 0 ]]; then
        echo ".....is a potential culprit for resetting the keyboard"
        echo "mappings."
    fi
    # Return to default layout before making changes.
    setxkbmap -layout us
    xmodmap ~/.Xmodmap
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

localize () {
    while [[ $# -ne 0 ]]; do
        cat $1 > $1.local && mv -f $1.local $1
        shift
    done
}

if $CYGWIN; then
    # adapted from http://stackoverflow.com/a/12661288/1858225
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

edit () {
    $NEWWINDOW_EDIT_CMD $@
}
# ...I can't remember why I set up `edit` to be so complicated.
# edit () {
#     if $CYGWIN; then
#         # XXX TODO figure out how to make `-f` work
#         # ...maybe do something with the `--fork=2` stuff?
#         gvim "$@"
#     elif [[ $VISUAL =~ "gvim" ]]; then
#         # run in background and suppress job details
#         # `eval` is for zsh compatibility
#         (eval $VISUAL $@ &)
#     else
#         # Don't try to run normal 'vim' in the background!
#         eval $VISUAL $@
#     fi
# }

# This must change if I switch my editor to Emacs or something.
edline () {
    # This check is actually mostly just to ensure that our first arg
    # is actually a number and the second arg is actually a file.
    # I don't know how to get wc to suppress the file name, so I use awk.
    # Note that this only works with the single-bracket conditional.
    if [ $1 -le $(wc -l $2 | awk '{print $1}') ] 2>/dev/null ; then
        edit +$1 $2
    else
        echo "first arg must be an integer <= the number of lines in" >&2
        echo "the file specified by the second arg" >&2
    fi
}

ednew () {
    touch $1
    chmod a+x $1
    edit $1
}

# edit something on path
edex () {
    edit $(which $1)
}

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


cptmp() {
    cp $@ $TMP/
}

mvtmp() {
    while [[ $# -ne 0 ]]
    do
        mv $1 $TMP/
        shift
    done
}

# move a local file to a sandbox location
tosandbox() {
    if [[ -n $2 ]]; then
        sanddir=$2
    else
        sanddir=default_backups
    fi
    fdir=$(dirname $1)
    fname=$(basename $1)
    destdir="~/sandbox/$sanddir/$fdir"
    mkdir -p $destdir
    echo "mv $1 $destdir/$fname"
    mv $1 $destdir/$fname
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

backup() {
    while [[ $# -ne 0 ]]
    do
        cp -a $1 $1.bak
        shift
    done
}

switch() {
    if [ "$1" == "" ] || [ "$2" == "" ]
    then
        echo "not enough args!"
    else
        /bin/cp $1 $TMP/switch_$1_$2
        /bin/cp $2 $1
        /bin/cp $TMP/switch_$1_$2 $2
    fi
}

mkgoodbad() {
    if [ "$1" == "" ]
    then
        echo "not enough args!"
    else
        cp $1 $1.good
        cp $1 $1.bad
    fi
}

usegood() {
    if [ "$1" == "" ]
    then
        echo "not enough args!"
    else
        /bin/cp $1.good $1
    fi
}

usebad() {
    if [ "$1" == "" ]
    then
        echo "not enough args!"
    else
        /bin/cp $1.bad $1
    fi
}
    
mkc() { mkdir "$@" ; cd "$@";}

# Easy extract
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

# google () {
#     googurl="http://www.google.com/search?q="
#     firefox $googurl$(echo $@ | sed -e 's/ /\%20/g');
# }

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

# Cygwin specific:
start_xwin ()
{
    if ! $CYGWIN; then
        echo "ERROR: Not running Cygwin! Xwin not started."
        return 1
    fi
    if ! pgrep XWin > /dev/null; then
        startxwin &> $(mktemp /tmp/xwin_stdout_XXXXXX)
    fi
    if pgrep XWin > /dev/null; then # Check for success
        export DISPLAY=localhost:0
    fi
}

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
assert-pwd-is-obj () 
{ 
    if [[ $(basename $(pwd)) == obj ]] && [[ ! -e ./.git ]]; then
        return 0;
    else
        echo "NOT IN OBJ DIRECTORY! No action taken." 1>&2;
        return 1;
    fi
}
