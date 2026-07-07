#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  wifi5
  wifi5 "PROFILE_5G"
  wifi5 "PROFILE_5G" "PROFILE_2G"
  wifi5 --list

Examples:
  wifi5
  wifi5 "Auto FAMILIA NORIA-AC"
  wifi5 "Auto FAMILIA NORIA-AC" "Auto FAMILIA NORIA-1"

What it does:
  - Sets the selected Wi-Fi profile to prefer 5 GHz: band "a"
  - Raises its autoconnect priority to 100
  - Disables Wi-Fi power saving for that profile
  - Optionally lowers a 2.4 GHz profile priority to -10
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

need_nmcli() {
  command -v nmcli >/dev/null 2>&1 || die "nmcli is required"
}

active_wifi_connection() {
  nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status |
    awk -F: '$2 == "wifi" && $3 == "connected" { print $4; exit }'
}

list_wifi() {
  nmcli device wifi list
  printf '\nSaved Wi-Fi profiles:\n'
  printf '%-40s %-12s %-12s\n' "NAME" "AUTOCONNECT" "PRIORITY"
  nmcli -t -f NAME,TYPE,AUTOCONNECT,AUTOCONNECT-PRIORITY connection show |
    awk -F: '$2 == "802-11-wireless" || $2 == "wifi" { printf "%-40s %-12s %-12s\n", $1, $3, $4 }'
}

ensure_connection_exists() {
  local profile="$1"
  nmcli -t -f NAME connection show | grep -Fxq "$profile" ||
    die "connection profile not found: $profile"
}

prefer_5g_profile() {
  local profile="$1"

  ensure_connection_exists "$profile"

  nmcli connection modify "$profile" \
    connection.autoconnect yes \
    connection.autoconnect-priority 100 \
    802-11-wireless.band a \
    802-11-wireless.powersave 2

  printf 'Prefer 5 GHz: %s\n' "$profile"
}

deprioritize_profile() {
  local profile="$1"

  ensure_connection_exists "$profile"

  nmcli connection modify "$profile" \
    connection.autoconnect yes \
    connection.autoconnect-priority -10 \
    802-11-wireless.powersave 2

  printf 'Lower priority: %s\n' "$profile"
}

main() {
  need_nmcli

  case "${1:-}" in
    -h|--help)
      usage
      exit 0
      ;;
    --list)
      list_wifi
      exit 0
      ;;
  esac

  local prefer_profile="${1:-}"
  local lower_profile="${2:-}"

  if [ -z "$prefer_profile" ]; then
    prefer_profile="$(active_wifi_connection)"
    [ -n "$prefer_profile" ] || die "no active Wi-Fi connection found"
  fi

  prefer_5g_profile "$prefer_profile"

  if [ -n "$lower_profile" ]; then
    deprioritize_profile "$lower_profile"
  fi

  printf '\nCurrent Wi-Fi status:\n'
  nmcli device status | awk '$2 == "wifi" || NR == 1'
  printf '\nVisible networks:\n'
  nmcli device wifi list
}

main "$@"
