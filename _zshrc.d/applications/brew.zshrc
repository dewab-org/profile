[[ $+commands[brew] -lt 1 ]] && return

# Add brew environment variables
export HOMEBREW_GITHUB_API_TOKEN="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"
source <(brew shellenv)

# Add brew completions to shell
fpath=( $fpath $(brew --prefix)/share/zsh/site-functions )

function recask () {
	brew cask uninstall --force "$1" && brew cask install --force "$1"
}

#alias brewup="brew update ; brew upgrade ; brew-cask.sh upgrade ; brew cleanup ; brew cask cleanup"

function brew-up () {
	brew update
	brew upgrade
	brew cu -a --cleanup -q
	brew cleanup
}
