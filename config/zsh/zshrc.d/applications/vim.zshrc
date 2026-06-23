is-executable vim || return

export GVIMINIT='let $MYGVIMRC="$XDG_CONFIG_HOME/vim/gvimrc" | source $MYGVIMRC'
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

# VIMINIT is for Vim and takes precedence over Neovim's native init.lua.
if is-executable nvim; then
    function nvim {
        local VIMINIT GVIMINIT
        unset VIMINIT GVIMINIT
        command nvim "$@"
    }
fi

# Vim plugins are installed as native packages by setup.py (see manifest.json),
# under $XDG_DATA_HOME/vim/pack/plugins/start/*. Run `./setup.py` to install
# or update them.
