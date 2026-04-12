#!/usr/bin/env bash
# Validate repository_dispatch payload for deps-flake-dispatch.yml
# Ensures all required fields are present and input_name is safe for shell use.
set -euo pipefail

: "${INPUT_NAME:?Missing client_payload.input_name}"
: "${VERSION:?Missing client_payload.version}"
: "${SOURCE_REPO:?Missing client_payload.source_repo}"

if [[ ! "$INPUT_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
  echo "::error::Invalid input name: $INPUT_NAME (must start with a letter, alphanumeric/dash/underscore only)"
  exit 1
fi
