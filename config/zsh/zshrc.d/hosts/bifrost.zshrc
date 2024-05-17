# bifrost specific bashrc script

# Variables

# Command Aliases and Functions
function bans {
	for i in $(sudo ipset list -n)
	do
		echo -n "$i: "
		sudo ipset list $i | tail -n +8 | wc -l
	done
}

alias ban="sudo ipset add banned "

function firewalld-ban() {
	local OPTIND=""
	local CIDR=""
	local PERMANENT=""
	local FLAG=""
	local USAGE="
Usage:
ban: [-p] CIDR [CIDR...]
"

	if [ $# -eq 0 ] ; then
		echo "ban: at least one CIDR is required!"
		echo $USAGE
		return 1
	fi

	while getopts ":ph" FLAG ; do
		case $FLAG in
			p)	# make changes permanent and reload rules
				PERMANENT="--permanent"
				;;
			h)	# show usage
				echo $USAGE
				return 1
				;;
			\?)	# not sure what this is about
				echo "ban: unrecognized flag -${OPTARG}!"
				echo $USAGE
				return 1
			  	;;
		esac
	done

	shift $((OPTIND-1))

	# Add rules to firewall
	for CIDR in "$@" ; do
		sudo firewall-cmd $PERMANENT --zone=drop --add-source=$CIDR
	done

	# Reload rules once permanent changes are made to enable them
	if [ "$PERMANENT" ] ; then
                sudo firewall-cmd --reload
        fi
}
