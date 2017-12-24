TMUXINATOR=$(which tmuxinator 2> /dev/null)

# Have to do this because $fpath doesn't seem to work the way I thought it did

if [ -x "${TMUXINATOR}" ] ; then
	source ${HOME}/.zshrc.d/completions/_tmuxinator
fi
