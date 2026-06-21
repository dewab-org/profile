# Catppuccin Mocha — truecolor (38;2;R;G;B) semantic overrides
# Remaining file-type colors come from the terminal's ANSI palette (iTerm2 profile)
export EZA_COLORS="\
di=38;2;116;199;236:\
ex=38;2;166;227;161:\
ln=38;2;148;226;213:\
or=38;2;243;139;168;1:\
da=38;2;147;153;178:\
sn=38;2;205;214;244:\
sb=38;2;147;153;178:\
uu=38;2;205;214;244:\
ga=38;2;166;227;161:\
gm=38;2;249;226;175:\
gd=38;2;243;139;168:\
gv=38;2;203;166;247:\
gt=38;2;250;179;135"

# Prefer eza, then exa; otherwise leave the base ls aliases from .zshrc
if is-executable eza; then
  alias ls='eza --classify --icons --color-scale'
  alias ll='eza --classify --icons --color-scale --long --all'
  alias l.='eza --classify --icons --color-scale --list-dirs .* '
  alias la='eza --classify --icons --color-scale --all'
  alias lr='eza --classify --icons --color-scale --long --all --sort=newest'  # ls -ltr: newest last
  alias lR='eza --classify --icons --color-scale --long --all --recurse'      # ls -lR: recursive
  alias tree='eza --classify --icons --color-scale --tree'
  return
fi

if is-executable exa; then
  alias ls='exa --classify --icons --color-scale'
  alias ll='exa --classify --icons --color-scale --long --all'
  alias l.='exa --classify --icons --color-scale --list-dirs .* '
  alias la='exa --classify --icons --color-scale --all'
  alias lr='exa --classify --icons --color-scale --long --all --sort=newest'  # ls -ltr: newest last
  alias lR='exa --classify --icons --color-scale --long --all --recurse'      # ls -lR: recursive
  alias tree='exa --classify --icons --color-scale --tree'
fi
