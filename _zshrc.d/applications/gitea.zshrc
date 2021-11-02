local COMMAND=$(command -v docker)
[ ! -x "${COMMAND}" ] && return

alias tea='docker run --rm -v tea:/app -v $PWD:/repo:ro -w /repo tgerczei/tea'

unset COMMAND
