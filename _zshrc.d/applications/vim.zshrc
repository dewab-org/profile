[[ $+commands[vim] -lt 1 ]] && return

function vim-setup {
    if [ -d ~/.vim/bundle/Vundle.vim ] ; then
        # Update Vundle
        print "Ensuring Vundle is latest"
        git -C ~/.vim/bundle/Vundle.vim pull
    else
        # Download Vundle
        print "Installing Vundle"
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    fi

    # Use Vundle to install Plugins
    print "Using Vundle to install defined Plugins"
    vim +PluginInstall +qall
}
