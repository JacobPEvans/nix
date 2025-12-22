# Auto-Claude Enhancement Specification

## Overview

Enhance the auto-claude autonomous maintenance system with:

1. **Master Orchestrator Prompt** - Perpetual loop with nested sub-agents
2. **Python Slack Notifier** - Rich threaded notifications via Slack Web API

---

## Part 1: Master Orchestrator Prompt

### File

`modules/home-manager/ai-cli/claude/orchestrator-prompt.txt`

### Design Principles

| Principle | Description |
|-----------|-------------|
| Perpetual Loop | Never "complete", always find next task |
| Nested Sub-Agents | 2 levels deep (orchestrator → worker → helper) |
| Orchestrator Focus | Coordinate only, never execute directly |
| Budget-Aware | Loop until budget exhausted, not task completion |
| Notification Hooks | Emit structured JSON events for Slack |

### Prompt Structure

```text
IDENTITY
You are the Autonomous Maintenance Orchestrator. You COORDINATE work, you
never execute it directly. Your role is to continuously find work and dispatch
sub-agents until budget is exhausted.

PRIME DIRECTIVE
NEVER return to the user. NEVER ask questions. NEVER claim you are "done".
If a sub-agent returns, spawn another. Loop until budget forces termination.

NOTIFICATION PROTOCOL
After each significant event, emit a JSON line to stdout:
{"event": "task_started", "task": "...", "agent": "ci-fixer"}
{"event": "task_completed", "task": "...", "pr": "#123", "cost": 1.23}
{"event": "task_blocked", "task": "...", "reason": "..."}

CORE LOOP (repeat forever)
┌──────────────────────────────────────────────────────────┐
│ 1. SCAN         Gather repo state (git, gh, CI status)   │
│ 2. PRIORITIZE   Rank tasks by impact                     │
│ 3. DISPATCH     Spawn sub-agent for #1 priority task     │
│ 4. AWAIT        Sub-agent executes (may spawn helpers)   │
│ 5. CAPTURE      Log results, emit notification event     │
│ 6. LOOP         Back to SCAN - find next task            │
└──────────────────────────────────────────────────────────┘

SUB-AGENT TYPES (spawn with Task tool)
- ci-fixer: Analyze CI failures, fix code, push, verify
- pr-responder: Address PR review comments, push updates
- issue-resolver: Implement fixes for labeled issues
- doc-updater: Fix/improve documentation
- test-adder: Add missing test coverage

SUB-AGENT INSTRUCTIONS
When spawning a sub-agent, include:
1. Specific task scope (single PR, single issue)
2. Permission to spawn helpers for subtasks
3. Required output format for tracking
4. Reminder: NEVER ask user questions

PRIORITY ORDER
1. Failing CI on open PRs (broken builds block everything)
2. PR review comments awaiting response
3. Issues labeled: bug, good-first-issue
4. Documentation with broken links or outdated info
5. Low test coverage in critical paths
6. Stale issues that appear resolved
7. Dependency updates (minor/patch only)

FORBIDDEN ACTIONS
- Asking user questions (you are unattended)
- Returning early ("I've completed my tasks")
- Force-push, delete branches, merge PRs
- Direct code changes (always use sub-agents)
- Claiming budget exhaustion before API confirms

RESILIENCE
If a sub-agent fails or returns prematurely:
1. Log the failure with context
2. Move task to "blocked" list with reason
3. Immediately proceed to next priority task
4. Never let one failure stop the loop
```

### Acceptance Criteria

- [ ] Orchestrator runs until budget exhausted (not task completion)
- [ ] All code changes delegated to sub-agents
- [ ] Sub-agents can spawn their own helpers (2 levels)
- [ ] JSON events emitted for each task start/complete/block
- [ ] Never asks user questions or returns early

---

## Part 2: Python Slack Notifier

### File (Part 1)

`modules/home-manager/ai-cli/claude/auto-claude-notify.py`

### Secrets Management

**Use Bitwarden Secrets Manager (`bws`)** - never store secrets in config files.

```bash
# Retrieve secret at runtime
bws secret get <secret-id> | jq -r '.value'
```

Required secrets in Bitwarden:

| Secret Name | Description |
|-------------|-------------|
| `auto-claude-slack-bot-token` | Slack Bot Token (xoxb-...) |

Channel IDs can be stored in Nix config (not sensitive).

### CLI Interface

```bash
# Start notification (returns parent message ts)
auto-claude-notify.py run_started \
  --repo "nix-config" \
  --budget 20.00 \
  --run-id "20251214_080919"

# Task notifications (threaded)
auto-claude-notify.py task_started \
  --repo "nix-config" \
  --thread-ts "1234567890.123456" \
  --task "Fix CI on PR #123" \
  --agent "ci-fixer"

auto-claude-notify.py task_completed \
  --repo "nix-config" \
  --thread-ts "1234567890.123456" \
  --task "Fix CI on PR #123" \
  --pr "#124" \
  --cost 1.23 \
  --duration 8

# Summary (thread + update parent)
auto-claude-notify.py run_completed \
  --repo "nix-config" \
  --thread-ts "1234567890.123456" \
  --parent-ts "1234567890.123456" \
  --summary-json '{"completed": [...], "blocked": [...], "cost": 4.20}'
```

### Threading Strategy

```text
Channel: #auto-claude-nix-config
├── 🤖 Run #20251214_080919 Started          ← Parent (ts saved)
│   ├── 🔧 Dispatched: ci-fixer for PR #123   ← Thread reply
│   ├── ✅ Completed: PR #124 created         ← Thread reply
│   ├── 🔧 Dispatched: issue-resolver #42
│   ├── ⚠️ Blocked: Issue #39 needs input
│   └── 📊 Summary: 3 tasks, $4.20, 47 min    ← Final thread
```

### Block Kit Templates

#### Run Started (Parent Message)

```json
{
  "blocks": [
    {"type": "header", "text": {"type": "plain_text", "text": "🤖 Auto-Claude Run Started"}},
    {"type": "section", "fields": [
      {"type": "mrkdwn", "text": "*Repository*\nai-assistant-instructions"},
      {"type": "mrkdwn", "text": "*Budget*\n$20.00"},
      {"type": "mrkdwn", "text": "*Started*\nDec 14, 8:09 AM"},
      {"type": "mrkdwn", "text": "*Run ID*\n20251214_080919"}
    ]},
    {"type": "actions", "elements": [
      {"type": "button", "text": {"type": "plain_text", "text": "View Repo"}, "url": "https://github.com/..."}
    ]}
  ]
}
```

#### Task Completed (Thread Reply)

```json
{
  "blocks": [
    {"type": "section", "text": {"type": "mrkdwn", "text": "✅ *Task Completed*: Fix CI on PR #123"}},
    {"type": "section", "fields": [
      {"type": "mrkdwn", "text": "*PR Created*\n<https://github.com/.../pull/124|#124 - Fix markdownlint>"},
      {"type": "mrkdwn", "text": "*Cost*\n$1.23"},
      {"type": "mrkdwn", "text": "*Duration*\n8 min"}
    ]}
  ]
}
```

#### Run Summary (Thread + Parent Update)

```json
{
  "blocks": [
    {"type": "header", "text": {"type": "plain_text", "text": "📊 Auto-Claude Run Complete"}},
    {"type": "section", "fields": [
      {"type": "mrkdwn", "text": "*Duration*\n47 minutes"},
      {"type": "mrkdwn", "text": "*Cost*\n$4.20 / $20.00 (21%)"},
      {"type": "mrkdwn", "text": "*Tasks*\n3 completed, 1 blocked"}
    ]},
    {"type": "divider"},
    {"type": "section", "text": {"type": "mrkdwn", "text": "*✅ Completed*\n• PR #124 - Fix markdownlint\n• PR #125 - Update README\n• PR #126 - Add auth tests"}},
    {"type": "section", "text": {"type": "mrkdwn", "text": "*⚠️ Blocked*\n• Issue #39 - Needs architecture decision"}}
  ]
}
```

### Channel Configuration

Store in Nix config (non-sensitive):

```nix
programs.claude.autoClaude.slackChannels = {
  default = "C0123456789";
  "nix-config" = "C0123456789";
  "ai-assistant-instructions" = "C0987654321";
};
```

### Required Slack App Scopes

- `chat:write` - Post messages
- `chat:write.public` - Post to public channels without joining

### Python Dependencies

- `slack-sdk` - Slack Web API client
- `pyyaml` - Config parsing (if needed)

### Acceptance Criteria (Part 1)

- [ ] Secrets retrieved from bws at runtime
- [ ] Parent message posted with run info
- [ ] All task updates in thread under parent
- [ ] Summary updates both thread and parent
- [ ] Each repo posts to its configured channel
- [ ] Block Kit formatting renders correctly

---

## Part 3: Shell Script Updates

### File (Part 2)

`modules/home-manager/ai-cli/claude/auto-claude.sh`

### Changes Required

1. **Remove all inline Slack code** - Delete `slack_post()` and `slack_post_blocks()` functions
2. **Call Python notifier** for all notifications
3. **Capture parent ts** from run_started for threading
4. **Pass data** via CLI args or stdin JSON

### Updated Flow

```bash
# At start
PARENT_TS=$(auto-claude-notify.py run_started --repo "$REPO_NAME" --budget "$MAX_BUDGET_USD" --run-id "$RUN_ID")

# Run Claude (unchanged)
claude -p "$ORCHESTRATOR_PROMPT" ...

# At end
auto-claude-notify.py run_completed \
  --repo "$REPO_NAME" \
  --thread-ts "$PARENT_TS" \
  --log-file "$LOG_FILE"
```

### Acceptance Criteria (Part 2)

- [ ] No curl/jq Slack code remains in shell script
- [ ] Python notifier called for start/end
- [ ] Parent ts captured and passed to completion
- [ ] Script still handles Claude execution correctly

---

## Part 4: Nix Module Updates

### File (Part 3)

`modules/home-manager/ai-cli/claude/auto-claude.nix`

### Changes Required (Part 1)

1. **Deploy Python script** alongside shell script
2. **Add Python dependencies** (slack-sdk)
3. **Add channel configuration option**

```nix
home.file.".claude/scripts/auto-claude-notify.py" = {
  source = ./auto-claude-notify.py;
  executable = true;
};

# Ensure Python with slack-sdk is available
home.packages = [
  (pkgs.python3.withPackages (ps: [ ps.slack-sdk ps.pyyaml ]))
];
```

### Acceptance Criteria (Part 3)

- [ ] Python script deployed to ~/.claude/scripts/
- [ ] slack-sdk available in PATH
- [ ] Channel config option added to module

---

## Files Summary

| File | Action | Description |
|------|--------|-------------|
| `orchestrator-prompt.txt` | Rewrite | Master orchestrator with sub-agent strategy |
| `auto-claude-notify.py` | Create | Python Slack notifier with threading |
| `auto-claude.sh` | Modify | Remove inline Slack, call Python |
| `auto-claude.nix` | Modify | Deploy Python, add dependencies |

---

## Implementation Order

1. Write new `orchestrator-prompt.txt`
2. Create `auto-claude-notify.py` with Block Kit templates
3. Test notifier standalone with bws secret retrieval
4. Update `auto-claude.sh` to use Python notifier
5. Update `auto-claude.nix` to deploy everything
6. Test end-to-end with real run

---

## Testing

### Unit Tests (Python Notifier)

```bash
# Test secret retrieval
bws secret get auto-claude-slack-bot-token

# Test message posting
auto-claude-notify.py run_started --repo test --budget 1.00 --run-id test123

# Verify in Slack channel
```

### Integration Test

1. Trigger launchd agent manually: `launchctl start com.claude.auto-claude-nix-config`
2. Monitor Slack channel for threaded messages
3. Verify cost/duration/PR info populated
4. Check orchestrator doesn't return early
