function _profile_up_web () {
	CURL="$(which curl 2> /dev/null)"
	WGET="$(which wget 2> /dev/null)"

	if [ -x "${CURL}" ] ; then
		GET="${CURL} -L -s"
	elif [ -x "${WGET}" ] ; then
		GET="${WGET} --quiet -O-"
	else
		echo "X Cannot find curl or wget"
		exit 1
	fi

	${GET} https://danielwhicker.com/profile/profile.sh | bash
}

function _profile_up_git () {
	GIT="$(which git 2> /dev/null)"
	
	if [ ! -x "${GIT}" ] ; then
		echo "X Cannot find git"
		exit 1
	fi

	# Git profile
	local URL=$(${GIT} -C ~/.profile.d/ remote get-url origin)
	echo "> updating profile using ${URL}"
	${GIT} -C "${HOME}/.profile.d/" pull

	# Git binaries
	local URL=$(${GIT} -C ~/.custom/${platform}/ remote get-url origin)
	echo "> updating profile using ${URL}"
	${GIT} -C "${HOME}/.custom/${platform}/" pull
}

function profile-up () {
	if [ -d "${HOME}/.profile.d/.git" ] ; then
		echo "* Updating profile using git."
		_profile_up_git
	else
		echo "* Updating profile using web."
		_profile_up_web
	fi
}

function profile-reset () {
	GIT="$(which git 2> /dev/null)"
	
	if [ ! -x "${GIT}" ] ; then
		echo "X Cannot find git"
		exit 1
	fi

	local URL=$(${GIT} -C ~/.profile.d/ remote get-url origin)
	echo "> reseting profile using ${URL}"
	${GIT} -C "${HOME}/.profile.d" reset --hard origin/master

	local URL=$(${GIT} -C ~/.custom/${platform}/ remote get-url origin)
	echo "> reseting profile using ${URL}"
	${GIT} -C "${HOME}/.custom/${platform}" reset --hard origin/master
}

function profile-changes () {
	# IN PROGRESS
	GIT="$(which git 2> /dev/null)"

        if [ ! -x "${GIT}" ] ; then
                echo "X Cannot find git"
                exit 1
        fi
	
	# Check for vi(m) swap files first
	local SWAPS=$(find ~/.profile -type f -name "*.swp")
	if [ -n "$SWAPS" ] ; then
		echo "X Swap files exist.  Bailling until you clean up / finish."
		exit 1
	fi

	local URL=$(${GIT} -C ~/.profile.d/ remote get-url --push origin)	
	echo "> Sending changes to ${URL}"
}
