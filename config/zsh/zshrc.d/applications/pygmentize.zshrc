is-executable pygmentize || return

alias ccat="pygmentize -g"

is-executable less_py_filter.sh &&  alias cless='LESSOPEN="|less_py_filter.sh %s" less -R'

export LESSOPEN="| pygmentize %s"
LESS+=" -R"
