[[ $+commands[pygmentize] -lt 1 ]] && return

 alias ccat="pygmentize -g"

if [ -x "$(command -v less_py_filter.sh)" ] ; then
  alias cless='LESSOPEN="|less_py_filter.sh %s" less -R'
fi

export LESSOPEN="| pygmentize %s"
export LESS="$LESS -R"