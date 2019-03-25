local ONEPASSWORD=$(command -v op)
[ ! -x "${ONEPASSWORD}" ] && return

export OP_SESSION_FILE=~/.op_session

function op-signin {
	export OP_SESSION_dwhicker="$("${ONEPASSWORD}" signin --output=raw)"
	echo "${OP_SESSION_dwhicker}" > "${OP_SESSION_FILE}"
}

function op-eval {
	export OP_SESSION_dwhicker="$(cat "$OP_SESSION_FILE")"
}

# Read file on login
[ -f "${OP_SESSION_FILE}" ] && op-eval
