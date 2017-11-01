_mas()
{
	local cur opts
	
	cur="${COMP_WORDS[COMP_CWORD]}"

	opts="account help install list outdated reset search signin signout upgrade version"

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
	return 0
}

complete -F _mas mas
