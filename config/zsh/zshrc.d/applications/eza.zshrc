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

if is-executable eza; then
  # Register explicitly rather than relying on compinit's fpath scan: `ls` is an
  # alias, so completion resolves through eza's completer, and if compinit's daily
  # dump rebuild ever misses eza's #compdef (fpath race), Carapace silently takes
  # over with a completer that doesn't understand eza's flags.
  (( ${+_comps} )) || typeset -g -A _comps
  _comps[eza]=_eza

  # --classify/--icons/--color-scale take an *optional* value (e.g. `[<WHEN>]`)
  # as of eza 0.18.0 (--classify was the last of the three to switch, in
  # 2024-02). Pinning the value with `=` makes them unambiguous so they never
  # swallow a following path argument — a bare `--classify --icons
  # --color-scale <path>` ate <path> as each flag's value both in the real
  # binary AND in _eza's zsh completion spec (which models flags the same
  # way), breaking `ls <TAB>` entirely.
  #
  # Below 0.18.0 these are plain boolean switches and reject `=value` outright
  # (`--classify=auto` errors), so fall back to bare flags there — booleans
  # can't swallow an argument, so there's nothing to protect against.
  local _eza_version
  _eza_version="${${(f)"$(eza --version 2>/dev/null)"}[2]#v}"
  _eza_version="${${_eza_version%% *}:-999}"  # unparsed version: assume modern

  local -a _eza_display_flags
  if is-at-least 0.18.0 "${_eza_version}"; then
    _eza_display_flags=(--classify=auto --icons=auto --color-scale=all)
  else
    _eza_display_flags=(--classify --icons --color-scale)
  fi

  alias ls="eza ${_eza_display_flags[*]}"
  alias ll="eza ${_eza_display_flags[*]} --long --all"
  alias l.="eza ${_eza_display_flags[*]} --list-dirs -- .*"
  alias la="eza ${_eza_display_flags[*]} --all"
  alias lr="eza ${_eza_display_flags[*]} --long --all --sort=newest"  # ls -ltr: newest last
  alias lR="eza ${_eza_display_flags[*]} --long --all --recurse"      # ls -lR: recursive
  alias tree="eza ${_eza_display_flags[*]} --tree"

  unset _eza_version _eza_display_flags
  return
fi

if is-executable exa; then
  (( ${+_comps} )) || typeset -g -A _comps
  _comps[exa]=_exa

  alias ls='exa --classify --icons --color-scale --'
  alias ll='exa --classify --icons --color-scale --long --all --'
  alias l.='exa --classify --icons --color-scale --list-dirs -- .*'
  alias la='exa --classify --icons --color-scale --all --'
  alias lr='exa --classify --icons --color-scale --long --all --sort=newest --'  # ls -ltr: newest last
  alias lR='exa --classify --icons --color-scale --long --all --recurse --'      # ls -lR: recursive
  alias tree='exa --classify --icons --color-scale --tree --'
fi
