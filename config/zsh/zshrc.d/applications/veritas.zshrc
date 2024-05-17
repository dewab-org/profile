#
# Add Veritas SF & NetBackup Paths
#


#
# NetBackup
#
if [ -d "/usr/openv" ] ; then
	append_path PATH /usr/openv/netbackup/bin
	append_path PATH /usr/openv/netbackup/bin/admincmd
	append_path PATH /usr/openv/netbackup/bin/support
	append_path PATH /usr/openv/volmgr/bin
	append_path MANPATH /usr/openv/netbackup/bin/goodies
fi

#
# Storage Foundation
#
if [ -d "/opt/VRTS" ] ; then
	append_path PATH /opt/VRTS/bin
	append_path PATH /opt/VRTSvcs/bin
	append_path MANPATH /opt/VRTS/man
fi
