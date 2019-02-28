#

export HOMEBREW_GITHUB_API_TOKEN="97198fdc2bef0dbe0263e315cd12fdd95a0911fe"

fpath=( $fpath /brew/completions/zsh /brew/share/zsh-completions )

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
