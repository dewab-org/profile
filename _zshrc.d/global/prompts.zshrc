#
# Prompts Script
#

setopt PROMPT_SUBST

# Enable VCS information (GIT, SVN)
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr "%{$fg_no_bold[red]%}●%{$reset_color%}"
zstyle ':vcs_info:*' stagedstr "%{$fg_no_bold[green]%}●%{$reset_color%}"

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
		root)		USERCOLOR="%{$fg_no_bold[red]%}%{$bg_no_bold[white]%}" ; 
					ROOTPROMPT="%{$fg_no_bold[red]%}[%{$fg_no_bold[green]%}ROOT%{$fg_no_bold[red]%}]%{$reset_color%}" ;;
		*)          USERCOLOR="%{$fg_no_bold[green]%}" ;;
	esac

	if [ -n "$SSH_CONNECTION" ] ; then
		SSHPROMPT="%{$fg_no_bold[red]%}[%{$fg_no_bold[blue]%}SSH%{$fg_no_bold[red]%}]%{$reset_color%}"	
	else
		SSHPROMPT=''
	fi

	#export PROMPT="${SSHPROMPT}${ROOTPROMPT}%{$fg_no_bold[red]%}[%{$reset_color%}%!%{$fg_no_bold[red]%}]%{$fg_no_bold[red]%}[${USERCOLOR}%n%{$reset_color%}@${HOSTCOLOR}%m %{$reset_color%}%~%{$fg_no_bold[red]%}]%{$reset_color%}${vcs_info_msg_0_}%# "
	export PROMPT="${SSHPROMPT}${ROOTPROMPT}%{$fg_no_bold[red]%}[%{$reset_color%}%!%{$fg_no_bold[red]%}]%{$fg_no_bold[red]%}[${USERCOLOR}%n%{$reset_color%}@${HOSTCOLOR}%m %{$reset_color%}%~%{$fg_no_bold[red]%}]%{$reset_color%}$(git_info)%# "
	export RPROMPT='$(_right_prompt_err_code_prompt)'
	export SUDO_PS1=${PROMPT}
}

# Git prompt options
zstyle ':vcs_info:git*' formats "%{$fg_no_bold[red]%}[%{$fg[grey]%}(%s)%{$reset_color%}(%r)%{$fg[grey]%}(%{$fg[blue]%}%b)%{$reset_color%}%m%u%c%{$reset_color%}%{$fg_no_bold[red]%}]%{$reset_color%}"

#
# Aliases to switch between prompts
#
alias color_prompt='export PROMPT_COMMAND=_color_prompt'
alias normal_prompt='export PROMPT_COMMAND=_normal_prompt'

#
# Default prompt is colorize
#
export PROMPT_COMMAND=_color_prompt

_prompt_command () {
	eval "${PROMPT_COMMAND}"
}

# Allow ZSH to "emulate" bash PROMPT_COMMAND variable
#precmd() { vcs_info ; eval "$PROMPT_COMMAND" }
#precmd_functions+=(vcs_info)
precmd_functions+=(_prompt_command)
