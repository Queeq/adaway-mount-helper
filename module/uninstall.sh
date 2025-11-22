#!/bin/sh

# Cleanup redirect locations used by special modes
[ -f /data/adb/hosts ] && printf "127.0.0.1 localhost\n::1 localhost\n" > /data/adb/hosts
[ -f /data/adb/hostsredirect/hosts ] && printf "127.0.0.1 localhost\n::1 localhost\n" > /data/adb/hostsredirect/hosts

echo "AdAway Mount Helper uninstalled"
