ASSH=$(which assh 2>/dev/null)

if [ -x "${ASSH}" ]  ; then
	alias ssh="${ASSH} wrapper ssh"
fi
