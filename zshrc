# Install custom completions under ~/.zsh/completions
# e.g. to install salt completions
# mkdir -p ~/.zsh/completions && curl "https://raw.githubusercontent.com/saltstack/salt/develop/pkg/zsh_completion.zsh" > ~/.zsh/completions/_salt
fpath=( ~/.zsh/completions $fpath )

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
color="green"
if [ "$USER" = "root" ]; then
    color="red"
fi;
prompt="[%T]%{$fg[green]%}[%{$fg[$color]%}%n%{$reset_color%}%{$fg[green]%}@%M]%{$reset_color%}
%{$fg[cyan]%}[%~]%{$reset_color%}
$ "
RPROMPT='${vim_mode} ${vcs_info_msg_0_}'

# History
setopt hist_ignore_all_dups
setopt share_history
setopt hist_verify
export HISTSIZE=2000
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.zsh_history"

# Dirstack
DIRSTACKSIZE=20
DIRSTACKFILE="$HOME/.zdirs"
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

setopt AUTO_PUSHD PUSHD_SILENT PUSHD_TO_HOME
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# Key bindings
bindkey -v
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward
bindkey "^R" history-incremental-pattern-search-backward

# Aliases
alias ls='ls --color=auto'
alias l='ls -lah --color=auto'
alias ll='ls -lAh --color=auto'
alias -g ...='cd ../../'
alias -g ....='cd ../../../'
alias rsync-copy="rsync -avz --progress -h"
alias rsync-move="rsync -avz --progress -h --remove-source-files"
alias rsync-update="rsync -avzu --progress -h"
alias rsync-synchronize="rsync -avzu --delete --progress -h"
alias activate_production="export DJANGO_SETTINGS_MODULE=project.production"
alias activate_staging="export DJANGO_SETTINGS_MODULE=project.staging"
alias activate_local="export DJANGO_SETTINGS_MODULE=local_settings"
alias rootme="sudo -E su"

# Exports
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Helper functions
dump_db () {
  dump_file="$1-`date -I`.dump"
  echo "Running: sudo -u postgres pg_dump -Fc $1 >$dump_file"
  sudo -u postgres pg_dump -Fc $1 >$dump_file
  ls -lah $dump_file
}

