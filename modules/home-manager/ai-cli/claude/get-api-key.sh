#!/usr/bin/env zsh
# Retrieves Claude OAuth token from Bitwarden Secrets Manager
# BWS access token is stored in macOS Keychain for security
#
# Security architecture:
# 1. BWS access token stored in macOS login Keychain (encrypted at rest)
# 2. Claude OAuth token stored in BWS (cloud secrets with audit trail)
# 3. Token never written to disk - fetched at runtime
#
# Used by Claude Code's apiKeyHelper mechanism for headless authentication
# (cron jobs, CI/CD pipelines, etc.)
#
# Configuration (injected via Nix substituteAll):
# - @keychainService@ : Keychain service name for BWS access token
# - @bwsSecretId@     : Bitwarden secret ID for Claude OAuth token

set -euo pipefail

# Get BWS access token from Keychain
BWS_TOKEN=$(security find-generic-password -s "@keychainService@" -w) || {
  echo "ERROR: Cannot retrieve BWS token from Keychain (service: @keychainService@)" >&2
  exit 1
}

# Validate BWS token format (must be non-empty and not contain obvious corruption markers)
if [[ -z "$BWS_TOKEN" || "$BWS_TOKEN" == "null" ]]; then
  echo "ERROR: BWS token is empty or null" >&2
  echo "Fix: Delete and re-add the token to Keychain:" >&2
  echo "  security delete-generic-password -s \"@keychainService@\"" >&2
  echo "  security add-generic-password -s \"@keychainService@\" -a \"\$USER\" -w \"NEW_TOKEN\"" >&2
  echo "Get a new token from: https://vault.bitwarden.com" >&2
  exit 1
fi

# Fetch OAuth token from BWS
export BWS_ACCESS_TOKEN="$BWS_TOKEN"
if ! bws secret get "@bwsSecretId@" --output json 2>&1 | jq -r '.value' 2>&1; then
  ERROR_OUTPUT=$(bws secret get "@bwsSecretId@" --output json 2>&1 || true)
  echo "ERROR: Cannot retrieve OAuth token from BWS (secret: @bwsSecretId@)" >&2

  # Check for invalid token format error
  if echo "$ERROR_OUTPUT" | grep -q "not in a valid format"; then
    echo "" >&2
    echo "The BWS access token in your Keychain is invalid or corrupted." >&2
    echo "Fix: Replace the token with a new Machine Account token:" >&2
    echo "" >&2
    echo "  1. Delete the corrupted entry:" >&2
    echo "     security delete-generic-password -s \"@keychainService@\"" >&2
    echo "" >&2
    echo "  2. Get a new token from Bitwarden Secrets Manager:" >&2
    echo "     https://vault.bitwarden.com" >&2
    echo "" >&2
    echo "  3. Add to keychain:" >&2
    echo "     security add-generic-password -s \"@keychainService@\" -a \"\$USER\" -w \"NEW_TOKEN\"" >&2
    echo "" >&2
    echo "  4. Verify:" >&2
    echo "     export BWS_ACCESS_TOKEN=\$(security find-generic-password -s \"@keychainService@\" -w)" >&2
    echo "     bws secret list" >&2
  else
    echo "BWS error: $ERROR_OUTPUT" >&2
  fi
  exit 1
fi
