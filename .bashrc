# $Id: //depot/google3/googledata/corp/puppet/goobuntu/common/modules/shell/files/bash/skel.bashrc#6 $
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Vim motion and edit CLI in buffer
set -o vi

# Better cli history search:
bind -f ~/.inputrc

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000000
HISTFILESIZE=1000000000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Alias definitions (load both)
if [ -f ~/.goog/.bash_aliases ]; then
    . ~/.goog/.bash_aliases
fi
if [ -f ~/.bashgoodies/.bash_aliases ]; then
    . ~/.bashgoodies/.bash_aliases
fi

# Bash functions (only load work or not work)
if [ -f ~/.goog/.bash_funcs ]; then
    . ~/.goog/.bash_funcs
elif [ -f ~/.bashgoodies/.bash_funcs ]; then
    . ~/.bashgoodies/.bash_funcs
fi

# Bash promp make more goodly.
if [ -f ~/.bashgoodies/.bash_prompt ]; then
    . ~/.bashgoodies/.bash_prompt
fi

# Local non-version controlled stuff
if [ -f ~/.local/bash/local ]; then
    . ~/.local/bash/local
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|xterm-256color) color_prompt=yes;;
esac

force_color_prompt=yes

PS1="\[\033[01;32m\]\u@\h:\w\$(bpvcs_bash_prompt)\n\[\033[01;35m\]λ\[\033[00m\] "
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# turn off <C-s> functionality
stty -ixon

# Add local path to system path
export PATH=$PATH:~/.local/bin

# Go setup
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Add homebrew to path if it exists
if [ -d /opt/homebrew/bin ]; then
    export PATH=$PATH:/opt/homebrew/bin
fi

# LUA setup
export PATH=$PATH:$HOME/apps/lua-language-server/bin

# MPW env variables
export MPW_FULLNAME="Andrew Willey"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
