#
# Daniel's Action Script Reporting
#

#if [ -z "$PS1" ] ; then
if [[ $- =~ i ]] ; then
	RES_COL=60
else
	RES_COL=$(expr $(tput cols) - 10)
fi
MOVE_TO_COL="\\033[${RES_COL}G"

action() {
	local STRING rc

	STRING=$1
	print -n "$STRING "
	shift
	eval "$@" && success $"$STRING" || failure $"$STRING"
	rc=$?
	return $rc
}

success() {
	print -n ${MOVE_TO_COL}
	print "[$fg[green]  OK  $reset_color]"
	return 0
}

failure() {
	print -n ${MOVE_TO_COL}
	print "[$fg[red]FAILED$reset_color]"
	return 0
}
