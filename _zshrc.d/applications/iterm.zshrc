# Only run iTerm integration if the terminal is iTerm
#
# https://iterm2.com/shell_integration/bash
# https://github.com/gnachman/iterm2-website/blob/master/source/utilities/it2check

IT2CHECK="${HOME}/.bashrc.d/scripts/it2check"
ITERM_INTEGRATION="${HOME}/.bashrc.d/scripts/iterm_integration.sh"
IS_WINDOWS="$(uname -r | awk -F- '{print $NF}' | tr \[A-Z\] \[a-z\])"

# Check if using Linux on Windows, and if so skip iterm checking as it locks the terminal for some reason
if [ "${IS_WINDOWS}" = "microsoft" ]
then
	return
fi

# Check if running inside of a tmux session, and if so skip iterm checking as it doesn't like tmux start scripts
if [ -n "${TMUX}" ]
then
	return
fi

# Using isiterm2.sh to determine whether the connected terminal is iTerm or not
if [ -x "${IT2CHECK}" ] &&  [ -x "${ITERM_INTEGRATION}" ]
then
	${IT2CHECK} && ITERM=true

fi

if [ "${ITERM}" = "true" ]
then
	# Run the iterm integration script
	${ITERM_INTEGRATION}

	function iterm-up () {
		# Download and replace the iTerm bash shell integration script
		mv "${ITERM_INTEGRATION}" "${ITERM_INTEGRATION}-$(date +%Y-%m-%d)"
		curl -L https://iterm2.com/misc/bash_startup.in -o "${ITERM_INTEGRATION}"
		chmod 700 "${ITERM_INTEGRATION}"
	}

fi
