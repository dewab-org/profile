# Only run iTerm integration if the terminal is iTerm

ISITERM="${HOME}/.bashrc.d/scripts/isiterm2.sh"
ITERM_INTEGRATION="${HOME}/.bashrc.d/scripts/iterm_integration.sh"
IS_WINDOWS="$(uname -r | awk -F- '{print $NF}' | tr [A-Z] [a-z])"

# Using isiterm2.sh to determine whether the connected terminal is iTerm or not
if [ -x "${ISITERM}" ] &&  [ -x "${ITERM_INTEGRATION}" ]
then
	${ISITERM} && ITERM=true

fi

if [ "${IS_WINDOWS}" = "microsoft" ]
then
	ITERM=false
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
