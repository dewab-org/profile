#
# Prompts Script
#

setopt PROMPT_SUBST

#
# Notes:
# See https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
# %F{colorname} == Foreground colorname 
# %f == reset foreground
# %K{colorname} == Background colorname
# %k == reset background

# Enable VCS information (GIT, SVN)
# autoload -Uz vcs_info
# zstyle ':vcs_info:*' enable git svn
# zstyle ':vcs_info:*' check-for-changes true
# zstyle ':vcs_info:*' unstagedstr "%F{red}●%f"
# zstyle ':vcs_info:*' stagedstr "%F{green}●%f"
# # zstyle ':vcs_info:git*' formats "%{$fg[grey]%}%s %{$reset_color%}%r/%S%{$fg[grey]%} %{$fg[blue]%}%b%{$reset_color%}%m%u%c%{$reset_color%} "
# zstyle ':vcs_info:git*' formats "%F{red}[%F{blue}%b %f%m%u%c%f%F{red}]%f"
# precmd_functions+=(vcs_info)

# Use git_info instead of vcs_info
autoload -Uz git_info

_normal_prompt () {
        # Non-Colorized Prompt
        PROMPT="[%!][%n@%m %~${WINDOW:+ ($WINDOW)}]%# "
        SUDO_PS1=${PROMPT}
        if [ -n "$SSH_CONNECTION" ] ; then
                PROMPT="[SSH]"$PROMPT
        fi
}

# _right_prompt_err_code_prompt () {
# 	# set an error string for the prompt, if applicable
# 	local LAST_EXIT_CODE=$?
# 	if [[ $LAST_EXIT_CODE -eq 0 ]]
#         then
#             ERRPROMPT=" "
#         else
#             ERRPROMPT="%{$fg_no_bold[blue]%}-%{$fg_no_bold[red]%}%{$bg_no_bold[white]%} $LAST_EXIT_CODE %{$reset_color%}%{$fg_no_bold[blue]%}-%{$reset_color%}"
#         fi

# 	echo "${ERRPROMPT}"
# }

_color_prompt () {
	case "$hostname" in
		sunna)         	HOSTCOLOR="%F{white}" ;;
		uller)		    HOSTCOLOR="%F{magenta}" ;;
		uller-wifi)	    HOSTCOLOR="%F{magenta}" ;;
		freya)		    HOSTCOLOR="%F{blue}" ;;
		freya-wifi)	    HOSTCOLOR="%F{blue}" ;;
		bifrost)        HOSTCOLOR="%F{cyan}" ;;
		*)              HOSTCOLOR="%f" ;;
	esac

	case "$USER" in
		Daniel)		USERCOLOR="%f" ;;
		heimdall)	USERCOLOR="%f" ;;
		root)		USERCOLOR="%F{red}%K{white}" ; 
					ROOTPROMPT="%F{red}[%F{green}ROOT%F{red}]%f" ;;
		*)          USERCOLOR="%F{green}" ;;
	esac

	if [ -n "$SSH_CONNECTION" ] ; then
		# SSHPROMPT="%{$fg_no_bold[red]%}[%{$fg_no_bold[blue]%}SSH%{$fg_no_bold[red]%}]%{$reset_color%}"	
		SSHPROMPT="%F{red}[%F{blue}SSH%F{red}]%f"	
	else
		SSHPROMPT=''
	fi

	#export PROMPT="${SSHPROMPT}${ROOTPROMPT}%{$fg_no_bold[red]%}[%{$reset_color%}%!%{$fg_no_bold[red]%}]%{$fg_no_bold[red]%}[${USERCOLOR}%n%{$reset_color%}@${HOSTCOLOR}%m %{$reset_color%}%~%{$fg_no_bold[red]%}]%{$reset_color%}${vcs_info_msg_0_}%# "
	export PROMPT="${SSHPROMPT}${ROOTPROMPT}%F{red}[%f%!%F{red}]%F{red}[${USERCOLOR}%n%f@${HOSTCOLOR}%m %f%~%F{red}]%f$(git_info)%# "
	# export PROMPT="${SSHPROMPT}${ROOTPROMPT}%F{red}[%f%!%F{red}]%F{red}[${USERCOLOR}%n%f@${HOSTCOLOR}%m %f%~%F{red}]%f${vcs_info_msg_0_}%# "
	# export RPROMPT='$(_right_prompt_err_code_prompt)'
	# RPROMPT='%(?.%F{green}✔%f.%F{red}✘%F{white}%?%f)'
	RPROMPT='%(?..%F{red}✘%F{white}%?%f)'
	export SUDO_PS1=${PROMPT}
}

# Set correction prompt
SPROMPT="zsh: correct '%F{red}%R%f' to '%F{green}%r%f' [nyae]?"

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
precmd_functions+=(_prompt_command)
