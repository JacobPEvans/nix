#!/usr/bin/env bash
# Check file sizes against tier limits defined in .file-size.yml
# Config: .file-size.yml (single source of truth for both CI and pre-commit)
# Requires: yq (available in devShell and CI runners)
#
# Limits: defaults.warn (recommended), defaults.error (hard), extended.limit (large docs)
#
# Exit codes:
#   0 - All files within limits
#   N - Number of files exceeding their tier limit

set -euo pipefail

# Find .file-size.yml by walking up from script location or cwd
CONFIG=""
for dir in "." "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; do
  if [[ -f "$dir/.file-size.yml" ]]; then
    CONFIG="$dir/.file-size.yml"
    break
  fi
done

if [[ -z "$CONFIG" ]]; then
  echo "::error::No .file-size.yml found"
  exit 1
fi

# Read config via yq
WARN=$(yq '.defaults.warn // 6144' "$CONFIG")
ERR=$(yq '.defaults.error // 12288' "$CONFIG")
EXT_LIMIT=$(yq '.extended.limit // 0' "$CONFIG")

# Build space-separated lists for extended and exempt basenames
# tr -d '"' strips quotes for compatibility with both kislyuk/yq and mikefarah/yq
EXTENDED=" $(yq '.extended.files // [] | .[]' "$CONFIG" | tr -d '"' | tr '\n' ' ')"
EXEMPT=" $(yq '.exempt // [] | .[]' "$CONFIG" | tr -d '"' | tr '\n' ' ')"

# Build find name arguments from scan extensions
name_args=(); first=true
while IFS= read -r ext; do
  [ -z "$ext" ] && continue
  $first && first=false || name_args+=(-o)
  name_args+=(-name "*${ext}")
done < <(yq '.scan // [] | .[]' "$CONFIG" | tr -d '"')

ERRORS=0

while IFS= read -r -d '' f; do
  base=$(basename "$f" | sed 's/\.[^.]*$//')
  size=$(wc -c < "$f" | tr -d ' ')
  kb=$((size / 1024))

  # Skip exempt files
  if [[ "$EXEMPT" == *" $base "* ]]; then continue; fi

  # Determine limit: extended or standard
  if [[ "$EXT_LIMIT" -gt 0 ]] && [[ "$EXTENDED" == *" $base "* ]]; then
    limit=$EXT_LIMIT
    warn_threshold=$limit
  else
    limit=$ERR
    warn_threshold=$WARN
  fi

  # Report errors and warnings
  if [ "$size" -gt "$limit" ]; then
    echo "::error file=$f::$f is ${kb}KB (exceeds $((limit/1024))KB limit)"
    ERRORS=$((ERRORS + 1))
  elif [ "$size" -gt "$warn_threshold" ]; then
    echo "::warning file=$f::$f is ${kb}KB (exceeds $((warn_threshold/1024))KB recommended)"
  fi
# Note: -type f restricts to regular files and excludes symlinks intentionally.
done < <(find . -path './.git' -prune -o \( "${name_args[@]}" \) -type f -print0 | sort -z)

exit $ERRORS
