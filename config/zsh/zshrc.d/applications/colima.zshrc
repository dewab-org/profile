is-executable colima || return

# Work around colima bug abiosoft/colima#1431: when XDG_CONFIG_HOME is set,
# colima flip-flops between ~/.config/colima and ~/.colima across restarts. It
# runs the VM/socket from the legacy ~/.colima but leaves the docker context
# pointed at the stale ~/.config/colima socket, breaking every `docker` call.
# Hiding XDG_CONFIG_HOME from colima pins it to ~/.colima (which it prefers
# anyway) and also silences the "found ~/.colima, ignoring $XDG_CONFIG_HOME"
# warnings. XDG_CONFIG_HOME stays set for everything else.
function colima(){
    env -u XDG_CONFIG_HOME colima "$@"
}
