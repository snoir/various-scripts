#!/bin/sh
#
# Backup host with restic, using a configuration file for remote repository,
# excluded directories and a list of what to backup.
# Can also be used to launch all others restic commands, restic repository
# password will be taken from configuration file for easy use.
#

set -eu

usage() {
	echo "Usage: $0 <backup|cmd restic_cmd>"
}

backup() {
	excludes=""
	if [ ! -z "${restic_excludes:-}" ]; then
		for e in $restic_excludes; do
			excludes="$excludes --exclude=$e"
		done
	fi

	for m in $(mount -t nullfs,devfs,fdescfs,tmpfs,linprocfs | awk '{ print $3 }'); do
		excludes="$excludes --exclude=$m"
	done

	restic backup $restic_backup_dirs $excludes
	restic forget --keep-daily 7 --prune
}

config_dir="${RESTIC_CONFIG_DIR:-/opt/config/restic}"
config="${RESTIC_CONFIG:-default}"
config_file="${config_dir}/${config}"

. $config_file

if [ -z "${restic_password:-}" ]; then
	echo "Missing 'restic_password' in configuration (${config_file})"
	exit 1
fi

if [ -z "${restic_backup_dirs:-}" ]; then
	echo "Missing 'restic_backup_dirs' in configuration (${config_file})"
	exit 1
fi

if [ -z "${restic_repository:-}" ]; then
	echo "Missing 'restic_repository' in configuration (${config_file})"
	exit 1
fi

export RESTIC_PASSWORD=$restic_password
export RESTIC_REPOSITORY=$restic_repository

if [ $# -lt 1 ]; then
	usage
elif [ $1 = "backup" ]; then
	backup
elif [ $1 = "cmd" ]; then
	shift
	restic $@
else
	usage
fi
