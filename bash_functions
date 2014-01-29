#!/bin/bash
# The shebang is just to ensure that Vim knows how to highlight this file.

# generic Bash functions

function go() { 
    if [ "$1" != "" ]
    then
        cd "$1"
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    lsd
    else
        echo "go: no path given!"
    fi
}

function up() {
    local numdirs
    if [[ -z $1 ]]; then
        go ../
        return
    fi
    if [[ "$1" -eq "$1" ]] 2>/dev/null; then
        numdirs=$1
    else
        numdirs=${#1}
    fi
    for (( i=1; i<=$numdirs; i++)); do
        cd ../
    done
    lsd
}

# get an absolute path
function abspath() {
    if [[ -n $1 ]]; then
        targ=$1
    else
        targ=$PWD
    fi
    tmp_path=$(readlink -f $targ)
    # ...way to make this more generic?
    tmp_path=${tmp_path/#$(eval echo -e ~${USER})/~${USER}}
    echo $tmp_path
}

# function myglobfunc () {
#     if [[ -n $1 ]]; then rootdir=$1; else rootdir='.'; fi
#     if [[ -n $2 ]]; then childdir='-path *$2'; else childdir=''; fi
#     find -H $rootdir -type f $childdir
# }
# because I can't just name a function '**', as far as I can tell...
# disabled for now because I don't actually like this function that much yet.
# alias '**'=myglobfunc

# Somewhat similar to the above, but use zsh since that's what I really want.
function zeval () {
    echo $@ | zsh
}
alias z*='zeval echo'

# TODO write a function that will watch the timestamp of an exe and wait until
# it changes.
# This is useful while waiting for something to compile.
# use inotifywait--but make sure it's installed before creating this function!
# function comp_wait ()
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

function quickpgrep() {
    # don't use [p]attern trick b/c might have multiple terms
    ps -ef | grep $@ | grep -v grep
}

function swaptwo() {
    local tmpfile
    tmpfile=$(mktemp $TMP/fswapXXXXXXXXX)
    trap "rm -f $tmpfile; trap - RETURN" RETURN
    #TODO for safety, check permissions first
    mv -f $1 $tmpfile
    mv -f $2 $1
    mv -f $tmpfile $1
}

function fswap() {
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
        for fname in $files; do
            swaptwo $src/$fname $dst/$fname
        done
    fi
}

function localize () {
    while [[ $# -ne 0 ]]; do
        cat $1 > $1.local && mv -f $1.local $1
        shift
    done
}

function edit () {
    if [[ -n $DISPLAY ]]; then
        # run in background and suppress job details
        ($VISUAL $@ &)
    else
        # in a terminal, so DON'T run in background!
        $VISUAL $@
    fi
}

# This must change if I switch my editor to Emacs or something.
function edline () {
    # This check is actually mostly just to ensure that our first arg
    # is actually a number and the second arg is actually a file.
    # I don't know how to get wc to suppress the file name, so I use awk.
    # Note that this only works with the single-bracket conditional.
    if [ $1 -le $(wc -l $2 | awk '{print $1}') ] 2>/dev/null ; then
        $EDITOR +$1 $2
    else
        echo "first arg must be an integer <= the number of lines in" >&2
        echo "the file specified by the second arg" >&2
    fi
}

function ednew () {
    touch $1
    chmod a+x $1
    edit $1
}

# edit something on path
function edex () {
    edit $(which $1)
}

# edit a bash function in the current session
# TODO: apparently this doesn't work on home machine...why?
function edfunc () {
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
    if [[ $? -eq 1 ]]; then
        echo -e "function $1 ()\n{\n\n}" > $tmp_def_file
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
            edline $(grep -H -n "function $1" ~/.*functions* |
                awk -F  ":" '{print $2, $1}')
            reload
            return
        else
            echo -n "function " > ${tmp_def_file}.new
            tail -n +2 $tmp_def_file >> ${tmp_def_file}.new
            mv -f ${tmp_def_file}{.new,}
        fi
    else
        # TODO: handle aliases of functions?
        echo "ERROR: $1 is not a function!"
        return
    fi
    cp $tmp_def_file{,.bak}
    $EDITOR $tmp_def_file
    diff $tmp_def_file{,.bak} >/dev/null 2>&1 
    if [[ $? -eq 1 ]]; then
        . $tmp_def_file
    fi
}

function edvar() {
    eval echo \$$1 > $TMP/editvar_$1
    $EDITOR $TMP/editvar_$1
    eval export $1=\"`cat $TMP/editvar_$1`\"
    rm $TMP/editvar_$1
}


function cptmp() {
    cp $@ $TMP/
}

function mvtmp() {
    while [[ $# -ne 0 ]]
    do
        mv $1 $TMP/
        shift
    done
}

# move a local file to a sandbox location
function tosandbox() {
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
function contains() {
    if [[ $(diff $1 $2 | grep -P "^<") == "" ]]; then
        echo $1 contains $2
        return 0
    else
        return 1
    fi;
}

# print a large notification when command completes
function loud() {
eval "$@" ; bigresult $?
}

function backup() {
    while [[ $# -ne 0 ]]
    do
        cp -a $1 $1.bak
        shift
    done
}

function switch() {
    if [ "$1" == "" ] || [ "$2" == "" ]
    then
        echo "not enough args!"
    else
        /bin/cp $1 $TMP/switch_$1_$2
        /bin/cp $2 $1
        /bin/cp $TMP/switch_$1_$2 $2
    fi
}

function mkgoodbad() {
    if [ "$1" == "" ]
    then
        echo "not enough args!"
    else
        cp $1 $1.good
        cp $1 $1.bad
    fi
}

function usegood() {
    if [ "$1" == "" ]
    then
        echo "not enough args!"
    else
        /bin/cp $1.good $1
    fi
}

function usebad() {
    if [ "$1" == "" ]
    then
        echo "not enough args!"
    else
        /bin/cp $1.bad $1
    fi
}
    
function mkc() { mkdir "$@" ; cd "$@";}

# Easy extract
function extract () {
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

# function google () {
#     googurl="http://www.google.com/search?q="
#     firefox $googurl$(echo $@ | sed -e 's/ /\%20/g');
# }
