function profile-up () {
	CURL="$(which curl 2> /dev/null)"
	WGET="$(which wget 2> /dev/null)"

	if [ -x "${CURL}" ] ; then
		GET="${CURL} -L -s"
	elif [ -x "${WGET}" ] ; then
		GET="${WGET} --quiet -O-"
	else
		echo "> Cannot find curl or wget"
		exit 1
	fi

	${GET} https://danielwhicker.com/profile/profile.sh | bash
}
