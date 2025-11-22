#!/bin/sh

echo "[+] AdAway Mount Helper installer"
echo "[*] This module only provides mount infrastructure"
echo "[*] Install AdAway separately to manage your hosts file"

# Create hosts file directory
mkdir -p "$MODPATH/system/etc"

# Copy existing hosts file or create minimal one
if [ -f /data/adb/modules/adaway_mount_helper/system/etc/hosts ]; then
	echo "[+] Preserving existing hosts file"
	cat /data/adb/modules/adaway_mount_helper/system/etc/hosts > "$MODPATH/system/etc/hosts"
elif [ -f /system/etc/hosts ]; then
	echo "[+] Copying system hosts file"
	cat /system/etc/hosts > "$MODPATH/system/etc/hosts"
else
	echo "[+] Creating minimal hosts file"
	printf "127.0.0.1 localhost\n::1 localhost\n" > "$MODPATH/system/etc/hosts"
fi

# Set proper permissions
chmod 644 "$MODPATH/system/etc/hosts"
chown root:root "$MODPATH/system/etc/hosts" 2>/dev/null || true

echo "[+] Installation complete"
echo "[*] AdAway should now be able to modify the hosts file"
