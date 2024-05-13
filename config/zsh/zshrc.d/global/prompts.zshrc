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
autoload -Uz add-zsh-hook vcs_info 
VCS_BRANCH_CHAR=$'\ue0a0'
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr "%F{red}●%f"
zstyle ':vcs_info:*' stagedstr "%F{green}●%f"
zstyle ':vcs_info:git*' formats "%F{red}[%F{white}${VCS_BRANCH_CHAR}%b %f%m%u%c%f%F{red}]%f"
zstyle ':vcs_info:git*' actionformats "%F{red}[%F{white}${VCS_BRANCH_CHAR}%b|%f%m%a%u%c%f%F{red}]%f"
# precmd_functions+=(vcs_info)
add-zsh-hook precmd vcs_info

# Adds Ahead/Behind to %m in vcs_info
zstyle ':vcs_info:git*+set-message:*' hooks git-st
function +vi-git-st() {
    local ahead behind
    local -a gitstatus

    # for git prior to 1.7
    # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
    ahead=$(git rev-list --count ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null)
    (( $ahead )) && gitstatus+=( "%F{red}⇡${ahead}%f" )

    # for git prior to 1.7
    # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
    behind=$(git rev-list --count HEAD..${hook_com[branch]}@{upstream} 2>/dev/null)
    (( $behind )) && gitstatus+=( "%F{cyan}⇣${behind}%f" )

    hook_com[misc]+=${(j:/:)gitstatus}
}

# Adds Untracked Status to %c in vcs_info
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[staged]+='%F{red}…%f'
    fi
}

# Use git_info instead of vcs_info
# autoload -Uz git_info

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

	# Prompt using git_info
	# export PROMPT="${SSHPROMPT}${ROOTPROMPT}%F{red}[%f%!%F{red}]%F{red}[${USERCOLOR}%n%f@${HOSTCOLOR}%m %f%~%F{red}]%f$(git_info)%# "

	# prompt using vcs_info
	export PROMPT="${SSHPROMPT}${ROOTPROMPT}%F{red}[%f%!%F{red}]%F{red}[${USERCOLOR}%n%f%k@${HOSTCOLOR}%m %f%~%F{red}]%f${vcs_info_msg_0_}%# "
	
	# Prompt using bar arrows with vcs_info
	# export ARROW=$'\ue0b0'
	# export PROMPT="%K{red}%F{white}%! %K{magenta}%F{red}${ARROW}%F{USERCOLOR}%n@${RHOSTCOLOR}%m %K{blue}%F{magenta}${ARROW}%F{white} %~ %K{yellow}%F{blue}${ARROW}%f ${vcs_info_msg_0_} %K{blue}%F{yellow}${ARROW}%f %#%k%F{blue}${ARROW}%f"
	
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
