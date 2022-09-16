#!/bin/bash
#   ~/.bashrc
#
# Bash Shell initialization script.

#-------------------------#
# SHELL - INITIALIZATION  #
#-------------------------#
[[ $PATH = *local/bin* ]] || PATH=$PATH:/usr/local/bin
[[ $- = *i* ]] || return
source bashlib


#-------------------------#
# ALIASSES - FILESYSTEM   #
#-------------------------#
alias noproxy="http_proxy= HTTP_PROXY= https_proxy= HTTPS_PROXY= ftp_proxy= FTP_PROXY="
alias rs="rsync --archive --no-owner --verbose --sparse --hard-links --partial --progress"
alias srs="sc rs"
alias mvn="nice mvn"
alias port="sudo nice port"
alias cp="cp -v"
alias mv="mv -v"
alias tree="tree -F --dirsfirst"
if ls --color >/dev/null 2>/dev/null; then
    alias ls="ls -bFk --color=auto"
else
    alias ls="ls -bFkG"
fi
alias ll="ls -lh"
alias l=" ll -a"
alias df="df -h"


#-------------------------#
# ALIASSES - APPLICATIONS #
#-------------------------#
alias cal="cal -m -3"
alias gsh="git stash"
alias gst="git status"
alias gdf="git diff"
alias glo="git log"
alias gps="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gci="git commit"
alias gad="git add"
alias grm="git rm"
alias gmv="git mv"
alias gtg="git tag"
alias gbr="git branch"
alias gs="git svn"


#-------------------------#
# ALIASSES - SYSTEM       #
#-------------------------#
alias r='fc -s'
exists wdiff && \
    alias wdiff="wdiff -a"
exists less && \
    alias more="less" || \
    alias less="more"
alias kbg='bg; kill $!; fg'
exists ltrace && \
    alias trace="ltrace -C -f -n 4 -S"
exists pcregrep && \
    alias pcregrep="pcregrep --color=auto"
alias grep="grep -I --color=auto"
alias egrep="grep -E"
alias fgrep="grep -F"
alias pg="pgrep -l"
if exists pstree; then
    p() {
        if pstree -A >/dev/null 2>&1; then
            pstree -Aahlpu
        else
            [[ -t 1 ]] \
                && pstree -w -g2 \
                || pstree -w -g1 | recode -fg IBM850..UTF8
        fi
    }
else
    if ps auxf >/dev/null 2>&1; then
        p() { ps auxf; }
    else
        p() { ps aux; }
    fi
fi
alias pp="p | less"
top -u -l1 >/dev/null 2>&1 && \
    alias top="top -S -u -stats pid,ppid,user,cpu,time,threads,state,rprvt,vprvt,faults,command"


#-------------------------#
# ALIASSES - NETWORKING   #
#-------------------------#
alias n="netstat -np tcp"
alias mtr="mtr -t"
alias nmap="nmap -v -v -T5"
alias nmapp="nmap -P0 -A --osscan_limit"
alias pktstat="sudo pktstat -tBFT"


#-------------------------#
# OS-SPECIFIC             #
#-------------------------#
if [[ $MACHTYPE = *darwin* ]]; then
    # MAC ----------------#

    qview() {
        files=("$@"); i=0
        while true; do
            file=${files[i]}
            qlmanage -p "$file" & pid=$!
            
            read -sn1 key
            kill $pid || key=q
            wait $pid

            case $key in
                q)  return  ;;
                p)  let i-- ;;
                *)  let i++ ;;
            esac

            (( i < ${#files[@]} )) || break
            (( i < 0 )) && i=0
        done
    } 2>/dev/null

    qthumb() {
        qlmanage -t "$@" & pid=$!
        read -sn1

        kill $pid; wait $pid
    } 2>/dev/null
fi

#-----------------------------#
# SHELL - HISTORY             #
#-----------------------------#
shopt -s histappend
HISTSIZE=-1
HISTCONTROL=ignoreboth
HISTFILESIZE=-1
HISTTIMEFORMAT="%d/%m/%y %T "

#-------------------------#
# SHELL - LOOK AND FEEL   #
#-------------------------#
{
shopt -s extglob
shopt -s checkwinsize
shopt -s hostcomplete
shopt -s no_empty_cmd_completion
shopt -s globstar
shopt -s autocd
shopt -s cdspell
stty stop undef
} 2>/dev/null

#[[ -f /etc/bash_completion ]] && \
#    source /etc/bash_completion

# Terminal title for xterm/rxvt/screen.
case "$SHELL" in
    */bash|bash)
        case "$TERM" in
            ?term*|rxvt*|gnome*|interix)
                PROMPT_COMMAND='history -a; echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'   ;;
            screen*)
                PROMPT_COMMAND='history -a; echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"'   ;;
        esac
    ;;
esac

# Add git branch to prompt
if [ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash ]; then
    . /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
fi
source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh
# show whether pending changes are there
export GIT_PS1_SHOWDIRTYSTATE=1

# Prompt
#PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[00m\] '
PS1='\h\[$blue\] \W \[$yellow\]$(__git_ps1) \[$red\]${?/#0/\[$green\]}\$\[$reset\] '
#PS1='\h\[$blue\] \W \[$red\]${?/#0/\[$green\]}\$\[$reset\] '
if (( EUID )); then
    PS1='\[$reset$bold$green\]\u@'$PS1
else
    PS1='\[$reset$bold$red\]'$PS1
fi

# Colors
if      [[ -f /etc/DIR_COLORS.env ]]
then        source "/etc/DIR_COLORS.env"
elif    [[ -f /etc/DIR_COLORS ]] && exists dircolors
then        eval "$(dircolors -b "/etc/DIR_COLORS")"
fi
if      [[ -f $HOME/dir_colors.env ]]
then        source "$HOME/dir_colors.env"
elif    [[ -f $HOME/dir_colors ]] && exists dircolors
then        eval "$(dircolors -b "$HOME/dir_colors")"
fi

# X Resources.
#[ "$DISPLAY" -a -f "$HOME/.Xdefaults" ] && \
#    exists xrdb && xrdb "$HOME/.Xdefaults"


#-------------------------#
# FUNCTIONS - CONVENIENCE #
#-------------------------#
d() {
    if exists colordiff; then
        colordiff -ur "$@"
    elif exists diff; then
        diff -ur "$@"
    elif exists comm; then
        comm -3 "$1" "$2"
    fi | less
}
ppg() {
    pat=$1; shift
    p | grep -i "$@" "$pat"
}
cwatch() {
    while sleep .5; do
        o="$("$@")"
        clear && echo "$o"
    done
}
mvns() {
    export PATH=/usr/local/share/soylatte16-amd64-1.0.3/bin:${PATH}
    export JAVA_HOME=/usr/local/share/soylatte16-amd64-1.0.3

    mvn "$@"
}
mvnroot() {
    local p=$PWD
    until p=${p%/*}; [[ -e "$p/pom.xml" ]]; do :; done

    cd "$p"
}
gf() {
    git-forest --all -a --sha "$@" | less
}
git-redo-move() {
    (( $# == 2 ))   || { emit -r "Expected two parameters; [source] [destination]."; return; }
    [[ -e $2 ]]     || { emit -r "$2 doesn't exist, can't redo move."; return; }
    [[ ! -e $1 ]]   || { emit -r "$1 exists, don't want to overwrite, aborting redo move."; return; }
    mkdir -p "${1%/*}" && \mv "$2" "$1" && git mv "$1" "$2" && rmdir -p "${1%/*}"
}
portget() {
    (( $# )) || { emit -r "$0 [revision] [category/portname]"; return; }

    [[ -e "${2#*/}" ]] && { ask -Ny! 'Target exists, delete?' && rm -rf "${2#*/}" || return; }
    svn co -r "$1" http://svn.macports.org/repository/macports/trunk/dports/"$2"
    cd "${2#*/}"
}


#-------------------------#
# FUNCTIONS - NETWORKING  #
#-------------------------#
exists lft && \
    lft() {
        sudo lft -S "$@" | tail -n +3 | column -t
    }
svnup() {
    local cRev=$(svn info | awk '/^Revision:/ { print $2 }')
    [[ $cRev ]] || { emit -r "Not in a repository."; return 1; }

    emit "Looking for updates to r$cRev"
    svn up

    local nRev=$(svn info | awk '/^Revision:/ { print $2 }')
    [[ $nRev = $cRev ]] && {
        emit "Nothing to update."
        return
    }

    echo
    emit "Changelog $cRev -> $nRev:"
    svn log -r$((cRev+1)):$nRev | while IFS= read -r line; do
        [[ $line ]] || continue

        [[ $line != *[^-]* ]] && { begin=1; continue; }
        if (( begin )); then
            read rev _ user _ d t _ <<< "$line"
            echo
            echo "$bold$green$user$reset - r$bold${rev#r}$reset:    "$'\t'"($bold$d$reset - $bold$t$reset)"
            begin=0
        else
            [[ $line = *:* ]] \
                && echo $'\t'"$reset- $bold$blue${line%%:*}$reset:${line#*:}" \
                || echo $'\t'"$reset- $line"
        fi
    done

    echo
    emit "To view the code diff of these updates; execute: svn diff -r$cRev:$nRev $(quote "$@")"
}


#-------------------------#
# FUNCTIONS - FILE SYSTEM #
#-------------------------#
cc() {
    [[ $@ =~ ^\ *(.*)\ +([^\ ]+)\ *$ ]] && \
        tar -Sc ${BASH_REMATCH[1]} | \
            tar --preserve -xvC ${BASH_REMATCH[2]}
}
sc() {

    # Get the alias to sudo'ify and parse out the command.
    cmd="$(alias $1)"
    cmd="${cmd#*=\'}"
    shift
    
    # Replace homedir references for SSH-like commands by the correct homedir.
    if [[ $cmd =~ ^\(rsync\|ssh\|scp\) ]]; then
        cmd="${cmd%\'} $(echo "$@" | \
            perl -pe 's/:(~\/)?([^\/])/:'${HOME//\//\\/}'\/\2/')"
        cmd="$(echo "$cmd" | \
            perl -pe 's/:~(\s|$)/:'${HOME//\//\\/}'/')"
    fi

    # Execute.
    sudo /bin/sh -c ". ~/.keychain/$HOSTNAME-sh; $cmd"
}


#-------------------------#
# FUNCTIONS - EVALUATION  #
#-------------------------#
calc() { python -c "import math; print $*"; }
c() {
    local out="${TMPDIR:-/tmp}/c.$$" strict=1
    trap 'rm -f "$out"' RETURN

    [[ $1 = -l ]] && { strict=; shift; }
    
    local code="
#include <stdio.h>
#include <math.h>

int main(int argc, const char* argv[]) {
    $1;
    return 0;
}"
    shift

    if ! gcc -x c -o "$out" -Wall ${strict:+-Werror} - <<< "$code"; then
        emit -r "Compilation failed:"
        cat -n <<< "$code"
        return 255
    else
        chmod +x "$out" && "$out" "$@"
    fi
}


#-------------------------#
# STARTUP APPLICATIONS    #
#-------------------------#
exists todo && todo

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*