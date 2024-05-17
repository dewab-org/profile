is-executable tmux || return
is-executable tmuxinator && alias mux=tmuxinator

autoload -Uz tm
