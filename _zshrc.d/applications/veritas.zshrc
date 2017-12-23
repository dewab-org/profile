#
# Add Veritas SF & NetBackup Paths
#


#
# NetBackup
#
if [ -d "/usr/openv" ] ; then 
	pathmunge /usr/openv/netbackup/bin after
	pathmunge /usr/openv/netbackup/bin/admincmd after
	pathmunge /usr/openv/netbackup/bin/support after
	pathmunge /usr/openv/volmgr/bin after
	manpathmunge /usr/openv/netbackup/bin/goodies/man
fi

#
# Storage Foundation
#
if [ -d "/opt/VRTS" ] ; then
	pathmunge /opt/VRTS/bin after
	pathmunge /opt/VRTSvcs/bin after
	manpathmunge /opt/VRTS/man after
fi
