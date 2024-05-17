is-executable sqlite3 || return

export SQLITE_HISTORY="${XDG_DATA_HOME}/sqlite_history"
export SQLITE_CONF="${XDG_CONFIG_HOME}/sqlite3"

is-directory "${SQLITE_CONF}" || mkdir -m 700 "${SQLITE_CONF}"
is-readable "${SQLITE_CONF}/sqliterc" || touch "${SQLITE_CONF}/sqliterc"

alias sqlite3='sqlite3 -init "${SQLITE_CONF}/sqliterc"'
