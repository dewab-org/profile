_lsz() 
{
	local cur prev 
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	_filedir "@(tar|zip|tar.gz|tgz|tar.bz2|tbz2|rar|cbz|cbr|7z)"

}
complete -F _lsz lsz
