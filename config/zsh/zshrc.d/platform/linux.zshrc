# Custom bashrc script for Linux environment

# Command Aliases
alias ls='ls --color=auto -F'
alias l.='ls -d .* --color=auto'
alias yumup="sudo yum update"
alias dnfup="sudo dnf update"

# mkfile
mkfile=$(command -v mkfile)
xfs_mkfile=$(command -v xfs_mkfile)
if [ ! -x "${mkfile}" ] && [ -x "${xfs_mkfile}" ] ; then
	alias mkfile="${xfs_mkfile}"
fi

if [ -r  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] ; then
	source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Functions
function ips() {
	ip -o addr show scope global up | awk '{printf "%11s: %s\n", $2, $4}'
}
