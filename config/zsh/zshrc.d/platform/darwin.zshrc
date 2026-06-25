# Custom zshrc.d script for MacOSX (Darwin) Environment

# Mac Specific Environmental Variables
export GDFONTPATH=/Library/Fonts
export FIGNORE="$FIGNORE:Application Scripts:"
export MACOS_VER=$(sw_vers -productVersion)
unset COMMAND_MODE

# Add SSH Keys from OS-X Keychain
# Moved to a background process as this was taking 200ms to run each login.
# May want to move to once-per-day as with compinit.
is-at-least 12.0.0 ${MACOS_VER} && SSH_ADD_OPT="--apple-load-keychain" || SSH_ADD_OPT="-A"
/usr/bin/ssh-add ${SSH_ADD_OPT} &>| "${XDG_STATE_HOME}/ssh-add.out" &|
unset SSH_ADD_OPT

# Flush DNS Cache
is-at-least 10.10.4 ${MACOS_VER} && \
  alias flushcache="sudo dscacheutil -flushcache ; sudo killall -HUP mDNSResponder" || \
  alias flushcache="sudo discoveryutil mdnsflushcache"

# General Aliases
alias am='open -a "Activity Monitor"'
alias top="top -u" # Mac Top
alias vmstat='vm_stat'
alias eject='hdiutil eject'
alias hibernateon="sudo pmset -a hibernatemode 5"
alias hibernateoff="sudo pmset -a hibernatemode 0"
alias caff="caffeinate -disut 3600"
alias mdns-on='sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist'
alias mdns-off='sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist'
alias cpwd='pwd|tr -d "\n"|pbcopy'
alias ql="qlmanage -p &>/dev/null" # QuickLook a file

# Microsoft Office launchers. These are functions rather than aliases so that
# the per-app tab completion below actually applies: with complete_aliases unset
# (the default) zsh substitutes an alias for its expansion before completing, so
# `word` would inherit `open`'s "any file" completion. Functions aren't
# substituted, so the compdefs bind to the right command.
excel()      { open -a 'Microsoft Excel' "$@" }
word()       { open -a 'Microsoft Word' "$@" }
powerpoint() { open -a 'Microsoft PowerPoint' "$@" }

# Tab-complete the Office launchers on appropriate document types (plus dirs to
# descend into). nocaseglob makes the extension match case-insensitive (e.g.
# REPORT.DOCX) without depending on EXTENDED_GLOB being set.
compdef 'setopt localoptions nocaseglob; _files -g "*.(doc|docx|docm|dot|dotx|dotm|rtf|odt)(.)" -/' word
compdef 'setopt localoptions nocaseglob; _files -g "*.(xls|xlsx|xlsm|xlsb|xlt|xltx|xltm|xlw|csv|ods)(.)" -/' excel
compdef 'setopt localoptions nocaseglob; _files -g "*.(ppt|pptx|pptm|pps|ppsx|ppsm|pot|potx|potm|odp)(.)" -/' powerpoint

# Moving functions into zsh function autoloads
autoload -Uz macmodel
autoload -Uz location
autoload -Uz pman
autoload -Uz f
