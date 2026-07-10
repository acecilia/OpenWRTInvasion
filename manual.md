# openwrt-auto.sh Manual

## Purpose

This script automates the process of installing OpenWrt on a Xiaomi AX3000T-compatible router from Linux.

It supports two installation approaches:

- Web-based upload through the stock router web interface
- Recovery-mode TFTP upload when the web interface is unavailable

## Requirements

Before using the script, make sure you have:

- A Linux system with Bash
- Python 3 installed
- curl installed
- Optional for TFTP mode: tftp installed
- An OpenWrt firmware image file, or a direct URL to download it
- The router's admin password, if the web-based method is used

## Usage

```bash
./openwrt-auto.sh --firmware /path/to/openwrt-image.bin --password YOUR_PASSWORD
```

### Menu-driven use

```bash
./openwrt-auto.sh
```

The menu allows you to:

- flash OpenWrt firmware
- install AdGuard Home on an existing OpenWrt router
- exit

### AdGuard Home installation

```bash
./openwrt-auto.sh --action adguard --ip 192.168.1.1 --password YOUR_PASSWORD
```

This runs the OpenWrt package installation flow for AdGuard Home and enables the service.

### Common options

- `--ip <address>`: router IP address (default: `192.168.1.1`)
- `--host-ip <address>`: host IP assigned to the local network interface for recovery mode (default: `192.168.1.2`)
- `--password <password>`: router admin password
- `--firmware <path>`: local OpenWrt firmware image path
- `--firmware-url <url>`: URL to download the firmware image from
- `--mode <auto|web|tftp>`: installation method
  - `auto`: tries web upload first, then TFTP fallback
  - `web`: uses the stock web interface only
  - `tftp`: uses recovery-mode TFTP only

## Examples

### Install from a local file

```bash
./openwrt-auto.sh --firmware ./openwrt.bin --password admin
```

### Install from a URL

```bash
./openwrt-auto.sh --firmware-url https://example.com/openwrt.bin --ip 192.168.1.1
```

### Force TFTP mode

```bash
./openwrt-auto.sh --mode tftp --firmware ./openwrt.bin
```

## Notes

- The script is intended as a helper for Linux-based flashing workflows.
- Web-based flashing may require the router to already be reachable and the admin credentials to be valid.
- TFTP mode requires the router to be in recovery mode and the host to be configured appropriately.
- Always verify the firmware image is correct for your exact router model before flashing.

## Safety warning

Flashing custom firmware can brick the device if the wrong image is used or the process is interrupted. Proceed only with a firmware image that is known to be compatible with your hardware.
