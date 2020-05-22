# vim: ft=sh

# Source system-bashrc
[[ -e /etc/bashrc ]] && source /etc/bashrc

# -----------------------------------------------------------------------------
# MyShell Loader
typeset mys_load=true

# Only work on interactive mode
[[ ${-//i/} != "$-" ]] && mys_load=false
# Need a valid homedir
[[ -z "$HOME" ]] || ! [[ -d "$HOME" ]] && mys_load=false


if $mys_load; then
	source $HOME/.myshell/myshell
fi
# End of MyShell loader
# -----------------------------------------------------------------------------

