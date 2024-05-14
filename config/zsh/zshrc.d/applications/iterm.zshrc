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

# Using isiterm2.sh to determine whether the connected terminal is iTerm or not
if [ -x "${IT2CHECK}" ] &&  [ -x "${ITERM_INTEGRATION}" ]
then
	${IT2CHECK} && ITERM=true
fi

if [ "${ITERM}" = "true" ]
then
	# Run the iterm integration script
	source ${ITERM_INTEGRATION}

	function iterm-up () {
		# Download and replace the iTerm bash shell integration script
		mv "${ITERM_INTEGRATION}" "${ITERM_INTEGRATION}-$(date +%Y-%m-%d)"
		curl -L https://iterm2.com/shell_integration/zsh -o "${ITERM_INTEGRATION}"
		chmod 700 "${ITERM_INTEGRATION}"
	}

fi
