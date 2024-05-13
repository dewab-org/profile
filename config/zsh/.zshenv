#
# .zshenv is set for all sessions, login and non-interactive
#

#
# Set some varibles for use in this script
#
hostname=${HOST%%.*} # replaces everything including and after the first . with nothing.
platform=${$(uname -s):l} # lowercases platform name

#
# Reset to default path if getconf is present
#
[[ $+commands[getconf] -gt 0 ]] && export PATH="$(getconf PATH)"

#
# Configure XDG Variables
#
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export XDG_DATA_HOME=${HOME}/.local/share
export XDG_STATE_HOME=${HOME}/.local/state

# Create XDG dirs if they don't exist
for XDG_PATH in $XDG_CONFIG_HOME $XDG_CACHE_HOME $XDG_DATA_HOME $XDG_STATE_HOME
do
	[ -d "${XDG_PATH}" ] || mkdir -m 0700 -p "${XDG_PATH}"
done

#
# Set ZSH Configuration Root
#
export ZDOTDIR=${XDG_CONFIG_HOME}/zsh

#
# For non-ineractive shells, only set the path and exit
#
if [[ ! -o interactive ]]; then
    for dir in /usr/bin /usr/sbin /usr/*/bin/ ~/bin ~/.custom/$platform/bin /opt/homebrew/bin; do
        [ -d "${dir}" ] && export PATH="$PATH:$dir"
    done
    unset dir
    return
fi
