#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# OD&H Docker TorProxy Entrypoint Script

# --- Configuration ---

SOCKS_PORT="${TOR_SOCKS_PORT:-1080}"
HTTP_PORT="${TOR_HTTP_PORT:-8080}"
CONTROL_PORT="${TOR_CONTROL_PORT:-}"
CONTROL_PASSWD="${TOR_CONTROL_PASSWD:-}"
BRIDGE="${TOR_BRIDGE:-}"
USE_BRIDGES="${TOR_USE_BRIDGES:-0}"
CUSTOM_CONFIG="${TOR_CUSTOM_CONFIG:-}"
TORRC_PATH="/etc/tor/torrc"
TORRC_D_PATH="/etc/tor/torrc.d"

# --- Helper Functions ---

log() {
  echo "$(date -Is) [INFO] $*"
}

error() {
  echo "$(date -Is) [ERROR] $*" >&2
  exit 1
}

append_config() {
  local key="$1"
  local value="$2"
  if [[ -n "$value" ]]; then
    echo "$key $value" >> "$TORRC_PATH"
    log "Set: $key $value"
  fi
}

# --- Initialization ---

log "Initializing OD&H Docker TorProxy..."

mkdir -p "$TORRC_D_PATH"
: > "$TORRC_PATH"  # Truncate torrc

# --- Core Tor Settings ---

append_config "SocksPort" "$SOCKS_PORT"
append_config "DNSPort" "53"
append_config "AutomapHostsOnResolve" "1"

if [[ -n "$HTTP_PORT" ]]; then
  append_config "TransPort" "$HTTP_PORT"
fi

if [[ -n "$BRIDGE" ]]; then
  append_config "Bridge" "$BRIDGE"
  USE_BRIDGES=1
fi

if [[ "$USE_BRIDGES" -eq 1 ]]; then
  append_config "UseBridges" "1"
fi

if [[ -n "$CONTROL_PORT" ]]; then
  [[ -z "$CONTROL_PASSWD" ]] && error "CONTROL_PORT set, but CONTROL_PASSWD missing"
  append_config "ControlPort" "$CONTROL_PORT"
  HASHED_PASS=$(tor --hash-password "$CONTROL_PASSWD" | grep -o '16:[A-Z0-9]*$' || true)
  [[ -z "$HASHED_PASS" ]] && error "Failed to hash control password"
  append_config "HashedControlPassword" "$HASHED_PASS"
fi

# --- Custom & Additional Config ---

if [[ -n "$CUSTOM_CONFIG" ]]; then
  log "Appending custom configuration..."
  echo "$CUSTOM_CONFIG" >> "$TORRC_PATH"
fi

if [[ -d "$TORRC_D_PATH" ]]; then
  for file in "$TORRC_D_PATH"/*; do
    [[ -f "$file" ]] && {
      log "Including config: $file"
      cat "$file" >> "$TORRC_PATH"
    }
  done
fi

# --- Start Tor ---

log "Launching Tor with config at $TORRC_PATH"
exec tor -f "$TORRC_PATH"
