#!/bin/sh
#   ~/.profile
#
# POSIX Shell login script.
#
#-------------------------#
# BASE - UTILITY          #
#-------------------------#
exists() {
    test -x "`type -P "$1" 2>/dev/null`"
}


#-------------------------#
# BASE - PATH             #
#-------------------------#
export                  PATH="/etc/toolsched:$HOME/.bin:/usr/local/sbin:/usr/local/bin"
[ -d "$EPREFIX" ]    && PATH="$PATH:$EPREFIX/usr/sbin:$EPREFIX/usr/bin:$EPREFIX/sbin:$EPREFIX/bin"
                        PATH="$PATH:/usr/sbin:/usr/bin:/sbin:/bin"
[ -d "/usr/lib/git-core" ] \
                     && PATH="$PATH:/usr/lib/git-core"
[ -d "/Developer/usr/bin" ] \
                     && PATH="$PATH:/Developer/usr/bin"
[ -d "/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin" ] \
                     && PATH="$PATH:/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin"
[ -d ~/bin ] \
                     && PATH="$PATH:$HOME/bin"


export                  MANPATH="/usr/local/share/man:/usr/local/man"
[ -d "/sw" ]         && MANPATH="$MANPATH:/sw/share/man"
[ -d "/opt/local" ]  && MANPATH="$MANPATH:/opt/local/share/man:/opt/local/man"
[ -d "$EPREFIX"   ]  && MANPATH="$MANPATH:$(source "$EPREFIX/etc/profile.env"; echo "$MANPATH")"
                        MANPATH="$MANPATH:/usr/share/man:/usr/man"

#-------------------------#
# BASE - SECURITY         #
#-------------------------#
#umask 022


#-------------------------#
# BASE - APPLICATIONS     #
#-------------------------#
#export EDITOR="`type -P vim || type -P vi || type -P nano`"
export EDITOR="`whence -v vim || whence -v vi || whence -v nano`"


#-------------------------#
# ENVIRONMENT - LOCALE    #
#-------------------------#
printf -v langs '%s\n' en_{GB,US}{.utf8,.UTF-8,.iso88591,.ISO-8859-1,} C
read LANG < <(awk 'NR==FNR{a[$0];next}$0 in a' <(locale -a) <(echo "$langs"))
export LANG LC_COLLATE="C"
unset langs


#-------------------------#
# SHELL - CHECK TYPE      #
#-------------------------#
[[ $- != *i* ]] && return


#-----------------------------#
# ENVIRONMENT - APPLICATIONS  #
#-----------------------------#
exists lesspipe.sh && \
    export LESSOPEN="|lesspipe.sh %s"
export LESS="-i -M -R -W -S"
export GREP_COLOR=31
export NOSPLASH=1
export NOWELCOME=1


#-----------------------------#
# ENVIRONMENT - LOCAL CONFIG  #
#-----------------------------#
[ -r "$HOME/.profile.local" ] && \
    . "$HOME/.profile.local"
[ "$BASH_VERSION" ] && . "$HOME/.bashrc"