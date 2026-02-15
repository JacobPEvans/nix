#!/usr/bin/env bash
# Merge Nix-generated Gemini settings with runtime state
#
# Always merge when file exists (even if not writable/symlink),
# so runtime/auth keys are preserved. Write to temp file first
# for atomic replacement.
#
# Arguments:
#   $1: HOME_DIR - user's home directory
#   $2: SETTINGS_JSON - path to Nix-generated settings.json
#   $3: JQ_BIN - path to jq binary

set -euo pipefail

HOME_DIR="$1"
SETTINGS_JSON="$2"
JQ_BIN="$3"

SETTINGS_FILE="$HOME_DIR/.gemini/settings.json"
SETTINGS_DIR=$(dirname "$SETTINGS_FILE")

# Cleanup temporary file on exit
cleanup() {
  if [ -n "${TMP_SETTINGS_FILE:-}" ] && [ -f "$TMP_SETTINGS_FILE" ]; then
    rm -f "$TMP_SETTINGS_FILE"
  fi
}

trap cleanup EXIT

# Ensure .gemini directory exists
mkdir -p "$SETTINGS_DIR"

# Use mktemp in same directory for atomic replacement
TMP_SETTINGS_FILE=$(mktemp "$SETTINGS_DIR/settings.json.XXXXXX")

if [ -f "$SETTINGS_FILE" ]; then
  echo "Merging Nix configuration with existing Gemini settings..." >&2
  # Deep merge: Nix settings take precedence, runtime keys preserved
  if ! "$JQ_BIN" -s '.[0] * .[1]' "$SETTINGS_FILE" "$SETTINGS_JSON" > "$TMP_SETTINGS_FILE"; then
    echo "Error: failed to merge existing Gemini settings with Nix configuration." >&2
    exit 1
  fi
else
  echo "Creating new Gemini settings file..." >&2
  if ! cp "$SETTINGS_JSON" "$TMP_SETTINGS_FILE"; then
    echo "Error: failed to initialize Gemini settings from Nix configuration." >&2
    exit 1
  fi
fi

# Atomic replacement - mv is atomic when on same filesystem
if ! mv -f "$TMP_SETTINGS_FILE" "$SETTINGS_FILE"; then
  echo "Error: failed to replace Gemini settings file atomically." >&2
  exit 1
fi

# Ensure file is writable for Gemini CLI but not world-readable
if ! chmod 600 "$SETTINGS_FILE"; then
  echo "Warning: failed to set permissions on Gemini settings file." >&2
fi
