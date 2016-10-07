autoload -Uz compinit promptinit colors
compinit
promptinit
colors

setopt completealiases
setopt extendedglob

# VCS info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:hg*:*' formats "%{$fg[yellow]%}%c%{$fg[green]%}%u%{$reset_color%} [%{$fg[blue]%}%b%{$reset_color%}] %{$fg[yellow]%}%s%{$reset_color%}"
zstyle ':vcs_info:git*:*' formats "%{$fg[yellow]%}%c%{$fg[green]%}%u%{$reset_color%} [%{$fg[blue]%}%b@%.6i%{$reset_color%}] %{$fg[yellow]%}%s%{$reset_color%}"
precmd() { vcs_info }

# Prompt
setopt PROMPT_SUBST
color="blue"
if [ "$USER" = "root" ]; then
    color="red"
fi;
prompt="%{$fg[$color]%}%n%{$reset_color%}@%U%{$fg[yellow]%}%M%{$reset_color%}%u %B%~%b "
RPROMPT='${vim_mode} ${vcs_info_msg_0_}'

# History
setopt hist_ignore_all_dups
setopt share_history
setopt hist_verify
export HISTSIZE=2000
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.zsh_history"

bindkey -v
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

alias ls='ls --color=auto'
alias l='ls -lah --color=auto'
alias -g ...='cd ../../'
alias -g ....='cd ../../../'
alias rsync-copy="rsync -avz --progress -h"
alias rsync-move="rsync -avz --progress -h --remove-source-files"
alias rsync-update="rsync -avzu --progress -h"
alias rsync-synchronize="rsync -avzu --delete --progress -h"


