[ -f "/etc/oratab" ] || return

export ORATAB="/etc/oratab"

function select-oracle-database {
	DATABASES=$( egrep -v "^($|#)" ${ORATAB} | cut -f1 -d: | sort )
	select DATABASE in ${DATABASES} "Manual Entry"
	do
		case $DATABASE in
		"Manual Input")
			echo
			echo Type in your SID
			read -r VAR2
			export ORACLE_SID=$VAR2
			echo Type in your ORACLE_HOME
			read -r VAR2
			export ORACLE_HOME=$VAR2
			break
			;;
		*)
			ORACLE_SID=$DATABASE
			ORACLE_HOME=$( awk -F: '$1== "'${DATABASE}'" {print}' ${ORATAB} | cut -d: -f2 )
			export ORACLE_SID ORACLE_HOME
			break
			;;
		esac
	done

	ORACLE_BASE=$( ${ORACLE_HOME}/bin/orabase )
	export ORACLE_BASE
	append_path PATH ${ORACLE_HOME}/bin
	display-oracle-env
}


function display-oracle-env {
	echo "Oracle ---- "
	echo "ORACLE_SID = ${ORACLE_SID}"
	echo "ORACLE_HOME = ${ORACLE_HOME}"
	echo "ORACLE_BASE = ${ORACLE_BASE}"
	echo "----------- "
}


# set default options for first oratab entry
ORACLE_SID=$(egrep -v "^($|#)" ${ORATAB} | cut -f1 -d: | head -1)
ORACLE_HOME=$(egrep -v "^($|#)" ${ORATAB} | cut -f2 -d: | head -1)
export ORACLE_SID ORACLE_HOME

append_path PATH "${ORACLE_HOME}/bin"

ORACLE_BASE="$(${ORACLE_HOME}/bin/orabase)"
export ORACLE_BASE

display-oracle-env
