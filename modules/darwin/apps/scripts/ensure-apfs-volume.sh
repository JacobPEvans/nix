#!/usr/bin/env bash
# ensure-apfs-volume.sh - Create APFS volume if it doesn't exist
#
# Minimal script - only handles diskutil operations that cannot be done in Nix.
# All configuration (paths, names) comes from arguments.
#
# Arguments:
#   $1 - Volume name
#   $2 - APFS container identifier (e.g., "disk3")
#
# Exit codes:
#   0 - Volume exists or was created
#   1 - Creation failed

set -euo pipefail

VOLUME_NAME="${1:?Volume name required}"
CONTAINER="${2:?APFS container required}"
MOUNT_POINT="/Volumes/${VOLUME_NAME}"

# Already mounted - done
if mount | grep -q "on ${MOUNT_POINT} "; then
    exit 0
fi

# Exists but not mounted - mount it
if diskutil info "${MOUNT_POINT}" &>/dev/null; then
    diskutil mount "${VOLUME_NAME}"
    exit 0
fi

# Create volume
diskutil apfs addVolume "${CONTAINER}" APFS "${VOLUME_NAME}"
