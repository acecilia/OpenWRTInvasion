#!/usr/bin/env bash
set -euo pipefail

ROUTER_IP="${ROUTER_IP:-192.168.1.1}"
HOST_IP="${HOST_IP:-192.168.1.2}"
MODE="${MODE:-auto}"
PASSWORD="${PASSWORD:-}"
FIRMWARE_PATH=""
FIRMWARE_URL=""

usage() {
  cat <<'EOF'
Usage: ./openwrt-auto.sh [options]

Options:
  --ip <addr>             Router IP (default: 192.168.1.1)
  --host-ip <addr>        Host IP to assign on the Ethernet interface (default: 192.168.1.2)
  --password <pw>         Router admin password
  --firmware <path>       Local OpenWrt image file (factory or sysupgrade image)
  --firmware-url <url>    Download an OpenWrt image from a URL first
  --mode <auto|web|tftp>  Upload method to try (default: auto)
  -h, --help              Show this help message

Examples:
  ./openwrt-auto.sh --firmware ./openwrt.bin --password admin
  ./openwrt-auto.sh --firmware-url https://example.com/openwrt.bin --ip 192.168.1.1
EOF
}

log() {
  echo "[openwrt-auto] $*"
}

die() {
  echo "[openwrt-auto] ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ip)
        [[ $# -ge 2 ]] || die "--ip requires a value"
        ROUTER_IP="$2"
        shift 2
        ;;
      --host-ip)
        [[ $# -ge 2 ]] || die "--host-ip requires a value"
        HOST_IP="$2"
        shift 2
        ;;
      --password)
        [[ $# -ge 2 ]] || die "--password requires a value"
        PASSWORD="$2"
        shift 2
        ;;
      --firmware)
        [[ $# -ge 2 ]] || die "--firmware requires a value"
        FIRMWARE_PATH="$2"
        shift 2
        ;;
      --firmware-url)
        [[ $# -ge 2 ]] || die "--firmware-url requires a value"
        FIRMWARE_URL="$2"
        shift 2
        ;;
      --mode)
        [[ $# -ge 2 ]] || die "--mode requires a value"
        MODE="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
  done
}

prepare_firmware() {
  local tmp_dir="$1"
  if [[ -n "$FIRMWARE_PATH" ]]; then
    [[ -f "$FIRMWARE_PATH" ]] || die "Firmware file not found: $FIRMWARE_PATH"
    cp "$FIRMWARE_PATH" "$tmp_dir/openwrt-image.bin"
    return
  fi

  if [[ -n "$FIRMWARE_URL" ]]; then
    require_cmd curl
    log "Downloading firmware from $FIRMWARE_URL"
    curl -fsSL "$FIRMWARE_URL" -o "$tmp_dir/openwrt-image.bin"
    return
  fi

  die "No firmware source provided. Use --firmware or --firmware-url."
}

ask_password() {
  if [[ -n "$PASSWORD" ]]; then
    return
  fi

  read -r -s -p "Router admin password: " PASSWORD
  echo
  [[ -n "$PASSWORD" ]] || die "Password cannot be empty"
}

get_stok() {
  local page_file="$1"
  local login_file="$2"
  local login_page
  local mac
  local key

  require_cmd curl
  require_cmd python3

  log "Fetching login page from http://$ROUTER_IP/cgi-bin/luci/web"
  curl -fsSL "http://$ROUTER_IP/cgi-bin/luci/web" -o "$page_file" || return 1

  mac=$(grep -oE "deviceId = '[^']+'" "$page_file" | head -n 1 | sed "s/.*'//;s/'//") || true
  key=$(grep -oE "key: '[^']+'" "$page_file" | head -n 1 | sed "s/.*'//;s/'//") || true

  [[ -n "$mac" && -n "$key" ]] || return 1

  local nonce="0_${mac}_$(date +%s)_$((RANDOM % 9000 + 1000))"
  local account_hash
  local password_hash

  account_hash=$(python3 - "$PASSWORD" "$key" <<'PY'
import hashlib, sys
password, key = sys.argv[1], sys.argv[2]
print(hashlib.sha1((password + key).encode('utf-8')).hexdigest())
PY
)

  password_hash=$(python3 - "$nonce" "$account_hash" <<'PY'
import hashlib, sys
nonce, account_hash = sys.argv[1], sys.argv[2]
print(hashlib.sha1((nonce + account_hash).encode('utf-8')).hexdigest())
PY
)

  curl -fsSL -X POST "http://$ROUTER_IP/cgi-bin/luci/api/xqsystem/login" \
    -H 'User-Agent: Mozilla/5.0' \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    --data "username=admin&password=$password_hash&logtype=2&nonce=$nonce" \
    -o "$login_file" || return 1

  python3 - "$login_file" <<'PY'
import re, sys
from pathlib import Path
p = Path(sys.argv[1])
text = p.read_text(encoding='utf-8', errors='ignore')
match = re.search(r'"token":"([^"]+)"', text)
if not match:
    sys.exit(1)
print(match.group(1))
PY
}

try_web_flash() {
  local page_file="$1"
  local login_file="$2"
  local upload_file="$3"
  local stok

  if ! stok=$(get_stok "$page_file" "$login_file"); then
    log "Web login failed; falling back to recovery mode if requested"
    return 1
  fi

  log "Uploading firmware to the router via the stock web interface"
  curl -fsSL -X POST "http://$ROUTER_IP/cgi-bin/luci/;stok=$stok/api/misystem/upgrade" \
    -H 'User-Agent: Mozilla/5.0' \
    -F "image=@$upload_file;type=application/octet-stream" \
    -o "$upload_file.response" || true

  if [[ -s "$upload_file.response" ]]; then
    log "Upload request completed. The router may reboot automatically."
    log "If it does not reboot within a few minutes, wait and check the router status manually."
    return 0
  fi

  log "Primary upload endpoint did not return a usable response; trying the backup upload endpoint"
  curl -fsSL -X POST "http://$ROUTER_IP/cgi-bin/luci/;stok=$stok/api/misystem/c_upload" \
    -H 'User-Agent: Mozilla/5.0' \
    -F "image=@$upload_file;type=application/octet-stream" \
    -o "$upload_file.response" || true

  if [[ -s "$upload_file.response" ]]; then
    log "Upload request completed. The router may reboot automatically."
    return 0
  fi

  return 1
}

prepare_tftp_environment() {
  require_cmd ip

  local iface
  iface=$(ip route get 1.1.1.1 2>/dev/null | awk '/dev/ {print $5; exit}') || true
  [[ -n "$iface" ]] || die "Could not determine the active Ethernet interface"

  log "Configuring $iface with $HOST_IP/24"
  ip addr replace "$HOST_IP/24" dev "$iface" 2>/dev/null || ip addr add "$HOST_IP/24" dev "$iface"
  ip link set "$iface" up
}

try_tftp_flash() {
  local firmware_path="$1"
  require_cmd tftp

  log "Please put the router into recovery mode now."
  log "Typical steps: hold the reset button while powering on, then wait for the recovery state."
  read -r -p "Press Enter once the router is in recovery mode and reachable at $ROUTER_IP... "

  prepare_tftp_environment

  log "Sending firmware over TFTP to $ROUTER_IP"
  tftp "$ROUTER_IP" <<EOF
binary
put "$firmware_path" openwrt.bin
quit
EOF

  log "The transfer command has been issued. Wait a few minutes for the router to flash and reboot."
}

main() {
  parse_args "$@"

  [[ "$MODE" =~ ^(auto|web|tftp)$ ]] || die "Unsupported mode: $MODE"
  [[ -n "$ROUTER_IP" ]] || die "Router IP is empty"
  [[ -n "$HOST_IP" ]] || die "Host IP is empty"

  require_cmd python3
  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT

  prepare_firmware "$tmp_dir"
  local firmware_path="$tmp_dir/openwrt-image.bin"

  log "Firmware image prepared at $firmware_path"
  ask_password

  if [[ "$MODE" == "web" || "$MODE" == "auto" ]]; then
    if try_web_flash "$tmp_dir/login_page.html" "$tmp_dir/login.json" "$firmware_path"; then
      exit 0
    fi
  fi

  if [[ "$MODE" == "tftp" || "$MODE" == "auto" ]]; then
    try_tftp_flash "$firmware_path"
    exit 0
  fi

  die "The installation flow did not complete successfully"
}

main "$@"
