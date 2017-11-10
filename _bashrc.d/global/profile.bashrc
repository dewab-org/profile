function _profile_up_web () {
	CURL="$(which curl 2> /dev/null)"
	WGET="$(which wget 2> /dev/null)"

	if [ -x "${CURL}" ] ; then
		GET="${CURL} -L -s"
	elif [ -x "${WGET}" ] ; then
		GET="${WGET} --quiet -O-"
	else
		echo "X Cannot find curl or wget"
		return 1
	fi

	${GET} https://danielwhicker.com/profile/profile.sh | bash
}

function _profile_up_git () {
	GIT="$(which git 2> /dev/null)"
	
	if [ ! -x "${GIT}" ] ; then
		echo "X Cannot find git"
		return 1
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

function profile-publishable () {
	GIT="$(which git 2> /dev/null)"
	
	if [ ! -x "${GIT}" ] ; then
		echo "X Cannot find git"
		return 1
	fi

	${GIT} -C "${HOME}/.profile.d" remote set-url --push origin git@aws-1.bifrost.cc:/var/lib/git/profile.git
	${GIT} -C "${HOME}/.profile.d" remote -v

	${GIT} -C "${HOME}/.custom/${platform}/" remote set-url --push origin git@aws-1.bifrost.cc:/var/lib/git/custom.${platform}.git
	${GIT} -C "${HOME}/.custom/${platform}/" remote -v
}

function profile-reset () {
	GIT="$(which git 2> /dev/null)"
	
	if [ ! -x "${GIT}" ] ; then
		echo "X Cannot find git"
		return 1
	fi

	local URL=$(${GIT} -C ~/.profile.d/ remote get-url origin)
	echo "> reseting profile using ${URL}"
	${GIT} -C "${HOME}/.profile.d" reset --hard origin/master

	local URL=$(${GIT} -C ~/.custom/${platform}/ remote get-url origin)
	echo "> reseting profile using ${URL}"
	${GIT} -C "${HOME}/.custom/${platform}" reset --hard origin/master
}

function _profile_changes_git_push () {
	# I need to add error/sanity checking
	GITREPO=$1
	
	echo "> Checking for swap files in ${GITREPO}"
	# Check for vi(m) swap files first
	local SWAPS=$(find ${GITREPO} -type f -name "*.swp")
	if [ -n "${SWAPS}" ] ; then
		echo "X Swap files exist.  Bailling until you clean up / finish."
		echo "Swap Files:"
		echo "${SWAPS}"
		echo ""
		return 1
	fi

	local URL=$(${GIT} -C ${GITREPO} remote get-url --push origin)
        echo "> Sending changes to ${URL}"

        # Add any new files
        git -C "${GITREPO}" add .

        # Commits changes after launching an interactive VI(M) session
        git -C "${GITREPO}" commit

        # Push the changes to the git repo
        git -C "${GITREPO}" push origin master	
}

function profile-changes () {
	GIT="$(which git 2> /dev/null)"

        if [ ! -x "${GIT}" ] ; then
                echo "X Cannot find git"
                return 1
        fi
	
	_profile_changes_git_push "${HOME}/.profile.d" 
}

function custom-changes () {
	GIT="$(which git 2> /dev/null)"

        if [ ! -x "${GIT}" ] ; then
                echo "X Cannot find git"
                return 1
        fi
	
	_profile_changes_git_push "${HOME}/.custom/${platform}"
}
