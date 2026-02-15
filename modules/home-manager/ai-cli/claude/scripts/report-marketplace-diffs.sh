#!/usr/bin/env bash
# Show diffs between backed-up directories and new Nix-managed symlinks
# Backups are kept for manual review and deletion

set -euo pipefail

for path in "$@"; do
  BACKUP="$path.backup"
  [ ! -d "$BACKUP" ] && continue

  echo "" >&2
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Marketplace transition: $path" >&2

  if [ ! -L "$path" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] Not a symlink" >&2
    continue
  fi

  NEW_TARGET=$(readlink "$path")
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]   Was: Real directory (runtime)" >&2
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]   Now: Symlink → $NEW_TARGET (Nix)" >&2

  # Validate target before diffing
  if [ ! -e "$NEW_TARGET" ] || [ ! -d "$NEW_TARGET" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN]   Target unavailable, skipping diff" >&2
    continue
  fi

  # Show diff (first 20 lines) with proper exit code handling
  diff_output=$(diff -r "$BACKUP" "$path" 2>&1 | head -20 || true)
  if [ -z "$diff_output" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]   Directories identical" >&2
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]   Differences (first 20 lines):" >&2
    echo "$diff_output" >&2
  fi

  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]   Backup: $BACKUP (review and delete when done)" >&2
done
