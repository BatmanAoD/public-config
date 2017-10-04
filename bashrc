################################################################################
# File:             .bashrc
# Description:      Bash shell environment file; should be target of symlink
#                       ~/.bashrc
################################################################################

# TODO: figure out a way to add auto-updating version info (using git?)

# If not in an interactive shell, we don't want any custom config stuff.
if echo "$-" | grep -v i > /dev/null; then
    return
fi

# Permit explicitly skipping all our Bash customization
# (set SKIP_CUSTOM_CFG to `true`)
if [[ -n "$SKIP_CUSTOM_CFG" ]] && $SKIP_CUSTOM_CFG; then
    return
fi

# Set the default umask
umask 002

# Print a message
# TODO include version info?
echo -e "$(tput setaf 2)-> bashrc$(tput sgr0)"

# Needed to find bash_addl_rcfiles
shopt -s extglob

# DO NOT 'readlink' here--that will point to 'bashrc' in public-config!
BASHRC_PATH="${BASH_SOURCE[0]}"

cfg_HOME="$(dirname "${BASHRC_PATH}")"

# Source the rc "base" first.
bash_rcbasefile="${cfg_HOME}/.bash_rcbase"

# TODO use a strategy more like this: https://www.turnkeylinux.org/blog/generic-shell-hooks
# Aliases, functions, and site-specific config files
bash_addl_rcfiles="$(echo $bash_rcbasefile ${cfg_HOME}/.bash_!(rcbase|profile|history))"
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
# TODO on repeated 'reload'ing, it appears that 'extraconfigcmds' grows
# geometrically. Fix this.
# TODO in Windows, can we also reload system environment variables? (`cmd`
# offers `refreshenv`, apparently, but we can't call that in Bash.)
alias reload="unalias -a ; source \"${BASHRC_PATH}\" ; eval \${extraconfigcmds}"

say -n green "Primary local account: "
say yellow "${primary_local_account}"
if $id_is_known; then
    say cyan "You are currently using your primary account."
else
    say -n cyan "You are currently using account: "
    say yellow "$(whoami)"
fi

# Print a message
say green "<- bashrc"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
