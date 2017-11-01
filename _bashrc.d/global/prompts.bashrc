#
# Prompts Script
#
_normal_prompt () {
        #
        # Non-Colorized Prompt
        #
	history -a

        PS1="[\!][\u@\h \W${WINDOW:+ ($WINDOW)}]\\$ "
        SUDO_PS1="[\!][\u@\h \W${WINDOW:+ ($WINDOW)}]# "
        if [ -n "$SSH_CONNECTION" ] ; then
                PS1="[SSH]"$PS1
        fi

}

_color_prompt () {
	# set an error string for the prompt, if applicable
	if [ $? -eq 0 ]
	then 
		ERRPROMPT=" "
	else
		ERRPROMPT='->($?) '
	fi

	history -a

	case "$hostname" in
		snotra)         HOSTCOLOR=${Pur} ;;
		uller)		HOSTCOLOR=${Blu} ;;
		uller-wifi)	HOSTCOLOR=${Blu} ;;
		bifrost)        HOSTCOLOR=${Cya} ;;
		*)              HOSTCOLOR=${RCol} ;;
	esac

	case "$USER" in
		Daniel)		USERCOLOR=${RCol} ;;
		heimdall)	USERCOLOR=${RCol} ;;
		root)		USERCOLOR=${BRed}${On_Whi} ; ROOTPROMPT="${Red}[${BGre}ROOT${Red}]${RCol}" ;;
		*)          	USERCOLOR=${Gre} ;;
	esac

	if [ -n "$SSH_CONNECTION" ] ; then
		SSHPROMPT="${Red}[${Blu}SSH${Red}]${RCol}"	
	else
		SSHPROMPT=''
	fi

	export PS1="${SSHPROMPT}${ROOTPROMPT}${Red}[${RCol}\!${Red}]${Red}[${USERCOLOR}\u${RCol}@${HOSTCOLOR}\h ${RCol}\w${Red}]$ERRPROMPT${RCol}\\$ "
	export SUDO_PS1=${PS1}
}

#
# Aliases to switch between prompts
#
alias color_prompt='export PROMPT_COMMAND=_color_prompt'
alias normal_prompt='export PROMPT_COMMAND=_normal_prompt'

#
# Default prompt is colorize
#
export PROMPT_COMMAND=_color_prompt
