if [ -d "${HOME}/.custom/${platform}/go" ] ; then
	pathmunge "${HOME}/.custom/${platform}/go/bin" after
	export GOROOT="${HOME}/.custom/${platform}/go"
	export GOPATH="${HOME}/.custom/${platform}/go:${HOME}/.custom/${platform}/"
fi
