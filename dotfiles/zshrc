# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=**' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
zstyle :compinstall filename '/cygdrive/c/Users/kjstrand/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_hist
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory autocd extendedglob notify
unsetopt beep nomatch
# End of lines configured by zsh-newuser-install

autoload -U colors && colors
PS1="%{$fg[yellow]%}%m:%~> %{$reset_color%}"

# TODO ensure cross-compatibility and rename these
. ~/.bash_functions
. ~/.bash_aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
