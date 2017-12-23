if [ -f ~/.fzf.bash ] ; then

	#
	# Unconfigure bash-completion for kill command to allow for fzf's kill tab completion
	unset -f _kill

	source ~/.fzf.bash

	#
	# Split the tmux screen horizontally at 50% when fzf is in use
	#
	export FZF_TMUX_HEIGHT="50%"
fi
