_my_configured_interfaces ()
{
	#
	# The code in the base library does not seem to work with Darwin for some reason.
	#
	COMPREPLY=( $( compgen -W "$( /sbin/ifconfig | grep -E '^[^[:space:]]+:' | cut -d: -f1 )" -- "$cur" ) )
}

_ipconfig()
{
	local cur opts prev options profiles

	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	
	opts="waitall getifaddr ifcount getoption getpacket getv6packet set setverbose"

	case "${prev}" in
		getifaddr)
			_my_configured_interfaces
			return 0
		;;
		getoption)
			_my_configured_interfaces
			return 0
		;;
		set)
			_my_configured_interfaces
			return 0
		;;
		getpacket)
			_my_configured_interfaces
			return 0
		;;
		getv6packet)
			_my_configured_interfaces
			return 0
		;;
		*)
		;;
	esac

COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  	
return 0
}
complete -F _ipconfig ipconfig
