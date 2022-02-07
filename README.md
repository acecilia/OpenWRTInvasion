# Root shell exploit for several Xiaomi routers: 4A Gigabit, 4A 100M, 4C, 3Gv2, 4Q, miWifi 3C...

## How to run

**NOTE: FROM VERSION `0.0.2` THE ROUTER NEEDS INTERNET ACCESS**. If you require to run the exploit without internet access please try version `0.0.1`. Find the versions here: https://github.com/acecilia/OpenWRTInvasion/releases
**NOTE: THERE ARE REPORTED ISSUES WITH ROUTER IN AP MODE**. If you're not able to succeed in the AP mode, try to switch to some other (WiFi Repeater or Gateway)

### Using Docker (also works on Windows)

```console
$ docker build -t openwrtinvasion https://github.com/acecilia/OpenWRTInvasion.git
$ docker run --network host -it openwrtinvasion
```

### Using the command line

```shell
pip3 install -r requirements.txt # Install requirements
python3 remote_command_execution_vulnerability.py # Run the script
```

You will be asked for the router IP address and for the `stok`. You can grab the `stok` from the router URL after you log in to the admin interface:

![](readme/readme-001.png)

Note that [the script must be run from the same IP address used when login into the router](https://github.com/acecilia/OpenWRTInvasion/issues/97).

After that, a telnet server will be up and running. You can connect to it by running:

```
telnet <router_ip_address>
```

* User: `root`
* Password: `root`

The script also starts an ftp server at port 21, so you can get access to the filesystem using a GUI (for example [cyberduck](https://cyberduck.io)).

## Supported routers and firmware versions

* MiRouter 4A Gigabit: user [ksc91u](https://forum.openwrt.org/u/ksc91u) claims that this method also works on firmware version `2.28.62`, `2.28.65` and  `2.28.132`: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/359). It is also working on the latest `3.0.24` firmware: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-and-flashable-with-openwrtinvasion/36685/1135).
* MiRouter 4A 100M (non gigabit): user [morhimi](https://forum.openwrt.org/u/morhimi) claims that this method works on firmware version `2.18.51`: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/372). User [Jeffpeng](https://forum.openwrt.org/u/jeffpeng) claims that this method works on firmware version `2.18.58`: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/373). Find a troubleshooting guide [here](https://github.com/acecilia/OpenWRTInvasion/issues/92).
* MiRouter 4C: user [Jeffpeng](https://forum.openwrt.org/u/jeffpeng) claims that this method works on firmware version `2.14.81`: [OpenWrt forum](https://forum.openwrt.org/t/support-for-xiaomi-mi-router-4c-r4cm/36418/31). User [AddaxSoft](https://github.com/acecilia/OpenWRTInvasion/issues/73) claims that exploit version `0.0.1` works on firmware version `2.14.87`. Find [here](https://github.com/acecilia/OpenWRTInvasion/issues/89) a troubleshooting guide for this router
* Mi Router 3Gv2: user [Massimiliano Mangoni](massimiliano.mangoni@gmail.com) claims that this method also works on firmware version `2.28.8` (message posted in Slack).
* Mi Router 4Q (aka R4C): user cadaverous claims that this method also works on firmware version `2.28.48` (message posted in Slack), but because the router is mips architecture (not mipsel), he needed to use version `0.0.1` of the script (the other versions use a busybox binary built for the mipsel architecture that is used to start a telnet sever).
* MiWifi 3C: works on firmware versions `2.9.217`, `2.14.45` and `2.8.51_INT`: [OpenWrt forum](https://forum.openwrt.org/t/support-for-xiaomi-miwifi-3c/11643/23), [OpenWrt forum](https://forum.openwrt.org/t/support-for-xiaomi-miwifi-3c/11643/17).
* [Mi Router 4](https://www.mi.com/miwifi4): user [Firef0x](https://github.com/acecilia/OpenWRTInvasion/issues/21#issuecomment-748619870) claims that exploit version `0.0.1` works on firmware version `2.26.175`. User [AddaxSoft](https://github.com/acecilia/OpenWRTInvasion/issues/73) claims that exploit version `0.0.1` works on firmware version `2.18.62`.
* Xiaomi Mi R3P: user [lukasz1992](https://github.com/acecilia/OpenWRTInvasion/issues/58) claims that the exploit works with the Xiaomi Dev firmware.
* [Xiaomi 3Gv1](https://openwrt.org/toh/hwdata/xiaomi/xiaomi_miwifi_3g): user [krumelmonster](https://github.com/acecilia/OpenWRTInvasion/issues/68#issue-814768067) claims that exploit works with the stock firmware coming with the router.
* [AC2350 AIOT](https://www.mi.com/global/mi-aiot-router-ac2350/): user [dobosz23](https://github.com/acecilia/OpenWRTInvasion/issues/46#issuecomment-774784301) claims that exploit version `0.0.6` works on firmware version `1.3.8CN`.

## Xiaomi 4A Gigabit Global Edition

### Firmwares

This repository contains the following firmwares:

* Official Xiaomi - `2.28.62` - in Chinese. SHA256: `a3db7f937d279cf38c2a3bec09772d65`
  * URL in this repository: https://github.com/acecilia/OpenWRTInvasion/raw/master/firmwares/stock/miwifi_r4a_firmware_72d65_2.28.62.bin
* Official Xiaomi - `3.0.24` - in English. MD5: `9c4a60addaad76dc13b6df6b4ac03233`
  * URL in this repository: https://github.com/acecilia/OpenWRTInvasion/raw/master/firmwares/stock/miwifi_r4a_all_03233_3.0.24_INT.bin
  * URL in the official Xiaomi site: http://cdn.awsde0-fusion.fds.api.mi-img.com/xiaoqiang/rom/r4a/miwifi_r4a_all_03233_3.0.24_INT.bin

If you have a pending update in your Xiaomi stock firmware, you can check its md5 hash and the download url by navigating to:

```
http://192.168.31.1/cgi-bin/luci/;stok=<stok>/api/xqsystem/check_rom_update
```

### Install OpenWrt

When installing OpenWrt on the Xiaomi 4A Gigabit, there are several options:

* **[PREFERRED OPTION]**: use the latest supported stable release of OpenWrt. Find it in the [official OpenWrt wiki page](https://openwrt.org/inbox/toh/xiaomi/xiaomi_mi_router_4a_gigabit_edition)

* Build your own image with `imagebuilder`, using the latest source code on `master`:

  ```
  docker pull openwrtorg/imagebuilder:ramips-mt7621-master
  docker run --rm -v "$(pwd)"/bin/:/home/build/openwrt/bin -it openwrtorg/imagebuilder:ramips-mt7621-master
  make PROFILE=xiaomi_mir3g-v2 image
  ```

If **after reading above text** you still want to proceed, after login to the router through telnet run the following commands:

```shell
cd /tmp
curl https://raw.githubusercontent.com/acecilia/OpenWRTInvasion/master/firmwares/OpenWrt/06-06-2020/openwrt-ramips-mt7621-xiaomi_mir3g-v2-squashfs-sysupgrade.bin --output firmware.bin # Put here the URL you want to use to download the firmware
./busybox sha256sum firmware.bin # Verify the firmware checksum before flashing, very important to avoid bricking your device!
mtd -e OS1 -r write firmware.bin OS1 # Install OpenWrt
```

This will install the snapshot version of OpenWrt (without Luci). You can now use ssh to connect to the router (and install Luci if you prefer it).

### Performance:

Some users have reported worse WIFI performance in OpenWrt than in the stock firmware. See the following links:

* [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/430)
* [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/431)
* [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/451)

## For more info and support go to:

* [OpenWrt forum thread](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685)

## If you brick your device

You can find solutions in the following links:

* User [albertcp](https://forum.openwrt.org/u/albertcp) posted a very detailed guide: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/402)
* User [micky0867](https://forum.openwrt.org/u/micky0867) has some more comments about the topic: [OpenWrt forum](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/391)
* User [hoddy](https://forum.openwrt.org/u/hoddy) created a [video tutorial](https://www.youtube.com/watch?v=VxzEvdDWU_s)

## Acknowledgments

* Original vulnerabilities and exploit: [UltramanGaia](https://github.com/UltramanGaia/Xiaomi_Mi_WiFi_R3G_Vulnerability_POC)
* Instructions to install OpenWrt after exploit execution: [rogerpueyo](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/21)
* Testing and detailed install instructions: [hey07](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-but-requires-overwriting-spi-flash-with-programmer/36685/349)
* Checking the URL of pending updates: [sicklesareterrible](https://forum.openwrt.org/t/xiaomi-mi-router-4a-gigabit-edition-r4ag-r4a-gigabit-fully-supported-and-flashable-with-openwrtinvasion/36685/1114?u=acecilia)

## Demo

### Version 0.0.2 and higher: telnet

![Alt Text](readme/exploit-002.gif)

### Version 0.0.1: netcat (legacy)

![Alt Text](readme/exploit-001.gif)
