#
# Prompts Script
#

setopt PROMPT_SUBST

_normal_prompt () {
        #
        # Non-Colorized Prompt
        #
	# history -a

        PROMPT="[%!][%n@%m %~${WINDOW:+ ($WINDOW)}]\$ "
        SUDO_PS1="[%!][%n@%m %~${WINDOW:+ ($WINDOW)}]# "
        if [ -n "$SSH_CONNECTION" ] ; then
                PS1="[SSH]"$PS1
        fi

}

_right_prompt_err_code_prompt () {
	# set an error string for the prompt, if applicable
	local LAST_EXIT_CODE=$?
	if [[ $LAST_EXIT_CODE -eq 0 ]]
        then
                ERRPROMPT=" "
        else

                ERRPROMPT="%F{blue}-%F{red}%K{white} $LAST_EXIT_CODE %k%F{blue}-%f%k"
        fi

	echo "${ERRPROMPT}"
}

_color_prompt () {
	case "$hostname" in
		snotra)         HOSTCOLOR="%F{purple}" ;;
		uller)		    HOSTCOLOR="%F{blue}" ;;
		uller-wifi)	    HOSTCOLOR="%F{blue}" ;;
		bifrost)        HOSTCOLOR="%F{cyan}" ;;
		*)              HOSTCOLOR="%f%k%b" ;;
	esac

	case "$USER" in
		Daniel)		USERCOLOR="%f%k%b" ;;
		heimdall)	USERCOLOR="%f%k%b" ;;
		root)		USERCOLOR="%F{red}%K{white}" ; ROOTPROMPT="%F{red}[%F{green}ROOT%F{red}]%f%k%b" ;;
		*)          USERCOLOR="%F{green}" ;;
	esac

	if [ -n "$SSH_CONNECTION" ] ; then
		SSHPROMPT="%F{red}[%F{blue}SSH%F{red}]%f%k%b"	
	else
		SSHPROMPT=''
	fi

	export PROMPT="${SSHPROMPT}${ROOTPROMPT}%F{red}[%f%k%b%!%F{red}]%F{red}[${USERCOLOR}%n%f%k%b@${HOSTCOLOR}%m %f%k%b%~%F{red}]$ERRPROMPT%f%k%b\$ "
	export RPROMPT='$(_right_prompt_err_code_prompt)'
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

# Allow ZSH to "emulate" bash PROMPT_COMMAND variable
precmd() { eval "$PROMPT_COMMAND" }
