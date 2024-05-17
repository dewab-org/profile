is-executable gpg || return

export GNUPGHOME="${XDG_DATA_HOME}/gnupg"
is-directory ${GNUPGHOME} || mkdir -m 700 ${GNUPGHOME}
