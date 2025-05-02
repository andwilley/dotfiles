# $Id: //depot/google3/googledata/corp/puppet/goobuntu/common/modules/shell/files/bash/skel.bashrc#6 $
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
if [[ $- != *i* ]]; then
    return
fi


# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Vim motion and edit CLI in buffer
set -o vi

# nvim for all UI
export VISUAL=nvim
export EDITOR="$VISUAL"

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

# Local non-version controlled stuff
if [ -f ~/.local/bash/local ]; then
    . ~/.local/bash/local
fi

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi
if [ -x /opt/homebrew/bin/gdircolors ]; then
    test -r ~/.dircolors && eval "$(gdircolors -b ~/.dircolors)" || eval "$(gdircolors -b)"
    alias ls='ls --color=auto'
fi

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
# Rust setup
export PATH=$PATH:$HOME/.cargo/bin

# MPW env variables
export MPW_FULLNAME="Andrew Willey"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  fi
  if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# nice bash
eval "$(starship init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
