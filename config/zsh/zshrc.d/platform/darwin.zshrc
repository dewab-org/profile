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

# Enable ZSH Autosuggestions & Syntax Highlighting
zsh_script_paths=(
  # ZSH Autosuggestions
  "/brew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  # ZSH Syntax Highlighting
  "/brew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
)

for script in "${zsh_script_paths[@]}"; do
  is-readable "${script}" && source "${script}"
done

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

# Microsoft Office Aliases
alias excel="open -a 'Microsoft Excel'"
alias word="open -a 'Microsoft Word'"
alias powerpoint="open -a 'Microsoft PowerPoint'"

# Moving functions into zsh function autoloads
autoload -Uz macmodel
autoload -Uz location
autoload -Uz pman
autoload -Uz f
autoload -Uz ips
