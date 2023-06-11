#!/bin/sh
#
# Upgrade all jails running on host
#

set -eu

failed_pkg_upgrade_jails=""
new_release="13.1-RELEASE"

export PAGER="/bin/cat"

for jailname in $(jls -q name); do
        if [ $(freebsd-version -j $jailname | sed -re 's/(.*)-(.*)/\1/g') = $new_release ]; then
                continue
        fi
        echo "Upgrading jail '$jailname'"
        jailpath=$(jls -j $jailname -q path)
        zfs_dataset=$(zfs list -H -o mountpoint,name | awk -v jailpath=$jailpath '$1 == jailpath { print $2 }')
        now_str=$(date +%Y-%m-%dT%H:%M:%S)
        zfs snapshot ${zfs_dataset}@upgrade_${now_str}
        yes | freebsd-update -j $jailname --not-running-from-cron upgrade -r $new_release
        freebsd-update -j $jailname --not-running-from-cron install
        jail -rc $jailname
        freebsd-update -j $jailname --not-running-from-cron install
        jexec $jailname pkg upgrade -y || failed_pkg_upgrade_jails="$failed_pkg_upgrade_jails $jailname"
	jexec $jailname pkg autoremove -y
	jexec $jailname pkg clean -y
        jail -rc $jailname
done

echo "pkg upgrade has failed on $failed_pkg_upgrade_jails"
