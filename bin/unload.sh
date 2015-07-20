#!/bin/bash


function rrmmod {
	
	# Module we want to remove
	typeset    mods="$@"
	typeset -i r=0

	
	typeset    deps=""
	typeset    ndep=""
	for m in $mods; do
		# Get the dependencies
		ndep="$(/sbin/lsmod | awk '$1 == "'$m'" {
			if($3 > 0) {
				n = split($4,a,",")
				if(n < $3) {
					print "> Err: module "$1" has "$3" ref, but only "n" modules." > "/dev/stderr"
					print "> Remove manually refs to it (mountpoints, iptables rules, daemons, nfs exports...)" > "/dev/stderr"
					exit(1)
				}
				for (m in a) print a[m]
			}
		}')"
		
		# If we can't unload all mods, don't try
		[ $? -ne 0 ] && return 1
		
		# Some dep for current mod, add them before
		[ -n "$ndep" ] && deps="$ndep $deps"
	done
		
	# Some deps, go recursion
	[ -n "$deps" ] && {
		ndep="$(rrmmod "$deps")"
		[ $? -ne 0 ] && {
			echo "> Dependency removal error detected. Stopping here" >/dev/stderr
			return 2
		}
		deps="$ndep $deps"
	}

	# try to unload the modules
	for m in $ndep $mods; do
		/sbin/rmmod $m || {
			echo "> cannot remove module '$m'. Are you root ?" >/dev/stderr
			return 3;
		}
	done
}

rrmmod "$@"

# vim: ts=4
