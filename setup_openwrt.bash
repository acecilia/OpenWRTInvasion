#!/bin/bash
set -euo pipefail
echo "The script will install OpenWrt firmware on the Xiomi router."
echo "First we need to download the OpenWrt for your router model."

payload_dir=$(mktemp -d)
echo "Files will be downloaded to $payload_dir"

echo "Please select your model:"
echo "1. Xiomi 3G v1 (with USB) https://openwrt.org/toh/xiaomi/mir3g"
echo "2. Xiomi 3G v2 without USB https://openwrt.org/toh/xiaomi/mir3g"
echo "Type a number:"
read router_model
case "$router_model" in
  "1")
    echo "Download openwrt-22.03.0-ramips-mt7621-xiaomi_mi-router-3g"
    curl -L https://downloads.openwrt.org/releases/22.03.0/targets/ramips/mt7621/openwrt-22.03.0-ramips-mt7621-xiaomi_mi-router-3g-squashfs-kernel1.bin -o "$payload_dir/openwrt-squashfs-kernel1.bin" -z "$payload_dir/openwrt-squashfs-kernel1.bin"
    curl -L https://downloads.openwrt.org/releases/22.03.0/targets/ramips/mt7621/openwrt-22.03.0-ramips-mt7621-xiaomi_mi-router-3g-squashfs-rootfs0.bin -o "$payload_dir/openwrt-squashfs-rootfs0.bin" -z "$payload_dir/openwrt-squashfs-rootfs0.bin"
  ;;
  "2")
    echo "Not implemented yet, sorry"
    exit 3
  ;;
  *)
    echo "Your select is wrong"
    exit 2
esac

echo "Prepare payload.tar.gz"
cp ./payload/* "$payload_dir"
(cd "$payload_dir" && tar -I "gzip -1" -cvf /tmp/payload.tar.gz ./)
echo "The payload.tar.gz is ready for a shot:"
ls -l /tmp/payload.tar.gz

router_url="http://miwifi.com/cgi-bin/luci/;stok=04a76647de2b1d602d43cd131573f8ac/web/home#router"
echo ""
echo "Now let's install the firmware on the router."
echo "Reset router to it's factory settings with a needle pushed into a Reset hole."
echo "Then connect to it's WiFi and open your router admin panel at http://miwifi.com"
echo "Now set admin and wifi passwords and you'll see a dashboard."
echo "The URL in browser's address bar should look like $router_url"
echo "Now copy and paste here it's URL:"
read router_url
# strip after stok
router_base_url=( $(sed -e 's/\(.*stok=.*\)\/web\(.*\)/\1/' <<< "$router_url") )
echo router_base_url
curl -v -F 'image=@payload/payload.tar.gz' "$router_base_url/api/misystem/c_upload"
curl -v "$router_base_url/api/xqnetdetect/netspeed"
echo $?
echo "Now the router should reboot itself. Please wait for a minute."
echo "Try to connect with a cable and open OpenWrt Luci admin panel at http://192.168.1.1/"
