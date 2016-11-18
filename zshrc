# Install custom completions under ~/.zsh/completions
# e.g. to install salt completions
# mkdir -p ~/.zsh/completions && curl "https://raw.githubusercontent.com/saltstack/salt/develop/pkg/zsh_completion.zsh" > ~/.zsh/completions/_salt
fpath=( ~/.zsh/completions $fpath )

autoload -Uz compinit promptinit colors up-line-or-beginning-search down-line-or-beginning-search url-quote-magic
compinit
promptinit
colors

setopt completealiases
setopt extendedglob
setopt correct

# Completion
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

# Process completion shows all processes with colors
zstyle ':completion:*:*:*:*:processes' menu yes select
zstyle ':completion:*:*:*:*:processes' force-list always
zstyle ':completion:*:*:*:*:processes' command 'ps -A -o pid,user,cmd'
zstyle ':completion:*:*:*:*:processes' list-colors "=(#b) #([0-9]#)*=0=${color[green]}"
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -e -o pid,user,tty,cmd'

# List all processes for killall
zstyle ':completion:*:processes-names' command "ps -eo cmd= | sed 's:\([^ ]*\).*:\1:;s:\(/[^ ]*/\)::;/^\[/d'"

# Quote urls
zle -N self-insert url-quote-magic

# VCS info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable hg git
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:hg*:*' formats "%{$fg[blue]%}[%s:%b]%{$reset_color%} %{$fg[green]%}%u%{$reset_color%}"
zstyle ':vcs_info:git*:*' formats "%{$fg[blue]%}[%s:%b:%.6i]%{$reset_color%} %{$fg[green]%}%u %c%{$reset_color%}"
precmd() { vcs_info }

# Prompt
setopt prompt_subst
color="green"
if [ "$USER" = "root" ]; then
    color="red"
fi;

export VIRTUAL_ENV_DISABLE_PROMPT=yes
function virtenv_indicator {
  if [[ -z $VIRTUAL_ENV  ]] then
    psvar[1]=''
  else
    psvar[1]=${VIRTUAL_ENV##*/}
  fi
}

add-zsh-hook precmd virtenv_indicator

prompt='%(1j.%{$fg[red]%}[%j]%{$reset_color%}.)[%T]%{$fg[green]%}[%{$fg[$color]%}%n%{$reset_color%}%{$fg[green]%}@%M]%{$reset_color%}${vcs_info_msg_0_}
%{$fg[yellow]%}%(1V.(%1v).)%{$reset_color%}%{$fg[cyan]%}[%~]%{$reset_color%}
%(!.#.$) '

# History
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
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
bindkey -M vicmd 'k' history-beginning-search-backward-end
bindkey -M vicmd 'j' history-beginning-search-forward-end
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down
bindkey "^R" history-incremental-pattern-search-backward

# Easier moving backwards
# You can do either `cd ...` or just `...` in order to `cd ../../../` 
setopt auto_cd
setopt complete_aliases

rationalize-dots() {
	[[ $LBUFFER = *.. ]] && LBUFFER+=/.. || LBUFFER+=.
}

autoload rationalize-dots
zle -N rationalize-dots
bindkey . rationalize-dots

# Aliases
alias ls='ls --color=auto'
alias l='ls -lah --color=auto'
alias ll='ls -lAh --color=auto'
alias rsync-copy="rsync -avz --progress -h"
alias rsync-move="rsync -avz --progress -h --remove-source-files"
alias rsync-update="rsync -avzu --progress -h"
alias rsync-synchronize="rsync -avzu --delete --progress -h"
alias activate_development="export DJANGO_SETTINGS_MODULE=project.development"
alias activate_production="export DJANGO_SETTINGS_MODULE=project.production"
alias activate_staging="export DJANGO_SETTINGS_MODULE=project.staging"
alias activate_local="export DJANGO_SETTINGS_MODULE=local_settings"
alias rootme="sudo -E su"
alias rootzsh="sudo -E su -s /bin/zsh"
alias update_zshrc="curl https://raw.githubusercontent.com/tkharju/zsh/master/zshrc > $HOME/.zshrc && source $HOME/.zshrc"
alias salt="noglob salt"
alias tail_logs="tail -f **/*.log|ccze"
alias tail_syslogs="tail -f /var/log/{messages,syslog,**/*.log}|ccze"
alias drun='docker run --rm -i -t -v $(dirname $SSH_AUTH_SOCK):$(dirname $SSH_AUTH_SOCK) -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK -v $(pwd):/home/foo/foo'
alias glog="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(bold blue)- <%an>%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias gc="git commit -v"
alias gnc='git log `git describe --tags --abbrev=0`..HEAD --oneline'
alias gnd='git diff `git describe --tags --abbrev=0`..HEAD'
alias silent_push_hg="hg -q push &"
alias install_vimrc="git clone -b server https://github.com/tkharju/vim.git $HOME/.vim; vim"

# Exports
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR=vim

# Helper functions
haltu_dump_db () {
  dump_file="$1-`date -I`.dump"
  echo "Running: sudo -u postgres pg_dump -Fc $1 -f $dump_file"
  sudo -u postgres pg_dump -Fc $1 -f $dump_file
  ls -lah $dump_file
}

# For Ubuntu servers
haltu_remove_old_kernels () {
  echo "Current kernel"
  uname -a
  echo $(dpkg --list | grep linux-image | awk '{ print $2  }' | sort -V | sed -n '/'`uname -r`'/q;p') $(dpkg --list | grep linux-headers | awk '{ print $2  }' | sort -V | sed -n '/'"$(uname -r | sed "s/\([0-9.-]*\)-\([^0-9]\+\)/\1/")"'/q;p') | xargs sudo apt-get -y purge
}

haltu_install_security_updates () {
  echo "Packages to be installed"
  /usr/lib/update-notifier/apt-check -p
  echo "Installing updates"
  sudo unattended-upgrade -v
}

# Usage: $ haltu_check_certificate_dates app.seepra.fi
haltu_check_certificate_dates () {
  echo | openssl s_client -connect $1:443 2>/dev/null | openssl x509 -noout -dates |awk -F'=' '{ print $2 }'
}

# List top 20 prosesses with most open file descriptors
# Output format: <amount of open fd> <pid> <command>
haltu_top_20_open_file_descriptors () {
  for x in `ps -eF| awk '{ print $2  }'`
    do echo `ls /proc/$x/fd 2> /dev/null | wc -l` $x `cat /proc/$x/cmdline 2> /dev/null`
  done | sort -n -r | head -n 20
}

# Helper for creating e.g. backups. Use: "filename-$DSTAMP.bak"
export DSTAMP
currdate() {
  DSTAMP=$(date -I)
}
add-zsh-hook preexec currdate

# Install z command for faster jumping into directories.
# See: https://github.com/rupa/z
# Usage: This should work:
# cd ~/haltu/sysops
# cd /tmp/foo
# z sysops
# you are now in ~/haltu/sysops
alias haltu_install_z='mkdir -p $HOME/.zsh; curl https://raw.githubusercontent.com/rupa/z/master/z.sh -o $HOME/.zsh/z.sh; source $HOME/.zshrc'
[[ -r ~/.zsh/z.sh ]] && . ~/.zsh/z.sh

# You can add to ~/.zsh/local.zsh your mercurial and git settings
# E.g:
# export HGUSER=Tino Kiviharju <tino.kiviharju@haltu.fi>
# export GIT_AUTHOR_NAME=Tino Kiviharju
# export GIT_AUTHOR_EMAIL=tino.kiviharju@haltu.fi
# export GIT_COMMITTER_NAME=Tino Kiviharju
# export GIT_COMMITTER_EMAIL=tino.kiviharju@haltu.fi
[[ -r ~/.zsh/local.zsh ]] && . ~/.zsh/local.zsh

# vim: tw=0
