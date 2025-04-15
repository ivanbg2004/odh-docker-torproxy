#!/bin/bash
set -e

# internal/screen.sh

# Provides functions for managing screen sessions.

log() {
  echo "$(date -I) - $1"
}

# Kill a screen session by name
kill_screen() {
  local screenName="$1"

  # Check if screen is installed
  if ! command -v screen &> /dev/null; then
    log "WARNING: screen is not installed. Cannot kill screen session $screenName."
    return 1
  fi

  # Check if the screen session exists
  if screen -list | grep -qE "\.$screenName\t"; then
    log "NOTICE: Killing screen session $screenName"
    # Extract the session ID and kill it
    sessionID=$(screen -ls | grep -E "\.$screenName\t" | awk '{print $1}')
    screen -S "$sessionID" -X quit
    log "NOTICE: Killed screen session $screenName (Session ID: $sessionID)"
  else
    log "NOTICE: Screen session $screenName not found."
  fi
}
