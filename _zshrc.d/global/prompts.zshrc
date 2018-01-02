#
# Prompts Script
#

setopt PROMPT_SUBST

_normal_prompt () {
        # Non-Colorized Prompt
        PROMPT="[%!][%n@%m %~${WINDOW:+ ($WINDOW)}]%# "
        SUDO_PS1=${PROMPT}
        if [ -n "$SSH_CONNECTION" ] ; then
                PROMPT="[SSH]"$PROMPT
        fi
}

_right_prompt_err_code_prompt () {
	# set an error string for the prompt, if applicable
	local LAST_EXIT_CODE=$?
	if [[ $LAST_EXIT_CODE -eq 0 ]]
        then
            ERRPROMPT=" "
        else
            ERRPROMPT="%{$fg_no_bold[blue]%}-%{$fg_no_bold[red]%}%{$bg_no_bold[white]%} $LAST_EXIT_CODE %{$reset_color%}%{$fg_no_bold[blue]%}-%{$reset_color%}"
        fi

	echo "${ERRPROMPT}"
}

_color_prompt () {
	case "$hostname" in
		snotra)         HOSTCOLOR="%{$fg_no_bold[purple]%}" ;;
		uller)		    HOSTCOLOR="%{$fg_no_bold[blue]%}" ;;
		uller-wifi)	    HOSTCOLOR="%{$fg_no_bold[blue]%}" ;;
		bifrost)        HOSTCOLOR="%{$fg_no_bold[cyan]%}" ;;
		*)              HOSTCOLOR="%{$reset_color%}" ;;
	esac

	case "$USER" in
		Daniel)		USERCOLOR="%{$reset_color%}" ;;
		heimdall)	USERCOLOR="%{$reset_color%}" ;;
		root)		USERCOLOR="%{$fg_no_bold[red]%}%{$bg_no_bold[white]%}" ; ROOTPROMPT="%{$fg_no_bold[red]%}[%{$fg_no_bold[green]%}ROOT%{$fg_no_bold[red]%}]%{$reset_color%}" ;;
		*)          USERCOLOR="%{$fg_no_bold[green]%}" ;;
	esac

	if [ -n "$SSH_CONNECTION" ] ; then
		SSHPROMPT="%{$fg_no_bold[red]%}[%{$fg_no_bold[blue]%}SSH%{$fg_no_bold[red]%}]%{$reset_color%}"	
	else
		SSHPROMPT=''
	fi

	export PROMPT="${SSHPROMPT}${ROOTPROMPT}%{$fg_no_bold[red]%}[%{$reset_color%}%!%{$fg_no_bold[red]%}]%{$fg_no_bold[red]%}[${USERCOLOR}%n%{$reset_color%}@${HOSTCOLOR}%m %{$reset_color%}%~%{$fg_no_bold[red]%}]%{$reset_color%}%# "
	export RPROMPT='$(_right_prompt_err_code_prompt)'
	export SUDO_PS1=${PROMPT}
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
