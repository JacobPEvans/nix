#!/usr/bin/env zsh
# granola-migrate.sh - Triggered by watchexec when new .md files appear in granola/
#
# Required environment variables (set by launchd):
#   VAULT_PATH, CLAUDE_MODEL, CLAUDE_MAX_TURNS, MAX_BUDGET, DAILY_CAP, LOG_DIR
# Optional:
#   BATCH_SIZE (default: 5) — number of files per Claude invocation

# Restore homebrew PATH stripped by nix-darwin /etc/zshenv
export PATH="/opt/homebrew/bin:$PATH"

set -euo pipefail

log() { echo "$(date -Iseconds) $*"; }

# Validate required environment variables
for var in VAULT_PATH CLAUDE_MODEL CLAUDE_MAX_TURNS MAX_BUDGET DAILY_CAP LOG_DIR; do
  if [[ -z "${(P)var-}" ]]; then
    log "ERROR: Required variable $var is not set" >&2
    exit 1
  fi
done

BATCH_SIZE=$(( ${BATCH_SIZE:-5} ))

# --- Lock (atomic mkdir, no TOCTOU race) ---

LOCK_FILE="${HOME}/.claude/locks/granola-migrate.lock"
mkdir -p "${LOCK_FILE:h}"

if ! mkdir "$LOCK_FILE" 2>/dev/null; then
  log "Migration already running, skipping"
  exit 0
fi
trap 'rmdir "$LOCK_FILE" 2>/dev/null || true' EXIT

# --- Daily budget gate ---

BUDGET_FILE="${LOG_DIR}/granola-budget.json"
mkdir -p "$LOG_DIR"
TODAY=$(date +%Y-%m-%d)

# Reset budget on new day or missing file
if [[ -f "$BUDGET_FILE" ]] && [[ "$(jq -r '.date // ""' "$BUDGET_FILE" 2>/dev/null)" == "$TODAY" ]]; then
  spent=$(jq -r '.spent // 0' "$BUDGET_FILE" 2>/dev/null || echo "0")
else
  spent="0"
  echo "{\"date\":\"${TODAY}\",\"spent\":0.00}" > "$BUDGET_FILE"
fi

# Compare as integer cents to avoid floating-point issues
cap_cents=$(printf "%.0f" "$(echo "$DAILY_CAP * 100" | bc)")

spent_cents=$(printf "%.0f" "$(echo "$spent * 100" | bc)")
if (( spent_cents >= cap_cents )); then
  log "Daily budget exhausted (\$${spent}/\$${DAILY_CAP}), skipping"
  exit 0
fi

# --- Find unprocessed granola files ---

cd "$VAULT_PATH"

UNPROCESSED=()
for file in granola/*/*.md(N); do
  [[ "$file" == *-transcript.md ]] && continue

  granola_id=$(grep -m1 '^granola_id:' "$file" 2>/dev/null | sed 's/^granola_id:[[:space:]]*//' || echo "")
  [[ -z "$granola_id" ]] && continue

  # Check if already migrated (granola_id exists outside granola/)
  if ! grep -rql "^granola_id: ${granola_id}" --include="*.md" . 2>/dev/null | grep -qv "^./granola/"; then
    UNPROCESSED+=("$file")
  fi
done

if (( ${#UNPROCESSED[@]} == 0 )); then
  log "No unprocessed files found"
  exit 0
fi

log "Found ${#UNPROCESSED[@]} unprocessed file(s) (batch size: ${BATCH_SIZE}):"
printf '  %s\n' "${UNPROCESSED[@]}"

# --- Process in batches ---

batch_num=0
for ((i=0; i<${#UNPROCESSED[@]}; i+=BATCH_SIZE)); do
  batch_num=$((batch_num + 1))
  BATCH=("${UNPROCESSED[@]:i:BATCH_SIZE}")

  # Re-check budget before each batch
  spent=$(jq -r '.spent // 0' "$BUDGET_FILE" 2>/dev/null || echo "0")
  spent_cents=$(printf "%.0f" "$(echo "$spent * 100" | bc)")
  if (( spent_cents >= cap_cents )); then
    log "Daily budget exhausted before batch ${batch_num}, stopping"
    break
  fi

  remaining=$(echo "$DAILY_CAP - $spent" | bc)
  effective_budget=$(echo "if ($MAX_BUDGET < $remaining) $MAX_BUDGET else $remaining" | bc)

  FILE_LIST=$(printf '\n- %s' "${BATCH[@]}")

  PROMPT="You are an automated Granola migration agent for an Obsidian vault at ${VAULT_PATH}. Headless mode — NEVER prompt for user input. Process ONLY the files listed below.

## Files to migrate (this batch):
${FILE_LIST}

## Migration rules (self-contained — do NOT read any skill, rule, or data files):

### Project routing — match meeting title or content to a destination:

| Destination folder | Match when title or content contains |
|---|---|
| clients/deloitte/projects/netflow-itsi/meetings/YYYY-MM/ | ITSI, NetFlow, Splunk ITSI, 100-hour |
| clients/deloitte/projects/cribl-activation/meetings/YYYY-MM/ | Cribl Worker, activation, Cribl troubleshoot, Andrew Hendricks |
| clients/deloitte/projects/cyber/meetings/YYYY-MM/ | Cyber, CheckMark, Pratik |
| clients/commercial-alliance/projects/loan-automation/meetings/YYYY-MM/ | Tines, FiServ, SSO, loan, boarding, Snowflake, Commercial Alliance, CA Sync |
| clients/heb/projects/heb-cribl/meetings/YYYY-MM/ | HEB, H-E-B, SC4S |
| clients/world-pay/projects/wpay-cribl/meetings/YYYY-MM/ | World Pay, WorldPay, wpay |
| clients/hard-rock/projects/hrok-cribl/meetings/YYYY-MM/ | Hard Rock, HardRock |
| clients/northern-trust/projects/ntrs-cribl/meetings/YYYY-MM/ | Northern Trust |
| partner/cribl/meetings/YYYY-MM/ | Cribl (VCT/internal meeting with no external client) |
| partner/splunk/meetings/YYYY-MM/ | Splunk (VCT/internal meeting with no external client) |
| visicore/meetings/YYYY-MM/ | VCT internal, visicore, team meeting, all-hands |

Replace YYYY-MM with the meeting date extracted from the source file path or frontmatter.
For multiple Deloitte keyword matches: netflow-itsi > cribl-activation > cyber.
If no match is found, SKIP that file entirely — do not move it.

### File naming
Destination filename: YYYY-MM-DD Meeting Title.md
Use the date prefix from the granola source path and the meeting title from frontmatter or H1 heading.

### Frontmatter transformation
When migrating, update these fields in the destination file:
- Keep: granola_id (critical for dedup detection), attendees
- Set: type: meeting
- Set: project to the project slug (e.g., netflow-itsi, loan-automation, heb-cribl)
- Set: tags including the company tag (e.g., client/deloitte), project tag (e.g., project/deloitte/netflow-itsi), and meeting

### VCT internal people — do NOT create person pages for these:
Jacob Evans (Jacob, Jake Evans, jevans), Paul Stout (Paul), Andrew Hendricks (Andrew Hendrix, Andrew),
Rob Jolliffe (Rob), Vince Asdell (Vince), Cody Quinney (Cody), Arif Hohammad (Arif), James Hill (James)

### Migration steps for each file:
1. Read the granola file
2. Determine destination using keyword matching above (skip if ambiguous or no match)
3. Create the YYYY-MM destination folder if needed: mkdir -p path/to/meetings/YYYY-MM
4. git mv source destination (ALWAYS use git mv, never plain mv)
5. Update frontmatter in the destination file (Read then Edit)
6. Do NOT migrate the corresponding -transcript.md file (leave it in granola/)
7. Do NOT create person pages — skip that step entirely

### After all files in this batch are processed:
Stage and commit: git add -A && git commit -m '🤖 [AUTO-MERGE] Migrated N Granola meeting(s)' && git push origin main
Replace N with the actual count of files migrated (not skipped)."

  LOG_FILE="${LOG_DIR}/granola-migrate-$(date +%Y%m%d-%H%M%S)-batch${batch_num}.log"
  log "Batch ${batch_num}: invoking Claude for ${#BATCH[@]} file(s) (model=${CLAUDE_MODEL}, budget=\$${effective_budget})"

  set +o pipefail
  claude -p "$PROMPT" \
    --model "$CLAUDE_MODEL" \
    --max-budget-usd "$effective_budget" \
    --max-turns "$CLAUDE_MAX_TURNS" \
    --output-format stream-json \
    --verbose \
    --no-session-persistence \
    --permission-mode bypassPermissions \
    --allowedTools "Bash,Read,Write,Edit,Glob,Grep" \
    2>&1 | tee "$LOG_FILE"
  CLAUDE_EXIT=$pipestatus[1]
  set -o pipefail

  log "Claude exited with code ${CLAUDE_EXIT} (batch ${batch_num})"

  # Parse actual cost from the stream-json result line
  actual_cost=$(grep '"type":"result"' "$LOG_FILE" 2>/dev/null | tail -1 | jq -r '.total_cost_usd // 0' 2>/dev/null || echo "0")
  if [[ -n "$actual_cost" ]] && [[ "$actual_cost" != "0" ]] && [[ "$actual_cost" != "null" ]] && (( $(echo "$actual_cost > 0" | bc -l) )); then
    new_spent=$(echo "$spent + $actual_cost" | bc)
    log "Budget: \$${new_spent}/\$${DAILY_CAP} (actual cost: \$${actual_cost})"
  elif (( CLAUDE_EXIT == 0 )); then
    # Fallback: charge effective_budget conservatively if actual cost unavailable
    new_spent=$(echo "$spent + $effective_budget" | bc)
    log "Budget: \$${new_spent}/\$${DAILY_CAP} (charged \$${effective_budget}, actual cost unavailable)"
  else
    new_spent="$spent"
    log "Claude failed (exit ${CLAUDE_EXIT}), not charging budget"
  fi

  echo "{\"date\":\"${TODAY}\",\"spent\":${new_spent}}" > "$BUDGET_FILE"
  spent="$new_spent"
done

log "Migration complete. Processed up to ${#UNPROCESSED[@]} file(s) across ${batch_num} batch(es)."
