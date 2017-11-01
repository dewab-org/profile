#_unison_show()
#{
#        local cur
#
#        COMPREPLY=()
#        cur=${COMP_WORDS[COMP_CWORD]}
#        COMPREPLY=($( compgen -W "$(for x in ~/.unison/*.prf; do echo $(basename ${x%.prf}); done)" -- $cur ) )
#}
#complete -F _unison_show unison

_unison()
{
	local cur opts prev options profiles

	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	
	options="-version -ui -doc -auto -batch -silent -terse -path -root"
	profiles="$(for x in ~/.unison/*.prf; do echo $(basename ${x%.prf}); done)"

	opts="$options $profiles"

	case "${prev}" in
		-ui)
			COMPREPLY=( $(compgen -W "graphic text" -- $cur ) )
			return 0
		;;

		-root)
			_filedir -d
			return 0
		;;

		-path)
			_filedir -d
			return 0
		;;

		*)
		;;
	esac

COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  	
return 0
}
complete -F _unison unison
