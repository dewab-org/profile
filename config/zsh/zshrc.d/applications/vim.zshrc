is-executable vim || return

export GVIMINIT='let $MYGVIMRC="$XDG_CONFIG_HOME/vim/gvimrc" | source $MYGVIMRC'
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

function vim-setup {
    if [ -d ${XDG_DATA_HOME}/vim/bundle/Vundle.vim ] ; then
        # Update Vundle
        print "Ensuring Vundle is latest"
        (cd ${XDG_DATA_HOME}/vim/bundle/Vundle.vim ; git pull origin HEAD)
    else
        # Download Vundle
        print "Installing Vundle"
        git clone https://github.com/VundleVim/Vundle.vim.git ${XDG_DATA_HOME}/vim/bundle/Vundle.vim
    fi

    # Use Vundle to install Plugins
    print "Using Vundle to install defined Plugins"
    vim +PluginInstall +qall
}
