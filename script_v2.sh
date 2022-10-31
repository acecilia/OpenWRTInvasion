#!/bin/ash
LOGFILE="/tmp/exploit.log"

set -euo pipefail

exploit() {
    echo "start Exploit" >> $LOGFILE
    echo "setup_password" >> $LOGFILE
    setup_password

    echo "setup_busybox" >> $LOGFILE
    setup_busybox

    echo "start_telnet" >> $LOGFILE
    start_telnet

    echo "start_ftp" >> $LOGFILE
    start_ftp

    echo "start_ssh" >> $LOGFILE
    start_ssh
    echo "Done exploiting" >> $LOGFILE
}

setup_password() {
    # Override existing password, as the default one set by xiaomi is unknown
    # https://www.systutorials.com/changing-linux-users-password-in-one-command-line/
    echo "setting password for root" >> $LOGFILE
    echo -e "root\nroot" | passwd root
    echo "password set" >> $LOGFILE
}

setup_busybox() {
    
    echo "kill/stop telnet, in case it is running from a previous execution" >> $LOGFILE
    pgrep busybox | xargs kill || true
    
    echo "go to /tmp" >> $LOGFILE
    cd /tmp >> $LOGFILE 2>&1

    echo "chmod a+x to busybox" >> $LOGFILE
    chmod a+x busybox >> $LOGFILE 2>&1
}

start_ftp() {
    echo "go to /tmp" >> $LOGFILE
    cd /tmp >> $LOGFILE 2>&1
    echo "create link" >> $LOGFILE
    ln -sfn busybox ftpd >> $LOGFILE 2>&1 # Create symlink needed for running ftpd

    echo "starting ftp" >> $LOGFILE
    ./busybox tcpsvd -vE 0.0.0.0 21 ./ftpd -Sw / >> /tmp/messages 2>&1 &
    echo "ftp done" >> $LOGFILE
}

start_telnet() {
    echo "go to /tmp" >> $LOGFILE
    cd /tmp >> $LOGFILE 2>&1

    echo "start telnet" >> $LOGFILE
    ./busybox telnetd >> $LOGFILE 2>&1
    echo "telnet done" >> $LOGFILE
}

start_ssh() {
    echo "go to /tmp" >> $LOGFILE
    cd /tmp >> $LOGFILE 2>&1

    echo "kill/stop dropbear, in case it is running from a previous execution" >> $LOGFILE
    pgrep dropbear | xargs kill || true
    sleep 2 # wait for the kill

    echo "clean old installation" >> $LOGFILE
    rm -rf /tmp/dropbear >> $LOGFILE 2>&1
    rm -rf /tmp/dropbearStaticMipsel >> $LOGFILE 2>&1 # for old stuck files
    rm -f /tmp/dropbear.tar >> $LOGFILE 2>&1 # for old stuck files
    rm -rf /etc/dropbear >> $LOGFILE 2>&1

    echo "Unzipping dropbear static mipsel binary" >> $LOGFILE 
    bunzip2 -f /tmp/dropbear.tar.bz2 >> $LOGFILE 2>&1

    echo "Untarring dropbear static mipsel binary" >> $LOGFILE 
    tar -xf /tmp/dropbear.tar >> $LOGFILE 2>&1

    echo "moving untared dropbear" >> $LOGFILE 
    mv /tmp/dropbearStaticMipsel /tmp/dropbear >> $LOGFILE 2>&1

    # Add keys
    # http://www.ibiblio.org/elemental/howto/dropbear-ssh.html
    echo "create dropbear folder in etc" >> $LOGFILE 
    mkdir -p /etc/dropbear >> $LOGFILE 2>&1

    echo "go to /etc/dropbear" >> $LOGFILE 
    cd /etc/dropbear >> $LOGFILE 2>&1

    echo "creating RSA Key" >> $LOGFILE 
    /tmp/dropbear/dropbearkey -t rsa -f dropbear_rsa_host_key >> $LOGFILE 2>&1
    
    echo "creating DSS Key" >> $LOGFILE 
    /tmp/dropbear/dropbearkey -t dss -f dropbear_dss_host_key >> $LOGFILE 2>&1

    echo "Start SSH server" >> $LOGFILE 
    /tmp/dropbear/dropbear >> $LOGFILE 2>&1
    sleep 2 # wait for the start
    
    echo "SSH done" >> $LOGFILE 

    # https://unix.stackexchange.com/a/402749
    # Login with ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c 3des-cbc root@192.168.0.21
}

# From https://stackoverflow.com/a/16159057
"$@"
