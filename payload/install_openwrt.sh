#!/bin/ash
set -euo pipefail
[ -f ./openwrt-squashfs-kernel1.bin ] || exit
[ -f ./openwrt-squashfs-rootfs0.bin ] || exit
mtd write openwrt-squashfs-kernel1.bin kernel1
mtd write openwrt-squashfs-rootfs0.bin rootfs0
nvram set flag_try_sys1_failed=1
nvram commit
reboot
