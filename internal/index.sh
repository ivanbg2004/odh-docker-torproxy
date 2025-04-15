#!/bin/bash
set -e

# internal/index.sh

# Main entrypoint for setting up the OD&H TorProxy environment.

# --- Configuration ---

# Source other scripts (adjust paths if needed)
source /app/internal/screen.sh
source /app/internal/tor.sh
source /app/internal/dns.sh

# --- Helper Functions ---

# Log messages with timestamp and level
log() {
  local level="$1"
  local message="$2"
  echo -e "$(date +"%b %d %H:%M:%S %Z") [$(echo "$level" | tr '[:lower:]' '[:upper:]')] $message"
}

# Convert screaming snake case to camel case
to_camel_case() {
  echo "${1}" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1' OFS=""
}

# Escape characters for use in sed commands
sed_escape() {
  echo "$1" | sed -e 's/[\/&]/\\&/g'
}

# Set ownership recursively
uown() {
  local uid="$(id -u "$1")"
  chown -R "$uid":"$uid" "$2"
}

# --- Logrotate Setup ---

setup_logrotate() {
  log INFO "Setting up logrotate..."
  cat > /etc/logrotate.d/rotator <<EOF
/var/log/dnsmasq/dnsmasq.log
/var/log/gogost/*.log {
  size 1M
  rotate 3
  missingok
  notifempty
  create 0640 root adm
  copytruncate
}
EOF
  log INFO "Starting crond..."
  crond
  log INFO "crond started."
}

# --- Main Script ---

log INFO "Starting OD&H TorProxy initialization..."

# Setup logrotate
setup_logrotate

log INFO "Initialization complete."

exit 0
