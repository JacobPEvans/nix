#!/usr/bin/env bash
# setup-docker-socket.sh - Create Docker socket symlink for OrbStack
#
# Creates /var/run/docker.sock symlink pointing to OrbStack's socket.
# This allows tools expecting the default Docker socket to work with OrbStack.
#
# Arguments:
#   $1 - Home directory path (e.g., /Users/username)
#
# This script runs during darwin-rebuild with root privileges.

set -euo pipefail

HOME_DIR="${1:?Home directory required as first argument}"
ORBSTACK_SOCKET="${HOME_DIR}/.orbstack/run/docker.sock"
DOCKER_SOCKET="/var/run/docker.sock"

# Check if OrbStack socket exists (or path exists - OrbStack may not be running)
if [ -S "$ORBSTACK_SOCKET" ] || [ -e "${HOME_DIR}/.orbstack/run" ]; then
    # Remove existing symlink or file if it exists
    if [ -L "$DOCKER_SOCKET" ] || [ -e "$DOCKER_SOCKET" ]; then
        rm -f "$DOCKER_SOCKET"
    fi
    # Create symlink
    ln -sf "$ORBSTACK_SOCKET" "$DOCKER_SOCKET"
    echo "OrbStack: Created Docker socket symlink at $DOCKER_SOCKET"
else
    echo "OrbStack: Socket directory not found at ${HOME_DIR}/.orbstack/run (OrbStack may not be installed)"
fi
