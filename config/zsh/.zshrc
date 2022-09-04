# Daniel's .zshrc
# 
# Directories:
# ~/.zshrc.d
# ~/.zshrc.d/global/*.zshrc			scripts for all hosts
# ~/.zshrc.d/hosts/<shortname>.zshrc		scripts for specific hostname (ex: bifrost, sunna, ragnarok)
# ~/.zshrc.d/platform/<platform>.zshrc	scripts for specific OS (ex: darwin, linux, sunos)
# ~/.zshrc.d/applications/<app>.zshrc		scripts for specific App (ex: veritas)
# ~/.zshrc.d/scripts/<script>.sh		scripts for use in support of profile scripts (ex: isiterm2.sh)
#

#
# Set some varibles for use in this script
#
hostname=${${HOST%%.*}:l} # replaces everything including and after the first . with nothing. Then lowercases it.
platform=${$(uname -s):l} # lowercases platform name

# For non-ineractive shells, only set the path and exit
# non-interative information moved to .zshenv

# Paths
cdpath=(. ~ / $HOME/Documents)
fpath=( $fpath $HOME/.zshrc.d/completions )

# History Paramters
# export HISTFILE=$HOME/.zsh_history
[ -d "${XDG_STATE_HOME}/zsh" ] || mkdir -p "${XDG_STATE_HOME}/zsh"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTSIZE=1000
export SAVEHIST=$HISTSIZE
export HISTORY_IGNORE="(ls|ll|bg|fg|clear|exit|history|history|cd|df)"

# Others
export CLICOLOR=true
export LESS="-X"
export FIGNORE="" # files and directories to ignore with tab-completion

#
# Configure Shell Options
#
setopt auto_cd                      # if command is a path, cd into it
setopt correct                      # try to correct spelling of commands
setopt append_history               # append
setopt complete_aliases             # make the alias a distinct command for completion purposes
setopt extended_history             # save timestamp of command and duration
setopt hist_ignore_dups             # Do not write events to history that are duplicates of previous events
setopt hist_reduce_blanks           # trim blanks
setopt nonomatch                    # match BASH glob behavior.  Pass wildcard to command if unmatched (as in scp blah:* .)

#
# Enable ZSH colors
#
autoload -U colors && colors

#
# Completion
#
[ -d "${XDG_CACHE_HOME}/zsh/zcompcache" ] || mkdir -p "${XDG_CACHE_HOME}/zsh/zcompcache"
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/zcompcache"

# Enable is-at-least plugin for version checking
autoload -Uz is-at-least

# Enable compinit command completion
autoload -U compinit && compinit

# Enable bash completion support
autoload -U +X bashcompinit && bashcompinit

# Initialize in XDG dir
compinit -d "${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"

# Enable completion list menu
zstyle ':completion:*' menu select
zmodload zsh/complist

# Separate tab completions into groups
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %d
zstyle ':completion:*:descriptions' format %B%d%b

# Add simple clors to kill tab completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# Have completion ignore case
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Highlight the current autocomplete option
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Better SSH/Rsync/SCP Autocomplete
zstyle ':completion:*:(scp|rsync):*' tag-order ' hosts:-ipaddr:ip\ address hosts:-host:host files'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Allow for autocomplete to be case insensitive
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|?=** r:|?=**'


#
# expand !^ !* !$ !:2 !$:h !$:t when you hit space 
#
# Doesn't appear that these apply to ZSH
#bind space:magic-space

#
# Functions
#
function is-executable () {
	[[ $+commands[$1] -gt 0 ]] || return 1
}

function is-supported () {
	# see if a command supports a command line option
	if [ $# -eq 1 ]; then
		if eval "$1" > /dev/null 2>&1; then
			return 0
		else
			return 1
		fi
	else
		if eval "$1" > /dev/null 2>&1; then
			echo -n "$2"
		else
			echo -n "$3"
		fi
	fi
}

function nix-host () {
	#
	# Remove host key from .ssh/known_hosts
	#
	if [ $# -eq 0 ] ; then
		echo "Usage: nix-host [hosts]"
		return 1
	fi
	#echo perl -ni -e \'print unless /^$1/\' ~/.ssh/known_hosts | sh
	local host
	for host in "$@" 
	do
	  echo "Removing ${host}... "
	  ssh-keygen -R "${host}"
	done
}

function pathmunge () {
	[ -d "$1" ] || return # Only do something if the path exists
	case ":${PATH}:" in
		*:"$1":*)
		;;
		*)
		if [ "$2" = "after" ] ; then
			PATH="$PATH:$1"
		else
			PATH="$1:$PATH"
		fi
	esac
}

function manpathmunge () {
	[ -d "$1" ] || return # Only do something if the path exists
	case ":${PATH}:" in
		*:"$1":*)
		;;
		*)
		if [ "$2" = "after" ] ; then
			MANPATH="$MANPATH:$1"
		else
			MANPATH="$1:$MANPATH"
		fi
	esac
}

function unpathmunge ()  {
	PATH=$(echo -n "$PATH" | awk  'BEGIN { RS=":"; ORS=":" } $0 != "'$1'" ')
	export PATH=${PATH/%:/}
}

function showpath () {
	#
	# Show path entries one per line
	# 
	echo "${PATH}" | tr ":" "\n"
}

function grepp () {
        #
        # Paragraph Grep
        #
        [ $# -eq 1 ] && perl -00ne "print if /$1/i" || perl -00ne "print if /$1/i" < "$2";
}

#
# Set My Paths
#

pathmunge /sbin after
pathmunge /usr/sbin after
pathmunge $HOME/bin after
pathmunge $HOME/.custom/$platform/bin after
pathmunge $HOME/.custom/$platform/sbin after
pathmunge /usr/X11R6/bin after
pathmunge /usr/local/bin after
pathmunge /usr/local/sbin after
pathmunge /opt/local/bin after
pathmunge /opt/local/sbin after

manpathmunge /usr/man
manpathmunge $HOME/man after
manpathmunge $HOME/.custom/$platform/man after
manpathmunge $HOME/.custom/$platform/share/man after
manpathmunge /usr/share/man after
manpathmunge /usr/local/man after
manpathmunge /usr/local/share/man after
manpathmunge /usr/X11R6/man after
manpathmunge /opt/local/man after

#
# Aliases
#

alias ls='ls -F'
alias ll='ls -alh'
alias l.='ls -d .*' 
alias cpan="sudo perl -MCPAN -e shell"
alias nslookup='/usr/bin/nslookup -sil'
alias grpe='grep'
alias rb='source ${ZDOTDIR}/.zshrc'
#alias ipgrep="grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'"
alias ipgrep="grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'"
alias mailgrep="grep -Eo '\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\b'"
alias sortcount="sort | uniq -c | sort -n"
alias sudo='sudo ' # If the last character of the alias value is a blank, then the next command word following the alias is also checked for alias expansion.
#alias whatismyip='curl http://aws-1.bifrost.cc/whatismyip.php ; echo '
alias whatismyip='dig +short myip.opendns.com @resolver1.opendns.com'

#
# Run all application global zshrc scripts from $HOME/.zshrc.d/global/ (ex: prompt, colors, etc.)
#

for globalscript in ${ZDOTDIR}/zshrc.d/global/*.zshrc ; do
  source "${globalscript}"
done
unset globalscript

#
# Run platform specific zshrc scripts from $HOME/.zshrc.d/platform/ (ex: darwin, sunos, linux)
#

if [ -r "${ZDOTDIR}/zshrc.d/platform/${platform}.zshrc" ] ; then
	source "${ZDOTDIR}/zshrc.d/platform/${platform}.zshrc"
fi

#
# Run host specific zshrc scripts from $HOME/.zshrc.d/hosts/ (ex: bifrost, sunna, ragnarok)
#

if [ -r "${ZDOTDIR}/zshrc.d/hosts/${hostname}.zshrc" ] ; then
	source "${ZDOTDIR}/zshrc.d/hosts/${hostname}.zshrc"
fi

#
# Run all application specific zshrc scripts from $HOME/.zshrc.d/applications/ (ex: veritas)
#

for application in ${ZDOTDIR}/zshrc.d/applications/*.zshrc ; do
	source "${application}"
done
unset application

#
# Set the EDITOR variable
#
export EDITOR=$(command -v vim)
if [ ! -x "$EDITOR" ] ; then
	export EDITOR=$(command -v vi)
fi

#
# Switch back to Emacs mode (changing editor switches to VI-mode for some stupid reason)
#
bindkey -e

#
# Change ctrl+u to kill to front of line
#
bindkey '^U' backward-kill-line

#
# Cntrl+X E to edit the command line in editor
#
autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line

#
# Create socket directory for SSH ControlPath
#
[ -d ~/.ssh/cm_socket ] || ( mkdir ~/.ssh/cm_socket ; chmod 0700 ~/.ssh/cm_socket )
