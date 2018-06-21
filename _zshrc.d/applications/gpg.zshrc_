#
# GPG-Agent
#

#GPG_AGENT_PID=$(pgrep -u$UID gpg-agent)
#GPG_AGENT=$(which gpg-agent)
#if [ -x "$GPG_AGENT" ] ; then
#        if [ -n "$GPG_AGENT_PID" ]
#           then
#                . "${HOME}/.gpg-agent-info"
#           else
#                ${GPG_AGENT} --daemon --write-env-file "${HOME}/.gpg-agent-info" > /dev/null
#                . "${HOME}/.gpg-agent-info"
#        fi
#fi

GPGCONF=$(which gpgconf)
if [ -x "${GPGCONF}" ]
  then
    export GPG_TTY=$(/usr/bin/tty)
    ${GPGCONF} --launch gpg-agent
fi
