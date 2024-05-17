is-executable less || return

LESS_VERSION=$(less --version | head -1 | cut -d" " -f2)
is-at-least 590 $LESS_VERSION || export LESSHISTFILE="${XDG_CACHE_HOME}/less_history"
unset LESS_VERSION
