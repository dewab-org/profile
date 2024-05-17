# Turn on prompt performance checking if enabled
[ -z "$ZPROF" ] || zmodload zsh/zprof

# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && . "$HOME/.fig/shell/zshrc.pre.zsh"

# Daniel's .zshrc
#
# Directories:
# ~/.zshrc.d
# ~/.zshrc.d/global/*.zshrc				scripts for all hosts
# ~/.zshrc.d/hosts/<shortname>.zshrc	scripts for specific hostname (ex: bifrost, sunna, ragnarok)
# ~/.zshrc.d/platform/<platform>.zshrc	scripts for specific OS (ex: darwin, linux, sunos)
# ~/.zshrc.d/applications/<app>.zshrc	scripts for specific App (ex: veritas)
# ~/.zshrc.d/scripts/<script>.sh		scripts for use in support of profile scripts (ex: isiterm2.sh)

# Set some varibles for use in this script
hostname=${${HOST%%.*}:l} # replaces everything including and after the first . with nothing. Then lowercases it.
platform=${$(uname -s):l} # lowercases platform name

# Set ZSH Cache Directories
ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
[ -d "${ZSH_CACHE_DIR}/completions" ] || mkdir -m 0700 -p "${ZSH_CACHE_DIR}/completions"
[ -d "${XDG_CACHE_HOME}/zsh" ] || mkdir -m 0700 -p "${XDG_CACHE_HOME}/zsh"

# Set ZSH Comp Dump
ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}-${hostname}"

# Set ZSH Sessions Dir
export SHELL_SESSION_DIR="${XDG_STATE_HOME}/zsh/sessions"
export SHELL_SESSION_FILE="${SHELL_SESSION_DIR}/${TERM_SESSION_ID}"
[ -d "${SHELL_SESSION_DIR}" ] || mkdir -m 0700 -p "${SHELL_SESSION_DIR}"

# Prevent duplicate entries in path
declare -U path

# Paths
cdpath=( . ~ / ${HOME}/Documents )
fpath+=( "${ZDOTDIR}/zshrc.d/functions" )
(( ${fpath[(Ie)"${ZSH_CACHE_DIR}/completions"]} )) || fpath+=("${ZSH_CACHE_DIR}/completions" )

# History Paramters
[ -d "${XDG_STATE_HOME}/zsh" ] || mkdir -m 0700 -p "${XDG_STATE_HOME}/zsh"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTSIZE=1000
export SAVEHIST=${HISTSIZE}
export HISTORY_IGNORE="(ls|ll|l.|bg|fg|clear|exit|history|cd|df)"

# Others
export CLICOLOR=true
export LESS="-X"
export FIGNORE="" # files and directories to ignore with tab-completion

# Configure Shell Options (setopt)
# auto_cd				# if command is a path, cd into it
# correct				# try to correct spelling of commands
# append_history		# append
# complete_aliases		# make the alias a distinct command for completion purposes
# extended_history		# save timestamp of command and duration
# hist_ignore_dups		# Do not write events to history that are duplicates of previous events
# hist_reduce_blanks	# trim blanks
# nonomatch				# match BASH glob behavior.  Pass wildcard to command if unmatched (as in scp blah:* .)
# prompt_subst			# allow prompt expansion of vars
setopt auto_cd correct append_history complete_aliases extended_history hist_ignore_dups hist_reduce_blanks nonomatch prompt_subst

# Change paths to only store unique entries
typeset -aU path fpath manpath cdpath

# Enable ZSH colors
autoload -U colors && colors

# Completion
[ -d "${XDG_CACHE_HOME}/zsh/zcompcache" ] || mkdir -m 0700 -p "${XDG_CACHE_HOME}/zsh/zcompcache"
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/zcompcache"

# Enable is-at-least plugin for version checking
autoload -Uz is-at-least

# Enable compinit command completion
# autoload -U compinit # && compinit
autoload -Uz compinit # && compinit -C -d "${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"

# Enable strftime
zmodload zsh/datetime

# Function to check and rebuild completion database if necessary
function check_and_rebuild_compdb() {
    local db_timestamp

    if [ "$platform" = "darwin" ]; then
        db_timestamp=$(command stat -f '%Dm' "${ZSH_COMPDUMP}")
    else
        db_timestamp=$(command stat "${ZSH_COMPDUMP}" -c %Y)
    fi

    if [ "$(strftime "%j" "${EPOCHSECONDS}")" != "$(strftime "%j" "${db_timestamp}")" ]; then
        compinit -d "${ZSH_COMPDUMP}" && touch "${ZSH_COMPDUMP}"
    else
        compinit -C -d "${ZSH_COMPDUMP}"
    fi
}

check_and_rebuild_compdb

# Enable bash completion support
autoload -U +X bashcompinit && bashcompinit

# Enable my functions
# autoload -Uz action && action
autoload -Uz paths && paths
autoload -Uz nix-host
autoload -Uz grepp
autoload -Uz is && is
autoload -Uz convert_seconds
autoload -Uz convert_seconds_human_readable
autoload -Uz rules && rules
autoload -Uz lsz

# Enable completion list menu
zstyle ':completion:*' menu select
zmodload zsh/complist

# Separate tab completions into groups
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %d
zstyle ':completion:*:descriptions' format %B%d%b

# Add simple colors to kill tab completion
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

# expand !^ !* !$ !:2 !$:h !$:t when you hit space
# Doesn't appear that these apply to ZSH
#bind space:magic-space

# Set My Paths
append_path PATH /sbin
append_path PATH /usr/sbin
append_path PATH ${HOME}/bin
append_path PATH ${HOME}/.custom/${platform}/bin
append_path PATH ${HOME}/.custom/${platform}/sbin
append_path PATH ${HOME}/.local/bin
append_path PATH /usr/X11R6/bin
append_path PATH /usr/local/bin
append_path PATH /usr/local/sbin
append_path PATH /opt/local/bin
append_path PATH /opt/local/sbin
append_path PATH /opt/homebrew/bin
append_path PATH /snap/bin
append_path MANPATH /usr/man
append_path MANPATH ${HOME}/man
append_path MANPATH ${HOME}/.custom/${platform}/man
append_path MANPATH ${HOME}/.custom/${platform}/share/man
append_path MANPATH ${HOME}/.local/man
append_path MANPATH /usr/share/man
append_path MANPATH /usr/local/man
append_path MANPATH /usr/local/share/man
append_path MANPATH /usr/X11R6/man
append_path MANPATH /opt/local/man
append_path MANPATH /opt/homebrew/man
append_path MANPATH /snap/man

# Miscallaneous Vars
export BORG_REPO="ssh://borg/./"

# Aliases
alias ls='ls -F'
alias ll='ls -alh'
alias l.='ls -d .*'
alias la='ls -a'
alias cpan="sudo perl -MCPAN -e shell"
alias nslookup='/usr/bin/nslookup -sil'
alias grpe='grep'
alias rb='source ${ZDOTDIR}/.zshrc'
alias ipgrep="grep -Eo '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'"
alias mailgrep="grep -Eo '\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\b'"
alias sortcount="sort | uniq -c | sort -n"
alias sudo='sudo ' # If the last character of the alias value is a blank, then the next command word following the alias is also checked for alias expansion.
alias whatismyip='dig +short myip.opendns.com @resolver1.opendns.com'

# Run all application global zshrc scripts from $HOME/.zshrc.d/global/ (ex: prompt, colors, etc.)
for globalscript in ${ZDOTDIR}/zshrc.d/global/*.zshrc ; do
  source "${globalscript}"
done
unset globalscript

# Run platform specific zshrc scripts from $HOME/.zshrc.d/platform/ (ex: darwin, sunos, linux)
if [ -r "${ZDOTDIR}/zshrc.d/platform/${platform}.zshrc" ] ; then
	source "${ZDOTDIR}/zshrc.d/platform/${platform}.zshrc"
fi

# Run host specific zshrc scripts from $HOME/.zshrc.d/hosts/
if [ -r "${ZDOTDIR}/zshrc.d/hosts/${hostname}.zshrc" ] ; then
	source "${ZDOTDIR}/zshrc.d/hosts/${hostname}.zshrc"
fi

# Run all application specific zshrc scripts from $HOME/.zshrc.d/applications/ (ex: veritas)
for application in ${ZDOTDIR}/zshrc.d/applications/*.zshrc ; do
	source "${application}"
done
unset application

# Set the EDITOR variable
is-executable vim && export EDITOR=$(command -v vim)

# Switch back to Emacs mode (changing editor switches to VI-mode for some stupid reason)
bindkey -e

# Change ctrl+u to kill to front of line
bindkey '^U' backward-kill-line

# Cntrl+X E to edit the command line in editor
autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line

# Create socket directory for SSH ControlPath
# [ -d ~/.ssh/cm_socket ] || mkdir -m 0700 -p ~/.ssh/cm_socket
is-directory ~/.ssh/cm_socket || mkdir -m 0700 -p ~/.ssh/cm_socket

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && . "$HOME/.fig/shell/zshrc.post.zsh"

[ -z "$ZPROF" ] || zprof
