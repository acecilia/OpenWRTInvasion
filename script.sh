########################################
# Download standalone busybox and start telnet
# busybox binary downloaded from https://www.busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-mipsel
########################################
passwd -d root # Remove root password, as the default one set by xiaomi is unknown

# kill/stop telnet, in case it is running from a previous execution
pgrep busybox | xargs kill

cd /tmp
rm -rf busybox
curl "https://www.busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-mipsel" --output busybox
chmod +x busybox

# Start telnet
./busybox telnetd

# Start FTP server
ln -sfn busybox ftpd # Create symlink needed for running ftpd
./busybox tcpsvd -vE 0.0.0.0 21 ./ftpd -Sw / >> /tmp/messages 2>&1 &

# Remount /usr/share/xiaoqiang as read-write
# cp -R /usr/share/xiaoqiang /tmp/xiaoqiang
# mount --bind /tmp/xiaoqiang /usr/share/xiaoqiang

echo "Script executed"