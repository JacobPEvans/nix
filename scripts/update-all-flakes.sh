#!/usr/bin/env bash
# Update all flake inputs across the entire repository
#
# Usage: ./scripts/update-all-flakes.sh [--verbose]
#
# Updates:
# - Root flake.lock (darwin, home-manager, nixpkgs, AI tools)
# - Shell environment flakes (shells/**/flake.lock)
# - Host-specific flakes (hosts/**/flake.lock)
#
# Options:
#   --verbose    Show full nix flake update output
#
# Exit codes:
#   0 - Success (flakes updated or already up to date)
#   1 - Error during update

set -euo pipefail

VERBOSE=false
if [[ "${1:-}" == "--verbose" ]]; then
  VERBOSE=true
fi

# Update root flake
echo "=== Updating ROOT flake ==="
if [[ "$VERBOSE" == "true" ]]; then
  nix flake update --refresh
else
  nix flake update --refresh 2>&1 | tail -10
fi

# Update all shell environment flakes
echo ""
echo "=== Updating SHELL flakes ==="
for dir in shells/*/; do
  if [[ -f "${dir}flake.nix" ]]; then
    echo "Updating: $dir"
    if [[ "$VERBOSE" == "true" ]]; then
      (cd "$dir" && nix flake update --refresh) || true
    else
      (cd "$dir" && nix flake update --refresh 2>&1 | tail -3) || true
    fi
  fi
done

# Update host-specific flakes if they have locks
if ls hosts/*/flake.lock 1> /dev/null 2>&1; then
  echo ""
  echo "=== Updating HOST flakes ==="
  for dir in hosts/*/; do
    if [[ -f "${dir}flake.lock" ]]; then
      echo "Updating: $dir"
      if [[ "$VERBOSE" == "true" ]]; then
        (cd "$dir" && nix flake update --refresh) || true
      else
        (cd "$dir" && nix flake update --refresh 2>&1 | tail -3) || true
      fi
    fi
  done
fi

echo ""
echo "=== Update complete ==="
