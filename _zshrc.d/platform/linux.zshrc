# Custom bashrc script for Linux environment

# Command Aliases
alias ls='ls --color=auto -F'
alias l.='ls -d .* --color=auto'
alias yumup="sudo yum update"

# mkfile
mkfile=$(command -v mkfile)
xfs_mkfile=$(command -v xfs_mkfile)
if [ ! -x "${mkfile}" ] && [ -x "${xfs_mkfile}" ] ; then
	alias mkfile="${xfs_mkfile}"
fi

# Bash Completion
if [ -x "/etc/bash_completion" ] ; then
	source /etc/bash_completion
fi
