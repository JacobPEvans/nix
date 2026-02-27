# generate-pal-models.sh
#
# Generates a PAL MCP custom_models.json from `ollama list`.
# Must be SOURCED (not executed) — caller sets required env vars and PATH.
#
# Required env vars (set by caller before sourcing):
#   OLLAMA_BIN   — absolute path to ollama binary
#   OUTPUT_FILE  — destination JSON path
#   JQ_BIN       — absolute path to jq binary
#
# Required PATH entries (set by caller):
#   coreutils (mkdir, tee), gawk, gnused
#
# Behaviour:
#   - If ollama is unreachable: keeps existing file, prints warning, exits 0
#   - If ollama list returns no models: writes empty models array
#   - Skips models with "/" in name (OpenRouter proxies)
#   - Registers each model with a base-name alias (colon-stripping workaround)
#   - Intelligence score estimated from model size (GB buckets)
#   - Cloud models (size 0 / "-"): intelligence_score 14

set -euo pipefail

_pal_generate() {
  # ── Preflight check ──────────────────────────────────────────────────────
  if [ ! -x "$OLLAMA_BIN" ]; then
    echo "generate-pal-models: ollama not found at $OLLAMA_BIN — skipping" >&2
    return 0
  fi

  if ! "$OLLAMA_BIN" list >/dev/null 2>&1; then
    echo "generate-pal-models: ollama list failed (server not running?) — keeping existing file" >&2
    return 0
  fi

  # ── Parse ollama list ────────────────────────────────────────────────────
  # Output format: NAME  ID  SIZE  MODIFIED...
  # SIZE column is like "4.7 GB", "14 GB", "-", etc.
  local raw_list
  raw_list=$("$OLLAMA_BIN" list | tail -n +2)

  # Build JSON via jq null input + a shell-generated entries string
  # We collect entries as a newline-delimited list of JSON objects, then
  # assemble into the final structure.

  local entries=""
  local seen_aliases=""   # space-delimited list of already-used aliases

  while IFS= read -r line; do
    [ -z "$line" ] && continue

    # Extract fields: NAME is first column, SIZE is third+fourth (e.g., "4.7 GB")
    local name size_str size_gb
    name=$(echo "$line"   | awk '{print $1}')
    size_str=$(echo "$line" | awk '{print $3, $4}')

    # Skip models with "/" — those are OpenRouter/proxy entries
    case "$name" in
      */*) continue ;;
    esac

    # Parse size_gb from size_str ("4.7 GB" → 4, "14 GB" → 14, "-" → 0)
    size_gb=$(echo "$size_str" | awk '
      /^[0-9]/ { v = $1 + 0; print int(v); next }
      { print 0 }
    ')

    # Derive base name and tag
    local base tag model_name
    base="${name%%:*}"    # everything before first colon
    tag="${name#*:}"      # everything after first colon (same as name if no colon)

    # model_name: what gets sent to the Ollama API
    if [ "$tag" = "latest" ] || [ "$tag" = "$name" ]; then
      model_name="$base"     # Ollama auto-resolves :latest; no-colon names sent as-is
    else
      model_name="$name"     # e.g. "glm-5:cloud", "qwen3-coder:30b"
    fi

    # Intelligence score from size buckets
    local score
    if [ "$size_gb" -eq 0 ]; then
      score=14   # cloud/remote model — assume large
    elif [ "$size_gb" -lt 5 ]; then
      score=5
    elif [ "$size_gb" -lt 20 ]; then
      score=8
    elif [ "$size_gb" -lt 40 ]; then
      score=11
    elif [ "$size_gb" -lt 70 ]; then
      score=14
    else
      score=17
    fi

    # Build aliases array (JSON)
    # Always include base name (colon-stripping workaround: PAL strips ":tag" before lookup)
    # Also add hyphenated variant for tags that are not "latest"
    local aliases_json
    if [ "$tag" = "latest" ] || [ "$tag" = "$name" ]; then
      # Only base alias needed (model_name == base already)
      if echo "$seen_aliases" | grep -qw "$base"; then
        # Alias already taken by an earlier model — omit aliases
        aliases_json="[]"
      else
        aliases_json="[\"$base\"]"
        seen_aliases="$seen_aliases $base"
      fi
    else
      # Add base + hyphenated variant (e.g., "glm-5" + "glm-5-cloud")
      local hyphen_alias="${base}-${tag}"
      aliases_json="[]"
      local a_base="" a_hyphen=""
      if ! echo "$seen_aliases" | grep -qw "$base"; then
        a_base="\"$base\""
        seen_aliases="$seen_aliases $base"
      fi
      if ! echo "$seen_aliases" | grep -qw "$hyphen_alias"; then
        a_hyphen="\"$hyphen_alias\""
        seen_aliases="$seen_aliases $hyphen_alias"
      fi
      if [ -n "$a_base" ] && [ -n "$a_hyphen" ]; then
        aliases_json="[$a_base, $a_hyphen]"
      elif [ -n "$a_base" ]; then
        aliases_json="[$a_base]"
      elif [ -n "$a_hyphen" ]; then
        aliases_json="[$a_hyphen]"
      fi
    fi

    # Append entry (newline-delimited JSON objects, will be joined by jq)
    local entry
    entry=$(printf '{"model_name":"%s","aliases":%s,"intelligence_score":%d,"speed_score":5,"json_mode":false,"function_calling":false,"images":false}' \
      "$model_name" "$aliases_json" "$score")
    if [ -z "$entries" ]; then
      entries="$entry"
    else
      entries="$entries
$entry"
    fi

  done <<< "$raw_list"

  # ── Write output file ────────────────────────────────────────────────────
  mkdir -p "$(dirname "$OUTPUT_FILE")"

  if [ -z "$entries" ]; then
    # No models found — write empty structure
    printf '{"custom_api":{"models":[]}}\n' > "$OUTPUT_FILE"
    echo "generate-pal-models: no Ollama models found — wrote empty custom_models.json" >&2
    return 0
  fi

  # Use jq to produce well-formed, sorted JSON
  echo "$entries" \
    | "$JQ_BIN" -Rs '
        split("\n")
        | map(select(length > 0))
        | map(fromjson)
        | { custom_api: { models: . } }
      ' \
    > "$OUTPUT_FILE"

  local count
  count=$(echo "$entries" | wc -l | tr -d ' ')
  echo "generate-pal-models: wrote $count model(s) to $OUTPUT_FILE" >&2
}

_pal_generate
