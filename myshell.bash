# vim: ft=sh

PS4=' (${BASH_SOURCE##*/}:$LINENO ${FUNCNAME[0]:-main})  '

# Source system-bashrc
#[[ -e /etc/bashrc ]] && source /etc/bashrc

# -----------------------------------------------------------------------------
# MyShell Loader
typeset mys_load=true

# Only work on interactive mode
[[ ${-//i/} == "$-" ]] && mys_load=false
# Need a valid homedir
[[ -z "$HOME" ]] || ! [[ -d "$HOME" ]] && mys_load=false


if $mys_load; then
	source $HOME/.myshell/myshell

	function command_not_found_handle {
		typeset cmd="$1"

		# Check if it's an internal command to be loaded
		if [[ "$cmd" != "${cmd#amm}" ]]; then
			if type "ammLib::Load" 2>/dev/null; then
				ammLog::Wrn "AMM Command not found: '$cmd'"
			else
				echo >&2 "AMMLib not loaded. Cannot auto-load requested library"
				return 127
			fi

		# TODO: Command which we could handle through package manager
		else
			# Standard error message
			echo >&2 "$0: line ${BASH_LINENO[0]}: $cmd: command not found"
			return 127
		fi
	}

fi
# End of MyShell loader
# -----------------------------------------------------------------------------

