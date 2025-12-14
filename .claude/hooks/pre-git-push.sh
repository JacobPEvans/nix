#!/usr/bin/env bash
# Pre-git-push hook: Requirements before pushing to remote
#
# This hook runs before any git push command in Claude Code.
# Add additional requirements here as needed.

set -euo pipefail

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "🔨 Pre-push: Running darwin-rebuild switch --flake ."
echo "══════════════════════════════════════════════════════════════"
echo ""

# Run the rebuild with full output
sudo darwin-rebuild switch --flake .

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ Pre-push checks passed"
echo "══════════════════════════════════════════════════════════════"
echo ""
