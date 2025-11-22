#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH
MODDIR="/data/adb/modules/adaway_mount_helper"
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs

# Load detected mode
. "$MODDIR/mode.sh"

target_hostsfile="$MODDIR/system/etc/hosts"

# Mount/redirect functions based on mode
case $operating_mode in
	0)
		# Normal magic mount - no action needed
		echo "adaway_mount_helper: using normal magic mount" >> /dev/kmsg
		;;
	1)
		# KSU + SUSFS bind + try_umount
		mount --bind "$MODDIR/system/etc/hosts" /system/etc/hosts
		"$SUSFS_BIN" add_try_umount '/system/etc/hosts' 1
		echo "adaway_mount_helper: KSU SUSFS bind mount active" >> /dev/kmsg
		;;
	2)
		# Plain bind mount
		mount --bind "$MODDIR/system/etc/hosts" /system/etc/hosts
		echo "adaway_mount_helper: plain bind mount active" >> /dev/kmsg
		;;
	3)
		# APatch hosts_file_redirect
		target_hostsfile="/data/adb/hosts"
		if [ ! -f "$target_hostsfile" ]; then
			cat /system/etc/hosts > "$target_hostsfile" 2>/dev/null || {
				printf "127.0.0.1 localhost\n::1 localhost\n" > "$target_hostsfile"
			}
			chmod 644 "$target_hostsfile"
		fi
		echo "adaway_mount_helper: APatch hosts_file_redirect active" >> /dev/kmsg
		;;
	4)
		# ZN-hostsredirect
		target_hostsfile="/data/adb/hostsredirect/hosts"
		mkdir -p /data/adb/hostsredirect
		if [ ! -f "$target_hostsfile" ]; then
			cat /system/etc/hosts > "$target_hostsfile" 2>/dev/null || {
				printf "127.0.0.1 localhost\n::1 localhost\n" > "$target_hostsfile"
			}
			chmod 644 "$target_hostsfile"
		fi
		echo "adaway_mount_helper: ZN-hostsredirect active" >> /dev/kmsg
		;;
	6)
		# KSU source mod with try_umount
		mount --bind "$MODDIR/system/etc/hosts" /system/etc/hosts
		echo "adaway_mount_helper: KSU source mod active" >> /dev/kmsg
		;;
	10001)
		# KSU add-try-umount
		mount --bind "$MODDIR/system/etc/hosts" /system/etc/hosts
		/data/adb/ksud add-try-umount '/system/etc/hosts'
		echo "adaway_mount_helper: KSU add-try-umount active" >> /dev/kmsg
		;;
	*)
		echo "adaway_mount_helper: fallback to normal mount" >> /dev/kmsg
		;;
esac

# Wait for boot completion
until [ "$(getprop sys.boot_completed)" = "1" ]; do
	sleep 1
done

# Update module description with status
if [ -w "$target_hostsfile" ]; then
	echo "adaway_mount_helper: hosts file writable, ready for AdAway" >> /dev/kmsg
	sed -i "s/^description=.*/description=Ready for AdAway (mode: $operating_mode)/" "$MODDIR/module.prop"
else
	echo "adaway_mount_helper: WARNING - hosts file not writable" >> /dev/kmsg
	sed -i "s/^description=.*/description=ERROR: hosts not writable/" "$MODDIR/module.prop"
	touch "$MODDIR/disable"
fi
