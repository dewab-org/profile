#
# .zshenv is set for all sessions, login and non-interactive
#

#
# Set some varibles for use in this script
#
hostname=${HOST%%.*} # replaces everything including and after the first . with nothing.
platform=$(uname -s | tr "[A-Z]" "[a-z]")

#
# Set ZSH Configuration Root
#
export ZDOTDIR=${HOME}/.config/zsh

#
# Configure XDG Variables
#
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export XDG_DATA_HOME=${HOME}/.local/share
export XDG_STATE_HOME=${HOME}/.local/state

# Create XDG dirs if they'd exist
for XDG_PATH in $XDG_CONFIG_HOME $XDG_CACHE_HOME $XDG_DATA_HOME $XDG_STATE_HOME
do
	[ -d "${XDG_PATH}" ] || mkdir -p "${XDG_PATH}"
done

#
# For non-ineractive shells, only set the path and exit
#
if [[ ! -o interactive ]]; then
    for dir in /usr/bin /usr/sbin /usr/*/bin/ ~/bin ~/.custom/$platform/bin /brew/bin; do
        [ -d "${dir}" ] || return
        export PATH="$PATH:$dir"
    done
    unset dir
    return
fi
