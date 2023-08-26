#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

if command -v nvim &>/dev/null; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

export RANGER_LOAD_DEFAULT_RC=false
export LESSHISTFILE=-

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias e="$EDITOR"
alias r="ranger"