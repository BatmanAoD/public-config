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
    tmp_path=$(readlink -f $1)
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

function quickpgrep() {
    # don't use [p]attern trick b/c might have multiple terms
    ps -ef | grep $@ | grep -v grep
}

function swaptwo() {
    local tmpfile
    tmpfile=$(mktemp $TMP/fswapXXXXXXXXX)
    trap "rm -f $tmpfile" RETURN
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
    # run in background and suppress job details
    ($VISUAL $@ &)
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

function edvar() {
    eval echo \$$1 > $TMP/editvar_$1
    $EDITOR $TMP/editvar_$1
    eval export $1=\"`cat $TMP/editvar_$1`\"
    rm $TMP/editvar_$1
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
