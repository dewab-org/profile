is-executable fzf || return
is-executable git || return

# fzf-git.sh: Git integration for fzf
# Provides: gco (checkout), gcof (force checkout), gcb (create branch), gcp (checkout PR), gcl (clone), gcll (list remotes)
# Also: gbr (branch list), gcm (switch to main), gcf (fixup), gcp (commit), gst (status), glog (log)

_FZF_GIT_SCRIPTS=(
  "${HOMEBREW_PREFIX}/opt/fzf/git/git.sh"
  "/opt/homebrew/opt/fzf/git/git.sh"
  "/usr/local/opt/fzf/git/git.sh"
  "${HOME}/.fzf/git/git.sh"
  "/usr/share/fzf/git/git.sh"
  "/usr/share/doc/fzf/examples/git.sh"
)

_FZF_GIT_FOUND=0
for _fzf_git_script in "${_FZF_GIT_SCRIPTS[@]}"; do
  if is-readable "${_fzf_git_script}"; then
    source "${_fzf_git_script}"
    _FZF_GIT_FOUND=1
    break
  fi
done
unset _fzf_git_script

if [[ $_FZF_GIT_FOUND -eq 1 ]]; then
  # Add git aliases for fzf
  # gco = git checkout (fzf)
  # gcof = git checkout -f (force)
  # gcb = git checkout -b (create branch)
  # gcl = git clone
  # gcll = git clone (list remotes)
  # gbr = git branch (list)
  # gcm = git checkout main/master
  # gcf = git commit --fixup
  # gcp = git checkout PR
  # gst = git status
  # glog = git log

  # FZF_GIT_OPTS for customizing fzf behavior
  export FZF_GIT_OPTS="--preview 'git diff --color=always HEAD~1..HEAD' --preview-window=down:50%"

  # Add custom git aliases if not already defined
  [ -z "${aliases[gco]+isset}" ] && alias gco="git checkout $(git branch -a | fzf --height 40% --layout=reverse --border)"
  [ -z "${aliases[gcof]+isset}" ] && alias gcof="git checkout -f $(git branch -a | fzf --height 40% --layout=reverse --border)"
  [ -z "${aliases[gcb]+isset}" ] && alias gcb="git checkout -b"
  [ -z "${aliases[gcl]+isset}" ] && alias gcl="git clone"
  [ -z "${aliases[gcll]+isset}" ] && alias gcll="git clone $(git remote | fzf --height 40% --layout=reverse --border)"
  [ -z "${aliases[gbr]+isset}" ] && alias gbr="git branch $(git branch -a | fzf --height 40% --layout=reverse --border)"
  [ -z "${aliases[gcm]+isset}" ] && alias gcm="git checkout main"
  [ -z "${aliases[gcf]+isset}" ] && alias gcf="git commit --fixup=$(git log --oneline | fzf --height 40% --layout=reverse --border)"
  [ -z "${aliases[gcp]+isset}" ] && alias gcp="git checkout $(git branch -a | fzf --height 40% --layout=reverse --border)"
  [ -z "${aliases[gst]+isset}" ] && alias gst="git status"
  [ -z "${aliases[glog]+isset}" ] && alias glog="git log --oneline --graph --all | fzf --height 50% --layout=reverse --border"

  unset _FZF_GIT_OPTS _FZF_GIT_SCRIPTS _FZF_GIT_FOUND
fi

unset _FZF_GIT_SCRIPTS _FZF_GIT_FOUND
