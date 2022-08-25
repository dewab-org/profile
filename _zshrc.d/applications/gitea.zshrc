[[ $+commands[docker] -lt 1 ]] && return

alias tea='docker run --rm -v tea:/app -v $PWD:/repo:ro -w /repo tgerczei/tea'