ANSIBLE=$(which ansible 2>/dev/null)

if [ -x "${ANSIBLE}" ] ; then
	ANS_PIP="$(dirname $( head -1 $(which ansible) | sed -e 's/^\#\!//' ))/pip"
	alias ansible-pip="${ANS_PIP}"
fi
