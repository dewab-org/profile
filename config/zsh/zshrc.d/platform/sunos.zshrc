# Custom bashrc script for Solaris (sunos) Environment

# Solaris Specific Paths
append_path PATH /usr/openv/netbackup/bin
append_path PATH /usr/openv/netbackup/bin/admincmd
append_path PATH /usr/sfw/bin
append_path PATH /usr/sfw/sbin
append_path MANPATH /usr/sfw/man
append_path PATH /opt/csw/bin
append_path PATH /opt/csw/sbin
append_path MANPATH /opt/csw/man

# Fish iTerm Integrate Shell Dependence on hostname -f flag
iterm2_hostname=$(hostname)

# Bash Completeion
if [ -f "/opt/csw/etc/bash_completion" ] ; then
        . /opt/csw/etc/bash_completion
fi
