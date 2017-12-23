PYGMENTIZE="$(which pygmentize 2> /dev/null)"

if [ -x "${PYGMENTIZE}" ] ; then
        alias ccat="${PYGMENTIZE} -g"

	if [ -x "$(which less_py_filter.sh)" ] ; then
		alias cless='LESSOPEN="|less_py_filter.sh %s" less -R'
	fi
fi

unset PYGMENTIZE
