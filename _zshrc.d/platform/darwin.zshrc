#
# Custom bashrc.d script for MacOSX (Darwin) Environment
#

#
# Add SSH Keys from OS-X Keychain
# (Had to add this after upgrding to macOS Sierra, for some reason
#
/usr/bin/ssh-add -A > /dev/null 2>&1

#
# Run Fink Environment
#
if [ -f "/sw/bin/init.sh" ] ; then
        source /sw/bin/init.sh
fi

#
# Homebrew environment
#
if [ -d "/brew" ] ; then
	pathmunge /brew/bin after
	pathmunge /brew/sbin after
	manpathmunge /brew/share/man after
fi

#
# Mac Specific Environmental Variables
#
cdpath=($cdpath $HOME/Documents/Work/Sigma/Customers)
export GDFONTPATH=/Library/Fonts
export FIGNORE="$FIGNORE:Application Scripts:Global Foundries:"
unset COMMAND_MODE

release=`uname -r | awk -F. '{print $1}'`

#
# Bash Completeion
#

if [ -r "/sw/etc/bash_completion" ] ; then
        source /sw/etc/bash_completion
fi

if [ -r "/brew/etc/profile.d/bash_completion.sh" ] ; then
	source /brew/etc/profile.d/bash_completion.sh
fi

#
# Aliases
#
alias finkup='fink selfupdate ; fink update-all'

case "$release" in
	#
	#  Apple being inconsistent.  Go figure.
	#
	13) 	alias flushcache="sudo killall -HUP mDNSResponder" # 10.7 & 10.8 & 10.9
	;;
	14)	
		if [ -x /usr/sbin/discoveryutil ] ; then
			alias flushcache="sudo discoveryutil mdnsflushcache" # 10.10.0 - 10.10.3
		else
			alias flushcache="sudo killall -HUP mDNSResponder" # 10.10.4 - ??
		fi
	;;
	15)
		alias flushcache="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder" # 10.11.0 (El Capitan)
	;;
	16)
		alias flushcache="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder" # 10.11.0 (El Capitan)
	;;
	*)	alias flushcache="dscacheutil -flushcache" # 10.6 and earlier
	;;
esac
unset release

alias am='open -a "Activity Monitor"'
alias top="top -u" # Mac Top
alias vmstat='vm_stat'
alias eject='hdiutil eject'

alias hibernateon="sudo pmset -a hibernatemode 5"
alias hibernateoff="sudo pmset -a hibernatemode 0"
alias caff="caffeinate -disut 3600"

alias ftp-on='sudo -s launchctl load -w /System/Library/LaunchDaemons/ftp.plist'
alias ftp-off='sudo -s launchctl unload -w /System/Library/LaunchDaemons/ftp.plist'

alias tftp-on='sudo -s launchctl load -w /System/Library/LaunchDaemons/tftp.plist'
alias tftp-off='sudo -s launchctl unload -w /System/Library/LaunchDaemons/tftp.plist'

alias mdns-on='sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist'
alias mdns-off='sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist'

alias cdf='cd "`osascript ~/.custom/darwin/bin/finder-window-dir`"'

#alias maclocation="scselect | egrep '^ \*' | sed 's:.*(\(.*\)):\1:'"
alias maclocation="networksetup -getcurrentlocation"

alias ql="qlmanage -p &>/dev/null" # QuickLook a file

##alias is-on='sudo -s launchctl load -w /System/Library/LaunchDaemons/com.apple.InternetSharing.plist'
##alias is-off='sudo -s launchctl unload -w /System/Library/LaunchDaemons/com.apple.InternetSharing.plist'

#
# Mac Specific Paths
#
pathmunge /sw/bin after
pathmunge /sw/sbin after

manpathmunge /sw/share/man after

#
# Functions
#
function pman () {
	#
	# Open a Unix man page in Preview.app
	#
	if [ $# -ne 1 ]
	then
		echo "pman <command>"
		return 1
	fi
	man -t $1 | open -f -a Preview
}

function location () {
    # Determine mac network location
    local location=$(networksetup -getcurrentlocation)
    
    echo "$location:l" # :l converts output to all lowercase
}

function ips () {
	# List IP addresses for each active interface
	local interface
	local interfaces=($(networksetup -listallhardwareports | awk '/^Device: /{print $2}'))

	for interface in $interfaces
	do
		local ip=$(ipconfig getifaddr $interface)
		[ -n "$ip" ] && printf "%11s: %s\n" "$interface" "$ip"
	done
	
	return 0 # needed so that failure of last getifaddr doesn't fail entire function
}
