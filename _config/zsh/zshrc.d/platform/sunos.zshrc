#
# Custom bashrc script for Solaris (sunos) Environment
#

#
# Solaris Specific Paths
#
pathmunge /usr/openv/netbackup/bin after
pathmunge /usr/openv/netbackup/bin/admincmd after

pathmunge /opt/VRTS/bin after
manpathmunge /opt/VRTS/man after

pathmunge /usr/sfw/bin after
pathmunge /usr/sfw/sbin after
manpathmunge /usr/sfw/man after

pathmunge /opt/csw/bin after
pathmunge /opt/csw/sbin after
manpathmunge /opt/csw/man after

#
# Fish iTerm Integrate Shell Dependence on hostname -f flag
#

iterm2_hostname=$(hostname)

#
# Bash Completeion
#

if [ -f "/opt/csw/etc/bash_completion" ] ; then
        . /opt/csw/etc/bash_completion
fi
