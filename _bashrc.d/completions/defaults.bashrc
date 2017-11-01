## Bash completion for `defaults` domains
## e.g. `defaults read com.apple[TAB]`

_complete_domain ()
{
	local cur
	local LC_ALL='C'
	cur=${COMP_WORDS[COMP_CWORD]}
	cur=${cur//\./\\\.} # escape dots for grep
	local IFS="
"
	COMPREPLY=( $(defaults domains | tr ',' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//'|grep -i "^$cur") )
	return 0
}

complete -o bashdefault -o default -o nospace -F _complete_domain defaults 2>/dev/null || complete -o default -o nospace -F _complete_domain defaults
