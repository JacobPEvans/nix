# OpenCode Integration Planning

**Branch:** `claude/slack-replace-sugar-with-opencode-xmGTN`
**Created:** 2025-12-29
**Status:** Initial Implementation

## Overview

This document tracks the integration of OpenCode as a complement/alternative to auto-claude
for AI-assisted development workflows.

## Completed Work

### 1. Sugar Plugin Removal

**File:** `modules/home-manager/ai-cli/claude/plugins/community.nix`

Removed `"sugar@cc-marketplace" = true;` reference.

### 2. OpenCode Module Enhancement

**File:** `modules/home-manager/ai-cli/opencode.nix`

Enhanced configuration with:

- Multi-provider support (Anthropic, OpenAI, Google, Groq, Copilot)
- Agent configurations (coder, task, title)
- Auto-compact settings
- MCP server structure (commented templates)
- LSP configuration structure (commented templates)
- Shell configuration for command execution

### 3. Documentation

**File:** `docs/OPENCODE.md`

Created comprehensive documentation covering:

- Installation methods (nixpkgs, flakes)
- Configuration options
- Feature comparison with auto-claude
- MCP server integration
- OrbStack integration patterns

## OpenCode vs Auto-Claude Analysis

### Features Auto-Claude Has That OpenCode Lacks

| Feature | Auto-Claude | OpenCode | Gap Resolution |
|---------|-------------|----------|----------------|
| Slack notifications | Native Block Kit | None | MCP server needed |
| Cost tracking | Per-run budgets | None | API-level estimation |
| Scheduled runs | launchd native | None | Wrapper script needed |
| JSONL logging | events.jsonl | None | Wrapper script needed |
| Anomaly detection | Built-in | None | External monitor needed |
| Control interface | ctl script | None | Wrapper script needed |

### Features OpenCode Has That Auto-Claude Lacks

| Feature | OpenCode | Auto-Claude | Notes |
|---------|----------|-------------|-------|
| Multi-provider | 7+ providers | Anthropic only | Major flexibility advantage |
| Provider fallback | Configurable | None | Resilience |
| Native MCP | Built-in | Via Claude Code | Direct integration |
| Native LSP | Built-in | Via Claude Code | Code intelligence |
| MIT license | Open source | Proprietary | Self-hosting option |

### Recommendation

**Run both tools in parallel:**

1. **Auto-Claude**: Scheduled maintenance tasks
   - Existing infrastructure (Slack, monitoring, scheduling)
   - Budget-controlled runs
   - Automated PR creation

2. **OpenCode**: Interactive development
   - Multi-provider flexibility
   - Model switching on-the-fly
   - MCP-based extensibility

## Future Integration Architecture

### Phase 1: Current State (Completed)

```text
┌─────────────────────────────────────────────────────────────────┐
│                    AI Coding Agents                              │
├───────────────────────────────┬─────────────────────────────────┤
│         Auto-Claude            │           OpenCode              │
│  ┌─────────────────────────┐  │  ┌─────────────────────────┐   │
│  │ Scheduled Maintenance   │  │  │ Interactive Coding      │   │
│  │ • launchd scheduling    │  │  │ • Multi-provider        │   │
│  │ • Slack notifications   │  │  │ • TUI interface         │   │
│  │ • Cost budgets          │  │  │ • Session management    │   │
│  │ • JSONL logging         │  │  │ • MCP/LSP support       │   │
│  └─────────────────────────┘  │  └─────────────────────────┘   │
└───────────────────────────────┴─────────────────────────────────┘
```

### Phase 2: Wrapper Development (Planned)

Create `auto-opencode` wrapper with:

```nix
# Proposed: modules/home-manager/ai-cli/opencode/auto-opencode.nix
{
  launchd.agents."com.opencode.auto-opencode" = {
    # Similar structure to auto-claude
    # Uses opencode -p for non-interactive execution
    # Wraps with Slack notification calls
  };
}
```

### Phase 3: OrbStack/K8s Integration

```text
┌─────────────────────────────────────────────────────────────────┐
│                    OrbStack Environment                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────┐  ┌───────────────────┐                   │
│  │ OpenCode Container │  │ Auto-Claude       │                   │
│  │ (K8s CronJob)      │  │ (launchd/K8s)     │                   │
│  └────────┬──────────┘  └────────┬──────────┘                   │
│           │                      │                               │
│           ▼                      ▼                               │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              Shared MCP Servers                              ││
│  │  • Slack MCP     • Kubernetes MCP    • Terraform MCP        ││
│  └─────────────────────────────────────────────────────────────┘│
│           │                      │                               │
│           ▼                      ▼                               │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │           Monitoring (OTEL → Cribl → Splunk)                 ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Phase 4: Terraform/Proxmox Integration

For `JacobPEvans/terraform-proxmox` integration:

```text
┌─────────────────────────────────────────────────────────────────┐
│                    Server Infrastructure                         │
├─────────────────────────────────────────────────────────────────┤
│  MacBook (OrbStack)              │  Proxmox Server              │
│  ┌─────────────────────────┐     │  ┌─────────────────────────┐ │
│  │ OpenCode + Auto-Claude  │     │  │ OpenCode Container      │ │
│  │ (Development)           │────▶│  │ (Production Jobs)       │ │
│  └─────────────────────────┘     │  └─────────────────────────┘ │
│                                   │                              │
│  terraform apply ────────────────▶  VM provisioning             │
└───────────────────────────────────┴──────────────────────────────┘
```

## MCP Server Development Priorities

### High Priority

1. **Slack MCP Server** (for OpenCode notifications)
   - Use existing `slack-mcp-server` or `slack-mcp-client`
   - Configure for same channels as auto-claude

2. **Kubernetes MCP Server**
   - kubectl operations
   - Log streaming
   - Pod management

### Medium Priority

3. **Terraform MCP Server**
   - State operations
   - Plan/apply execution
   - Resource queries

4. **Ansible MCP Server**
   - Playbook execution
   - Inventory queries
   - Role management

### Low Priority

5. **Bitwarden MCP Server** (already configured)
6. **Filesystem MCP Server** (standard)

## Nix Module Structure

### Current

```text
modules/home-manager/ai-cli/
├── claude/                    # Claude Code module (complex)
│   ├── auto-claude.nix       # Scheduled automation
│   ├── auto-claude-notify.py # Slack notifications
│   └── ...
├── opencode.nix              # OpenCode config (simple)
├── gemini.nix                # Gemini CLI config
└── copilot.nix               # Copilot CLI config
```

### Proposed (Phase 2)

```text
modules/home-manager/ai-cli/
├── claude/                    # Claude Code module
│   └── ...
├── opencode/                  # OpenCode module (expanded)
│   ├── default.nix           # Main module
│   ├── config.nix            # Configuration values
│   ├── auto-opencode.nix     # Scheduled automation
│   ├── mcp-servers.nix       # MCP server definitions
│   └── lsp.nix               # LSP configurations
├── gemini.nix
└── copilot.nix
```

## Testing Commands

```bash
# Verify OpenCode installation
which opencode
opencode --version

# Test interactive mode
opencode

# Test non-interactive mode
opencode -p "What is 2+2?" -q

# Verify configuration
cat ~/.config/opencode/opencode.json | jq

# Rebuild after changes
sudo darwin-rebuild switch --flake .
```

## Related Files

- `modules/home-manager/ai-cli/opencode.nix` - OpenCode configuration
- `modules/darwin/common.nix` - Package installation
- `modules/home-manager/common.nix` - File deployment
- `docs/OPENCODE.md` - Documentation

## References

- [OpenCode GitHub](https://github.com/opencode-ai/opencode)
- [OpenCode Nix Flake](https://github.com/AodhanHayter/opencode-flake)
- [Numtide LLM Agents](https://github.com/numtide/llm-agents.nix)
- [MCP Specification](https://modelcontextprotocol.org/)
- [Slack MCP Server](https://github.com/korotovsky/slack-mcp-server)
