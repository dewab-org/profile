#
# Unconfigure bash-completion for kill command to allow for fzf's kill tab completion
unset -f _kill

# Setup fzf
# ---------
#if [[ ! "$PATH" =~ "/Users/Daniel/work/fzf/bin" ]]; then
#  export PATH="$PATH:/Users/Daniel/work/fzf/bin"
#fi

# Man path
# --------
#if [[ ! "$MANPATH" =~ "/Users/Daniel/work/fzf/man" && -d "/Users/Daniel/work/fzf/man" ]]; then
#  export MANPATH="$MANPATH:/Users/Daniel/work/fzf/man"
#fi
#
if [[ -d "/brew/opt/fzf/" ]] ; then

# Auto-completion
# ---------------
[[ $- =~ i ]] && source /brew/opt/fzf/shell/completion.bash 2> /dev/null

# Key bindings
# ------------
source /brew/opt/fzf/shell/key-bindings.bash

#
# Split the tmux screen horizontally at 50% when fzf is in use
#
export FZF_TMUX_HEIGHT="50%"

fi
