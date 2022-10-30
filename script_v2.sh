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

setup_password() {
    # Override existing password, as the default one set by xiaomi is unknown
    # https://www.systutorials.com/changing-linux-users-password-in-one-command-line/
    echo -e "root\nroot" | passwd root
}

setup_busybox() {
    # kill/stop telnet, in case it is running from a previous execution
    pgrep busybox | xargs kill || true

    cd /tmp
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

# From https://stackoverflow.com/a/16159057
"$@"
