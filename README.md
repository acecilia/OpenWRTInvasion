# Root shell exploit for the router Xiaomi 4A Gigabit Global Edition, firmware version 2.28.132

## How to run

**NOTE: FROM VERSION `0.0.2` THE ROUTER NEEDS INTERNET ACCESS**. If you require to run the exploit without internet access please try version `0.0.1`. Find the versions here: https://github.com/acecilia/OpenWRTInvasion/releases

```shell
pip3 install -r requirements.txt # Install requirements
python3 remote_command_execution_vulnerability.py # Run the script
```

After that, a letnet server will be up and running on the router. You can connect to it by running:

```
telnet <router_ip_address>
```

* User: root
* Password: none (just hit enter)

The script also starts an ftp server at port 21, so you can get access to the filesystem using a GUI (for example [cyberduck](https://cyberduck.io)).

## Install OpenWrt

**NOTE: LATEST SNAPSHOT FIRMWARE DOES NOT WORK AT THE MOMENT (10/04/2020), AND WILL BRICK YOUR DEVICE**. Please, **READ THE [LATEST POSTS IN THE OPENWRT FORUM](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685) BEFORE PROCEEDING**. Until OpenWrt fixes the problem, you can use the firmware files provided by other users **AT YOUR OWN RISK**:

* User [zorro](https://forum.openwrt.org/u/zorro) provided http://www.mediafire.com/file/0qetz7rm8n9hr04/openwrt-ramips-mt7621-xiaomi_mir3g-v2-squashfs-sysupgrade.bin/file ([OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/412))
* User [zorro](https://forum.openwrt.org/u/zorro) provided https://anonfile.com/LbueT2n8o4/openwrt-ramips-mt7621-xiaomi_mir3g-v2-squashfs-sysupgrade_bin ([OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/448))

After login to the router through telnet, run:

```shell
cd /tmp
curl https://downloads.openwrt.org/snapshots/targets/ramips/mt7621/openwrt-ramips-mt7621-xiaomi_mir3g-v2-squashfs-sysupgrade.bin --output firmware.bin # Put here the URL you want to use to download the firmware
./busybox sha256sum firmware.bin # Verify the firmware checksum before flashing, very important to avoid bricking your device!
mtd -e OS1 -r write firmware.bin OS1 # Install OpenWrt
```

This will install the snapshot version of OpenWrt (without Luci). You can now use ssh to connect to the router (and install Luci if you prefer it).

### Performance:

Some users have reported worse WIFI performance in OpenWrt than in the stock firmware. See the following links:

* [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/430)
* [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/431)
* [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/451)

## Other supported routers or firmware versions

* MiRouter 4A Gigabit: user [ksc91u](https://forum.openwrt.org/u/ksc91u) claims that this method also works on firmware version `2.28.62`: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/359).
* MiRouter 4A 100M (non gigabit): user [morhimi](https://forum.openwrt.org/u/morhimi) claims that this method works on firmware version `2.18.51`: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/372). User [Jeffpeng](https://forum.openwrt.org/u/jeffpeng) claims that this method works on firmware version `2.18.58`: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/373).
* MiRouter 4C: user [Jeffpeng](https://forum.openwrt.org/u/jeffpeng) claims that this method works on firmware version `2.14.81`: [OpenWrt forum](https://forum.openwrt.org/t/support-for-xiaomi-mi-router-4c-r4cm/36418/31).
* Mi Router 3Gv2: user [Massimiliano Mangoni](massimiliano.mangoni@gmail.com) claims that this method also works on firmware version `2.28.8` (message posted in Slack).
* Mi Router 4Q (aka R4C): user cadaverous claims that this method also works on firmware version `2.28.48` (message posted in Slack), but because the router is mips architecture (not mipsel), he needed to use version `0.0.1` of the script (the other versions use a busybox binary built for the mipsel architecture that is used to start a telnet sever).

## For more info and support go to:

* [OpenWrt forum thread](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685)
* [Slack workspace](https://join.slack.com/t/openwrt-workspace/shared_invite/zt-cz2m5uf4-Q8wbP_LKggOy9B7IQyaqfA)

## If you brick your device

You can find solutions in the following links:

* User [albertcp](https://forum.openwrt.org/u/albertcp) posted a very detailed guide: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/402)
* User [micky0867](https://forum.openwrt.org/u/micky0867) has some more comments about the topic: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/391)

## Acknowledgments

* Original vulnerabilities and exploit: [UltramanGaia](https://github.com/UltramanGaia/Xiaomi_Mi_WiFi_R3G_Vulnerability_POC)
* Instructions to install OpenWrt after exploit execution: [rogerpueyo](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/21)
* Testing and detailed install instructions: [hey07](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/349)

## Demo

### Version 0.0.2 and higher: telnet

![Alt Text](readme/exploit-002.gif)

### Version 0.0.1: netcat (legacy)

![Alt Text](readme/exploit-001.gif)
