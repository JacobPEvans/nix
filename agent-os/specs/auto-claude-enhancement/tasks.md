# Auto-Claude Enhancement Tasks

## Overview

Transform auto-claude into a perpetual orchestrator with rich Slack notifications.

---

## Phase 1: Orchestrator Prompt

### Task 1.1: Write Master Orchestrator Prompt

**File**: `modules/home-manager/ai-cli/claude/orchestrator-prompt.txt`

- [x] Write IDENTITY section (coordinator, not executor)
- [x] Write PRIME DIRECTIVE (never return, never ask, never claim done)
- [x] Write NOTIFICATION PROTOCOL (JSON events to stdout)
- [x] Write CORE LOOP (SCAN → PRIORITIZE → DISPATCH → AWAIT → CAPTURE → LOOP)
- [x] Define SUB-AGENT TYPES (ci-fixer, pr-responder, issue-resolver, doc-updater, test-adder)
- [x] Write SUB-AGENT INSTRUCTIONS (scope, helpers allowed, output format)
- [x] Define PRIORITY ORDER (CI > reviews > bugs > docs > tests > stale)
- [x] Write FORBIDDEN ACTIONS section
- [x] Write RESILIENCE section (handle sub-agent failures)

**Acceptance**: Prompt runs continuously until budget exhausted, delegates all work to sub-agents.

---

## Phase 2: Python Slack Notifier

### Task 2.1: Create Notifier Skeleton

**File**: `modules/home-manager/ai-cli/claude/auto-claude-notify.py`

- [x] Set up CLI with argparse (event type, repo, data args)
- [x] Add bws secret retrieval for SLACK_BOT_TOKEN
- [x] Initialize slack_sdk WebClient
- [x] Add channel lookup from config/args
- [x] Add error handling and logging

**Depends on**: None

### Task 2.2: Implement run_started Event

- [x] Create Block Kit template for run started
- [x] Post parent message to channel
- [x] Return message `ts` for threading
- [x] Include: repo, budget, timestamp, repo link

**Depends on**: 2.1

### Task 2.3: Implement task_started Event

- [x] Create Block Kit template for task dispatch
- [x] Post as thread reply using parent `ts`
- [x] Include: task description, agent type

**Depends on**: 2.2

### Task 2.4: Implement task_completed Event

- [x] Create Block Kit template for task completion
- [x] Post as thread reply
- [x] Include: PR link, cost, duration
- [x] Handle case where no PR created

**Depends on**: 2.2

### Task 2.5: Implement task_blocked Event

- [x] Create Block Kit template for blocked task
- [x] Post as thread reply
- [x] Include: task, blocker reason

**Depends on**: 2.2

### Task 2.6: Implement run_completed Event

- [x] Create Block Kit template for summary
- [x] Post summary as thread reply
- [x] Update parent message with final status
- [x] Include: duration, cost/budget %, tasks completed, tasks blocked, PR links

**Depends on**: 2.2, 2.3, 2.4, 2.5

### Task 2.7: Add Log File Parsing

- [x] Parse JSONL log file for task events
- [x] Extract cost, duration, PRs from log
- [x] Generate summary data from parsed events

**Depends on**: 2.1

---

## Phase 3: Shell Script Updates

### Task 3.1: Remove Inline Slack Code

**File**: `modules/home-manager/ai-cli/claude/auto-claude.sh`

- [x] Remove `slack_post()` function
- [x] Remove `slack_post_blocks()` function
- [x] Remove SLACK_WEBHOOK_URL handling
- [x] Remove jq Block Kit construction

**Depends on**: None (can be done in parallel with Phase 2)

### Task 3.2: Add Python Notifier Calls

- [x] Call `run_started` at script start, capture ts
- [x] Store parent ts in variable for threading
- [x] Call `run_completed` at script end with log file
- [x] Pass repo name, budget, run ID to notifier

**Depends on**: 2.6, 3.1

### Task 3.3: Handle Notifier Errors

- [x] Add error handling for notifier failures
- [x] Continue execution if Slack fails (non-blocking)
- [x] Log notifier errors to summary log

**Depends on**: 3.2

---

## Phase 4: Nix Module Updates

### Task 4.1: Deploy Python Script

**File**: `modules/home-manager/ai-cli/claude/auto-claude.nix`

- [x] Add home.file entry for auto-claude-notify.py
- [x] Set executable = true
- [x] Deploy to ~/.claude/scripts/

**Depends on**: 2.6 (notifier complete)

### Task 4.2: Add Python Dependencies

- [x] Add python3 with slack-sdk to home.packages or wrapper
- [x] Ensure pyyaml available if needed
- [x] Verify bws in PATH for secret retrieval

**Depends on**: 4.1

### Task 4.3: Add Channel Configuration Option

- [x] Add `slackChannel` option to repository config
- [x] Support repo-to-channel mapping
- [x] Pass channel config to launchd agent

**Depends on**: 4.1

---

## Phase 5: Testing

### Task 5.1: Test Notifier Standalone

- [ ] Verify bws secret retrieval works
- [ ] Test run_started posts to correct channel
- [ ] Test threading with task events
- [ ] Verify Block Kit renders correctly in Slack

**Depends on**: 2.6

### Task 5.2: Test Shell Script Integration

- [ ] Run auto-claude.sh manually
- [ ] Verify parent message posted
- [ ] Verify completion message in thread
- [ ] Check no Slack errors in logs

**Depends on**: 3.3, 4.2

### Task 5.3: Test Full End-to-End

- [ ] Trigger launchd agent: `launchctl start com.claude.auto-claude-*`
- [ ] Monitor Slack for threaded notifications
- [ ] Verify orchestrator runs until budget exhausted
- [ ] Confirm sub-agents spawned for tasks
- [ ] Check cost/duration/PR info accurate

**Depends on**: 5.2

---

## Task Summary

| Phase | Tasks | Description | Status |
|-------|-------|-------------|--------|
| 1 | 1.1 | Orchestrator prompt rewrite | ✅ Complete |
| 2 | 2.1-2.7 | Python Slack notifier | ✅ Complete |
| 3 | 3.1-3.3 | Shell script updates | ✅ Complete |
| 4 | 4.1-4.3 | Nix module updates | ✅ Complete |
| 5 | 5.1-5.3 | Testing | ⏳ Pending |

**Total**: 16 tasks across 5 phases (13 complete, 3 pending testing)
