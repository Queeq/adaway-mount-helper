#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH
MODDIR="/data/adb/modules/adaway_mount_helper"
SUSFS_BIN="/data/adb/ksu/bin/ksu_susfs"

# Create hosts file directory if needed
mkdir -p "$MODDIR/system/etc"

# Initialize hosts file if it doesn't exist
if [ ! -f "$MODDIR/system/etc/hosts" ]; then
	cat /system/etc/hosts > "$MODDIR/system/etc/hosts" 2>/dev/null || {
		printf "127.0.0.1 localhost\n::1 localhost\n" > "$MODDIR/system/etc/hosts"
	}
fi

# Set proper permissions
busybox chmod 644 "$MODDIR/system/etc/hosts" 2>/dev/null || chmod 644 "$MODDIR/system/etc/hosts"
busybox chown root:root "$MODDIR/system/etc/hosts" 2>/dev/null || chown root:root "$MODDIR/system/etc/hosts"

# Detect operating mode for mount strategy
# Default: normal magic mount
mode=0

# Plain mount mode for APatch overlayfs, APatch litemode, KSU nomount
if { [ "$APATCH" = "true" ] && [ ! "$APATCH_BIND_MOUNT" = "true" ]; } ||
	{ [ "$APATCH_BIND_MOUNT" = "true" ] && [ -f /data/adb/.litemode_enable ]; } ||
	{ [ "$KSU_MAGIC_MOUNT" = "true" ] && [ -f /data/adb/ksu/.nomount ]; }; then
	mode=2
fi

# Check for denylist handlers that provide umount capability
denylist_handlers="rezygisk zygisksu zygisk-assistant zygisk_nohello"
for module_name in $denylist_handlers; do
	if [ -d "/data/adb/modules/$module_name" ] && [ ! -f "/data/adb/modules/$module_name/disable" ] &&
		[ ! -f "/data/adb/modules/$module_name/remove" ]; then
		if [ "$module_name" = "zygisksu" ]; then
			if grep -q NeoZygisk /data/adb/modules/zygisksu/module.prop 2>/dev/null; then
				echo "adaway_mount_helper: NeoZygisk found" >> /dev/kmsg
			else
				continue
			fi
		fi
		echo "adaway_mount_helper: $module_name found, using plain mount" >> /dev/kmsg
		mode=2
	fi
done

# ZygiskNext 1.3.0+ with enforce_denylist
zygisksu_dir="/data/adb/modules/zygisksu"
if [ -d "$zygisksu_dir" ] && [ ! -f "$zygisksu_dir/remove" ] && [ ! -f "$zygisksu_dir/disable" ]; then
	if [ -f /data/adb/zygisksu/denylist_enforce ]; then
		enforce_denylist_mode=$(cat /data/adb/zygisksu/denylist_enforce)
		if [ "$enforce_denylist_mode" -gt 0 ] 2>/dev/null; then
			echo "adaway_mount_helper: ZygiskNext with enforce_denylist $enforce_denylist_mode" >> /dev/kmsg
			mode=2
		fi
	fi
fi

# KSU Next 12183+ with try_umount
if [ "$KSU_NEXT" = "true" ] && [ "$KSU_KERNEL_VER_CODE" -ge 12183 ] 2>/dev/null; then
	mode=6
fi

# KSU + SUSFS try_umount
if [ "$KSU" = true ] && [ -f "$SUSFS_BIN" ] &&
	"$SUSFS_BIN" show enabled_features 2>/dev/null | grep -q "CONFIG_KSU_SUSFS_TRY_UMOUNT"; then
	echo "adaway_mount_helper: KSU with SUSFS try_umount found" >> /dev/kmsg
	mode=1
fi

# KSU source mod with add-try-umount
if [ "$KSU" = true ] && /data/adb/ksud -h 2>/dev/null | grep -q "add-try-umount"; then
	echo "adaway_mount_helper: KSU with add-try-umount found" >> /dev/kmsg
	mode=10001
fi

# APatch hosts_file_redirect
if [ "$APATCH" = true ]; then
	if dmesg 2>/dev/null | grep -q "hosts_file_redirect"; then
		mode=3
	fi
fi

# ZN-hostsredirect
if [ -d "/data/adb/modules/hostsredirect" ] && [ ! -f "/data/adb/modules/hostsredirect/disable" ] &&
	[ ! -f "/data/adb/modules/hostsredirect/remove" ] &&
	[ -d "$zygisksu_dir" ] && [ ! -f "$zygisksu_dir/disable" ] && [ ! -f "$zygisksu_dir/remove" ]; then
	mode=4
fi

# Write mode to file for service.sh
echo "operating_mode=$mode" > "$MODDIR/mode.sh"

# Configure skip_mount based on mode
skip_mount=1
[ "$mode" = 0 ] && skip_mount=0

if [ "$skip_mount" = 0 ]; then
	[ -f "$MODDIR/skip_mount" ] && rm "$MODDIR/skip_mount"
else
	[ ! -f "$MODDIR/skip_mount" ] && touch "$MODDIR/skip_mount"
fi

echo "adaway_mount_helper: mode $mode configured" >> /dev/kmsg
