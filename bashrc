################################################################################
# File:             .bashrc
# Description:      Bash shell environment file; should be target of symlink
#                       ~/.bashrc
################################################################################

# XXX TEMP profiling
#PS4='+ $(date "+%s.%N")\011 '
#exec 3>&2 2>/tmp/bashstart.$$.log
#set -x

# TODO: figure out a way to add auto-updating version info (using git?)

# Set the default umask
umask 002

# Print a message
# TODO include version info?
echo "-> bashrc"

shopt -s extglob

# Source the rc "base" first.
bash_rcbasefile="${HOME}/.bash_rcbase"

# Aliases, functions, and site-specific config files
bash_addl_rcfiles="$(echo $bash_rcbasefile ${HOME}/.bash_!(rcbase|profile|history))"
for bashfile in ${bash_addl_rcfiles}; do
    echo Sourcing $bashfile
    # We could skip `.swp` files, but in theory these are technically all
    # symlinks anyway, so the `.swp` files will be elsewhere.
    . ${bashfile}
done

# This is here, rather than in .bash_aliases, due to how it determines the
# bashrc path.
# `extraconfigcmds` is a set of commands used to restore any "additional" setup
# that was in place before the reload. I'm not sure why the `eval` is
# necessary.
alias reload="unalias -a ; source $(readlink -f "${BASH_SOURCE[0]}") ; eval \${extraconfigcmds}"

# Print a message
echo "<- bashrc"

# XXX TEMP profiling
#set +x
#exec 2>&3 3>&-
