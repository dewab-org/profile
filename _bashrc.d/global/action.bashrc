#
# Daniel's Action Script Reporting
#

#if [ -z "$PS1" ] ; then
if [[ $- =~ i ]] ; then
	RES_COL=60
else
	RES_COL=$(expr $(tput cols) - 10)
fi
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

action() {
	local STRING rc

	STRING=$1
	echo -n "$STRING "
	shift
	"$@" && success $"$STRING" || failure $"$STRING"
	rc=$?
	echo
	return $rc
}

success() {
	$MOVE_TO_COL
	echo -n "["
	$SETCOLOR_SUCCESS
	echo -n $"  OK  "
	$SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 0
}

failure() {
	$MOVE_TO_COL
	echo -n "["
	$SETCOLOR_FAILURE
	echo -n $"FAILED"
	$SETCOLOR_NORMAL
	echo -n "]"
	echo -ne "\r"
	return 0
}
