#!/bin/sh
#
# Create a jail using pkgbase, only FreeBSD 15 is supported
#

set -eu

create_zfs_dataset() {
	if ! zfs create "$1"; then
		return 1
	else
		echo "ZFS dataset $1 created, mountpoint: $(zfs get -H mountpoint "$1" | awk '{ print $3}')"
		return 0
	fi
}

zfs_dataset_prefix="${ZFS_DATASET_PREFIX:-zroot/data/jails}"

if [ $# -lt 1 ]; then
	echo "Please provide a jail name in argument" >&2
	exit 1
fi

jail_name=$1
zfs_dataset_base=${zfs_dataset_prefix}/${jail_name}
zfs_dataset_root=${zfs_dataset_prefix}/${jail_name}/root

create_zfs_dataset "$zfs_dataset_base" || exit 1
create_zfs_dataset "$zfs_dataset_root" || exit 1

zfs_dataset_root_mountpoint=$(zfs get -H mountpoint "$zfs_dataset_root" | awk '{ print $3}')

mkdir -p "$zfs_dataset_root_mountpoint/usr/share/keys/pkgbase-15/"
cp -r /usr/share/keys/pkgbase-15/* "$zfs_dataset_root_mountpoint/usr/share/keys/pkgbase-15/"
pkg --rootdir "$zfs_dataset_root_mountpoint" install -y FreeBSD-set-minimal-jail
mkdir -p "$zfs_dataset_root_mountpoint/usr/local/etc/pkg/repos/"
cat > "$zfs_dataset_root_mountpoint/usr/local/etc/pkg/repos/FreeBSD-base.conf"<<EOF
FreeBSD-base: {
  enabled: yes
}
EOF

echo "Minimal config for $jail_name:"
cat <<EOF
$jail_name {
       host.hostname = "$jail_name";
       path = "$zfs_dataset_root_mountpoint";
       ip4.addr = ;
       ip6.addr = ;
       interface = ;
       exec.start = '/bin/sh /etc/rc';
       exec.stop = '/bin/sh /etc/rc.shutdown';
       devfs_ruleset = 4;
       mount;
       mount.devfs
}
EOF
