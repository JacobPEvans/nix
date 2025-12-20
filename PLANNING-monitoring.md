# Monitoring Infrastructure - Session Planning

**Branch:** `feat/monitoring`
**PR:** <https://github.com/JacobPEvans/nix/pull/172>
**Created:** 2024-12-20
**Status:** In Progress

**Blocking Issue:** <https://github.com/JacobPEvans/nix/issues/173> (BWS token invalid)

## Overview

Comprehensive observability infrastructure for Claude Code autonomous agents and AI development workflows.

## Completed Work

### 1. Slack Notifications (Partial)

**Files Modified:**

- `modules/home-manager/ai-cli/claude-config.nix` - Enabled channel IDs (were commented out)
- `modules/home-manager/ai-cli/claude/auto-claude-notify.py` - Added `run_skipped` command
- `modules/home-manager/ai-cli/claude/auto-claude.sh` - Added skip notification, BWS keychain retrieval

**Channel Configuration:**

```nix
ai-assistant-instructions.slackChannel = "C0A3XA3PBL1";
nix.slackChannel = "C0A32VA40KH";
```

**Notification Types Implemented:**

- `run_started` - Parent message when auto-claude begins
- `task_started` - Thread reply when subagent spawns
- `task_completed` - Thread reply with PR link, cost, duration
- `task_blocked` - Thread reply when task fails
- `run_completed` - Summary with parent update
- `run_skipped` - NEW: Notification when run is paused/skipped

### 2. Structured JSON Logging

**File:** `modules/home-manager/ai-cli/claude/auto-claude.sh`

Added `emit_event()` function for consistent JSONL event logging to `~/.claude/logs/events.jsonl`:

```json
{"event": "run_started", "timestamp": "...", "run_id": "...", "repo": "...", "budget": 25.0}
{"event": "run_skipped", "timestamp": "...", "run_id": "...", "repo": "...", "reason": "..."}
{"event": "subagent_spawned", "agent_id": "...", "type": "ci-fixer", "parent": "orchestrator"}
{"event": "context_checkpoint", "usage_pct": 45, "tokens_used": 90000}
{"event": "budget_checkpoint", "spent": 5.50, "budget": 25.00, "remaining_pct": 78}
{"event": "run_completed", "duration_minutes": 45, "total_cost": 12.50}
```

### 3. Kubernetes Stack (DEPLOYED)

**Status:** Running on OrbStack

**Directory:** `modules/monitoring/k8s/`

**Components Running:**

| Component | Status | Notes |
|-----------|--------|-------|
| OTEL Collector | ✅ Running | Watching `~/.claude/logs/*.jsonl` |
| Cribl Edge | ✅ Running | Standalone "edge" mode |
| Splunk | ❌ Disabled | ARM64/Rosetta incompatible (KVStore fails) |

**Deployment Fixes Applied:**

- OTEL: Added `health_check` extension on port 13133
- Cribl Edge: Changed to standalone "edge" mode (was "worker")
- Cribl Edge: Changed probe to `exec` on `127.0.0.1:9420` (service binds to localhost)
- Splunk: Added ARM64 digest + license acceptance (disabled due to KVStore incompatibility)

**Secrets Created:**

```bash
# Splunk (created but unused - service disabled)
kubectl -n monitoring get secret splunk-admin
kubectl -n monitoring get secret splunk-hec-token
```

**Cribl Cloud (optional, not configured):**

```bash
kubectl -n monitoring create secret generic cribl-cloud-config \
  --from-literal=master-url='https://YOUR_ORG.cribl.cloud:4200' \
  --from-literal=auth-token='YOUR_FLEET_TOKEN'
```

### 4. Documentation

**Main:** `docs/MONITORING.md` - Overview and quick reference

**Detailed subdocs in `docs/monitoring/`:**

- `KUBERNETES.md` - Full K8s deployment guide, secrets, troubleshooting
- `SLACK.md` - Notification types, Block Kit customization, testing
- `OTEL.md` - Tracing, metrics, collector config, sampling
- `SPLUNK.md` - SPL queries, dashboards, saved searches, data models
- `OLLAMA.md` - AI-powered log enrichment, Cribl pipelines

### 5. Flake Changes

**File:** `flake.nix`

- Removed `./modules/home-manager/nix-config-symlink.nix` import (caused conflict with `~/.config/nix` being a git worktree)

## Known Issues

### 1. BWS Access Token Invalid (BLOCKING)

The BWS access token in macOS Keychain is invalid/corrupted:

```bash
$ security find-generic-password -s "bws-claude-automation" -w
0.aa078f10-a76c-4cad-8832-b3a501617143.1lDjaRiXAXkr2UXE6NyuFbQweB4H1u:9nW5WIQxaFTOJIRq3cg8fg==

$ export BWS_ACCESS_TOKEN="..." && bws secret list
Error: Access token is not in a valid format: Doesn't contain a decryption key
```

**Fix Required:**

```bash
# Delete old entry
security delete-generic-password -s "bws-claude-automation"

# Get new token from Bitwarden Secrets Manager web console
# Then add to keychain:
security add-generic-password -s "bws-claude-automation" -a "$USER" -w "NEW_TOKEN"
```

### 2. Slack Bot Token Not Tested

The Slack bot token (`auto-claude-slack-bot-token`) in BWS hasn't been verified because BWS auth is broken.

**Required Slack App Scopes:**

- `chat:write`
- `chat:write.public`

## Pending Work

### High Priority

1. **Fix BWS Keychain Token** - User must update keychain with valid token
2. **Test Slack Notifications** - After BWS is fixed, test with:

   ```bash
   ~/.claude/scripts/auto-claude-notify.py run_skipped \
     --repo test --reason "Test" --channel C0A32VA40KH
   ```

3. **Create PR** - Push branch and create PR for review

### Medium Priority

1. **Add Elasticsearch Cluster** - Replace Splunk (ARM64 native support):

   ```bash
   # Create Elasticsearch manifests in modules/monitoring/k8s/elasticsearch/
   # Use elastic/elasticsearch:8.x (has ARM64 images)
   ```

2. **Configure Cribl Cloud** - Create Fleet, get enrollment token
3. **Plan Dev/Prod Separation** - Per user requirements:
   - Minimum 1 dev + 1 prod instance per service
   - 3 replicas for critical services in prod
   - Auto-restart on failure for all containers

### Low Priority / Future

1. **OTEL Environment Variables** - Add to shell config:

   ```bash
   export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"
   export OTEL_SERVICE_NAME="claude-code"
   ```

2. **macOS Menu Bar App** - Future enhancement for monitoring dashboard
3. **Ollama Log Enrichment** - Configure Cribl pipelines for AI classification

## Commits Made

1. `e7faf90` - feat(monitoring): add Slack skip notifications and monitoring infrastructure
2. `ff8c508` - docs(monitoring): add detailed documentation for each component
3. `b96f91e` - fix(auto-claude): retrieve BWS_ACCESS_TOKEN from keychain for Slack
4. `93e8604` - docs: add PLANNING-monitoring.md for session continuity
5. `2c9c7f2` - feat(monitoring): deploy K8s stack to OrbStack with fixes

## Testing Commands

```bash
# Test Slack notification (after BWS fix)
export BWS_ACCESS_TOKEN=$(security find-generic-password -s "bws-claude-automation" -w)
/etc/profiles/per-user/jevans/bin/python3 ~/.claude/scripts/auto-claude-notify.py run_skipped \
  --repo "nix-config" --reason "Test notification" --channel "C0A32VA40KH"

# Trigger auto-claude manually
auto-claude-ctl run ai-assistant-instructions

# Check deployed script has run_skipped
grep "run_skipped" ~/.claude/scripts/auto-claude-notify.py

# Rebuild after changes
sudo darwin-rebuild switch --flake .
```

## Architecture Reference

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                           Log Sources                                    │
├─────────────────────────────────────────────────────────────────────────┤
│  Auto-Claude     │  Claude Code    │  Ollama        │  Terminal         │
│  ~/.claude/logs/ │  OTEL native    │  ~/Library/... │  ~/logs/          │
└────────┬─────────┴────────┬────────┴───────┬────────┴────────┬──────────┘
         │                  │                │                 │
         ▼                  ▼                ▼                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    OrbStack Kubernetes Cluster                           │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                   │
│  │ OTEL         │  │ Cribl Edge   │  │ Splunk       │                   │
│  │ Collector    │──│ (log shipper)│──│ (local SIEM) │                   │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┘                   │
│         │                 │                                              │
└─────────┼─────────────────┼──────────────────────────────────────────────┘
          │                 │
          ▼                 ▼
┌─────────────────┐  ┌─────────────────┐
│ Cribl Cloud     │  │ Cribl Lake      │
│ Stream          │──│ (long-term)     │
└─────────────────┘  └─────────────────┘
```

## Related Files

- `modules/home-manager/ai-cli/claude-config.nix` - Auto-claude repository config
- `modules/home-manager/ai-cli/claude/auto-claude.sh` - Main auto-claude script
- `modules/home-manager/ai-cli/claude/auto-claude-notify.py` - Slack notifier
- `modules/home-manager/ai-cli/claude/get-api-key.sh` - BWS keychain pattern reference
- `modules/monitoring/` - K8s manifests
- `docs/MONITORING.md` - Main documentation
- `docs/monitoring/` - Detailed component docs
