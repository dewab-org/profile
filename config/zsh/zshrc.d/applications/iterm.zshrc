# Only run iTerm integration if the terminal is iTerm
#
# https://iterm2.com/shell_integration/bash
# https://iterm2.com/shell_integration/zsh
# https://iterm2.com/utilities/it2check

IT2CHECK="${ZDOTDIR}/zshrc.d/scripts/it2check"
ITERM_INTEGRATION="${ZDOTDIR}/zshrc.d/scripts/iterm_integration.sh"

# Check if using Linux on Windows, and if so skip iterm checking as it locks the terminal for some reason
(( ${$(uname -r)[(Ie)microsoft]} )) && return

# Check if running inside of a tmux session, and if so skip iterm checking as it doesn't like tmux start scripts
[ -n "${TMUX}" ] && return

# Bail unless both helper scripts are present.
[ -x "${IT2CHECK}" ] && [ -x "${ITERM_INTEGRATION}" ] || return

# Only load the integration when it2check confirms a real iTerm2. Previously the
# script sourced unconditionally (it2check's result was assigned to ITERM but never
# used to gate), so the integration ran in Terminal.app, Ghostty, etc. too — leaking
# OSC 1337 / FTCS prompt-mark escapes (a stray prompt mark and extra line, made worse
# alongside starship). Outside iTerm2, it2check exits non-zero and we bail here.
"${IT2CHECK}" || return
ITERM=true

# Run the iterm integration script
source "${ITERM_INTEGRATION}"

function iterm-up () {
	# Download and replace the iTerm bash shell integration script
	mv "${ITERM_INTEGRATION}" "${ITERM_INTEGRATION}-$(date +%Y-%m-%d)"
	curl -L https://iterm2.com/shell_integration/zsh -o "${ITERM_INTEGRATION}"
	chmod 700 "${ITERM_INTEGRATION}"
}

###
# Executes an arbitrary iTerm2 command via an escape code sequence.
# See https://iterm2.com/documentation-escape-codes.html for all supported commands.
# Example: $ _iterm2_command "1337;StealFocus"
function _iterm2_command() {
	local cmd="$1"

	# Escape codes for wrapping commands for iTerm2.
	local iterm2_prefix="\x1B]"
	local iterm2_suffix="\x07"

	# If we're in tmux, a special escape code must be prepended/appended so that
	# the iTerm2 escape code is passed on into iTerm2.
	if [[ -n $TMUX ]]; then
		local tmux_prefix="\x1BPtmux;\x1B"
		local tmux_suffix="\x1B\\"
	fi

	echo -n "${tmux_prefix}${iterm2_prefix}${cmd}${iterm2_suffix}${tmux_suffix}"
}

###
# iterm2_profile(): Function for changing the current terminal window's
# profile (colors, fonts, settings, etc).
# To change the current iTerm2 profile, call this function and pass in a name
# of another existing iTerm2 profile (name can contain spaces).
function iterm2_profile() {
	# Desired name of profile
	local profile="$1"

	# iTerm2 command for changing profile
	local cmd="1337;SetProfile=$profile"

	# send the sequence
	_iterm2_command "${cmd}"

	# update shell variable
	ITERM_PROFILE="$profile"
}

###
# iterm2_tab_color(): Changes the color of iTerm2's currently active tab.
# Usage: iterm2_tab_color <red> <green> <blue>
#        where red/green/blue are on the range 0-255.
function iterm2_tab_color() {
	_iterm2_command "6;1;bg;red;brightness;$1"
	_iterm2_command "6;1;bg;green;brightness;$2"
	_iterm2_command "6;1;bg;blue;brightness;$3"
}


###
# iterm2_tab_color_reset(): Resets the color of iTerm2's current tab back to
# default.
function iterm2_tab_color_reset() {
	_iterm2_command "6;1;bg;*;default"
}
