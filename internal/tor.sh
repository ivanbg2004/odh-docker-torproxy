#!/bin/bash
set -e

# internal/tor.sh

# Generates and manages the Tor configuration file (torrc).

# --- Configuration ---

TOR_CONFIG_DIR="${TOR_CONFIG_DIR:-/etc/tor}" # Where torrc is stored
TOR_CONFIG="${TOR_CONFIG_DIR}/torrc"          # Path to torrc
TOR_DATA_DIR="${TOR_DATA_DIR:-/var/lib/tor}"  # Tor's data directory
DEFAULT_VIRTUAL_ADDR_NETWORK="10.192.0.0/10" # Default virtual address network

# List of custom TorProxy options (skip these when loading env vars)
CUSTOM_TOR_OPTIONS=(
  "TOR_CONTROL_PASSWD"
)

# --- Helper Functions ---

# Log messages with timestamp and level
log() {
  local level="$1"
  local message="$2"
  echo -e "$(date +"%b %d %H:%M:%S %Z") [$level] $message"
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
  chown -R "$uid":"$uid" "$2" "$3"
}

# Get a Tor config option from torrc
get_torrc_option() {
  grep -i "^$1" "$TOR_CONFIG" | awk '{print $2}'
}

# Get the current SocksPort from torrc
current_socks_port() {
  get_torrc_option "SocksPort"
}

# --- Tor Configuration Generation ---

generate_tor_config() {
  log INFO "Generating Tor configuration file: $TOR_CONFIG"

  cat > "$TOR_CONFIG" <<EOF
####### AUTO-GENERATED FILE, DO NOT EDIT #######
VirtualAddrNetwork ${TOR_VIRTUAL_ADDR_NETWORK:-$DEFAULT_VIRTUAL_ADDR_NETWORK}
AutomapHostsOnResolve ${TOR_AUTOMAP_HOSTS_ON_RESOLVE:-1}
SOCKSPort ${TOR_SOCKS_PORT:-59050}
${TOR_SOCKS_POLICY:+SOCKSPolicy $TOR_SOCKS_POLICY}
HTTPTunnelPort ${TOR_HTTP_TUNNEL_PORT:-58118}
DNSPort ${TOR_DNS_PORT:-53530}
TransPort ${TOR_TRANS_PORT:-58119}
${TOR_LOG_LEVEL:+Log $TOR_LOG_LEVEL}
${TOR_RUN_AS_DAEMON:+RunAsDaemon $TOR_RUN_AS_DAEMON}
User tor
DataDirectory ${TOR_DATA_DIRECTORY:-/var/lib/tor}
${TOR_CONTROL_PORT:+ControlPort $TOR_CONTROL_PORT}

# HashedControlPassword (only set if TOR_CONTROL_PASSWD is defined)
${TOR_CONTROL_PASSWD:+HashedControlPassword $(tor --hash-password "$TOR_CONTROL_PASSWD" | grep '^16:')}

${TOR_COOKIE_AUTHENTICATION:+CookieAuthentication $TOR_COOKIE_AUTHENTICATION}
${TOR_USE_BRIDGE:+UseBridges $TOR_USE_BRIDGE}
ClientTransportPlugin meek_lite,obfs2,obfs3,obfs4,scramblesuit exec /usr/local/bin/lyrebird
ClientTransportPlugin meek exec /usr/local/bin/meek-client
ClientTransportPlugin snowflake exec /usr/local/bin/snowflake-client
${TOR_SOCKS5_PROXY:+Socks5Proxy $TOR_SOCKS5_PROXY}
${TOR_SOCKS5_USERNAME:+Socks5Username $TOR_SOCKS5_USERNAME}
${TOR_SOCKS5_PASSWORD:+Socks5Password $TOR_SOCKS5_PASSWORD}
${TOR_HIDDEN_SERVICE_DIR:+HiddenServiceDir $TOR_HIDDEN_SERVICE_DIR}
${TOR_HIDDEN_SERVICE_PORT:+HiddenServicePort $TOR_HIDDEN_SERVICE_PORT}
${TOR_OR_PORT:+ORPort $TOR_OR_PORT}
${TOR_ADDRESS:+Address $TOR_ADDRESS}
${TOR_OUTBOUND_BIND_ADDRESS_EXIT:+OutboundBindAddressExit $TOR_OUTBOUND_BIND_ADDRESS_EXIT}
${TOR_OUTBOUND_BIND_ADDRESS_OR:+OutboundBindAddressOR $TOR_OUTBOUND_BIND_ADDRESS_OR}
${TOR_NICKNAME:+Nickname $TOR_NICKNAME}
${TOR_RELAY_BANDWIDTH_RATE:+RelayBandwidthRate $TOR_RELAY_BANDWIDTH_RATE}
${TOR_RELAY_BANDWIDTH_BURST:+RelayBandwidthBurst $TOR_RELAY_BANDWIDTH_BURST}
${TOR_ACCOUNTING_START:+AccountingStart $TOR_ACCOUNTING_START}
${TOR_CONTACT_INFO:+ContactInfo $TOR_CONTACT_INFO}
${TOR_DIR_PORT:+DirPort $TOR_DIR_PORT}
${TOR_DIR_PORT_FRONT_PAGE:+DirPortFrontPage $TOR_DIR_PORT_FRONT_PAGE}
${TOR_MY_FAMILY:+MyFamily $TOR_MY_FAMILY}
${TOR_EXIT_RELAY:+ExitRelay $TOR_EXIT_RELAY}
${TOR_IPV6_EXIT:+IPv6Exit $TOR_IPV6_EXIT}
${TOR_REDUCED_EXIT_POLICY:+ReducedExitPolicy $TOR_REDUCED_EXIT_POLICY}
${TOR_EXIT_POLICY:+ExitPolicy $TOR_EXIT_POLICY}
${TOR_BRIDGE_RELAY:+BridgeRelay $TOR_BRIDGE_RELAY}
${TOR_BRIDGE_DISTRIBUTION:+BridgeDistribution $TOR_BRIDGE_DISTRIBUTION}

# Include custom configuration files from /etc/tor/torrc.d/
%include /etc/tor/torrc.d/*.conf

########## END AUTO-GENERATED FILE ##########
EOF
}

# Cleans up and optimizes the Tor config file
cleanse_tor_config() {
  log INFO "Cleaning up Tor configuration file..."
  # Remove comment lines
  sed -i '/^#.*/d' "$TOR_CONFIG"
  # Remove options with no value
  sed -i '/^[^ ]* $/d' "$TOR_CONFIG"
  # Remove duplicate lines
  sed -i '$!N; /^\(.*\)\n\1$/D' "$TOR_CONFIG"
  # Remove double empty lines
  sed -i '/^\s*$/{N;/^\s*$/D;}' "$TOR_CONFIG"
}

# Fixes permissions for the Tor data directory
fix_tor_permissions() {
  log INFO "Fixing permissions for Tor data directory: $TOR_DATA_DIR"
  if [ ! -d "$TOR_DATA_DIR" ]; then
    mkdir -p "$TOR_DATA_DIR"
  fi
  uown tor tor "$TOR_DATA_DIR"
  chmod 700 "$TOR_DATA_DIR"
}

# Loads Tor options from environment variables
load_tor_env() {
  log INFO "Loading Tor options from environment variables..."
  generate_tor_config # Start with a clean config file
  local added_count=0
  local updated_count=0
  local raw_option_name raw_option_value option_name option_value

  for raw_option_name in $(env | grep -o "^TOR_[^=]*"); do
    # Skip TorProxy custom options
    if [[ " ${CUSTOM_TOR_OPTIONS[*]} " == *" ${raw_option_name} "* ]]; then
      continue
    fi

    raw_option_value="${!raw_option_name}"
    if [ -n "$raw_option_value" ]; then
      option_name=$(to_camel_case "${raw_option_name#TOR_}")
      option_value=$(sed_escape "$raw_option_value")

      # Check if there is a corresponding option in the config file, and update it
      if grep -q "^${option_name}" "$TOR_CONFIG"; then
        sed -i "s/^${option_name}.*/${option_name} ${option_value}/" "$TOR_CONFIG"
        ((updated_count++))
      else
        sed -i "s/\\# Include custom configuration files from \/etc\/tor\/torrc.d\///\n${option_name} ${option_value}\n\\# Include custom configuration files from \/etc\/tor\/torrc.d\//" "$TOR_CONFIG"
        ((added_count++))
      fi
    fi
  done

  cleanse_tor_config # Clean up after adding options
  fix_tor_permissions # Ensure correct permissions

  log INFO "Added $added_count and updated $updated_count options from environment variables."
}

# --- Main Script ---

# Ensure Tor data directory exists and has correct permissions
fix_tor_permissions

# Load Tor options from environment variables
load_tor_env

log INFO "Tor configuration complete."

exit 0
