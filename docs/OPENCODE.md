# OpenCode AI Coding Agent

OpenCode is an open-source, provider-agnostic AI coding agent built for the terminal.

## Overview

OpenCode provides a terminal-based AI coding assistant with:

- **Multi-provider support**: Claude, OpenAI, Google, Groq, GitHub Copilot, local models
- **TUI interface**: Smooth terminal experience with vim-like editor integration
- **MCP integration**: Extensible via Model Context Protocol servers
- **LSP support**: Code intelligence across multiple languages
- **Session management**: Persistent conversations with SQLite storage
- **Non-interactive mode**: Automation-ready with `-p` flag

**Project**: [github.com/opencode-ai/opencode](https://github.com/opencode-ai/opencode)

## Installation

OpenCode is installed via nixpkgs in `modules/darwin/common.nix`:

```nix
environment.systemPackages = with pkgs; [
  opencode # Provider-agnostic AI coding agent
];
```

Alternative Nix sources for latest versions:

```bash
# Direct from nixpkgs
nix run nixpkgs#opencode

# Auto-updated flake (latest releases)
nix run github:AodhanHayter/opencode-flake

# Numtide multi-agent flake (daily builds)
nix run github:numtide/llm-agents.nix#opencode
```

## Configuration

Configuration file: `~/.config/opencode/opencode.json`

Managed by: `modules/home-manager/ai-cli/opencode.nix`

### Current Settings

```json
{
  "theme": "auto",
  "data": "~/.local/share/opencode",
  "providers": {
    "anthropic": { "disabled": false },
    "openai": { "disabled": false },
    "google": { "disabled": false },
    "copilot": { "disabled": false }
  },
  "agents": {
    "coder": { "model": "claude-sonnet-4-20250514" },
    "task": { "model": "claude-haiku-4-5-20251001" }
  },
  "autoCompact": { "enabled": true, "threshold": 95 }
}
```

### Environment Variables

```bash
# Required for each provider
ANTHROPIC_API_KEY="..."
OPENAI_API_KEY="..."
GOOGLE_API_KEY="..." # or GEMINI_API_KEY
GROQ_API_KEY="..."
```

## Usage

### Interactive Mode (TUI)

```bash
# Start OpenCode in current directory
opencode

# Keyboard shortcuts
Ctrl+N  # New session
Ctrl+A  # Switch session
Ctrl+C  # Cancel current operation
```

### Non-Interactive Mode

```bash
# Single prompt, text output
opencode -p "Explain this codebase"

# JSON output for automation
opencode -p "List all TODO comments" -f json

# Quiet mode (no spinner)
opencode -p "Fix the bug" -q

# Working directory
opencode -c /path/to/project -p "Run tests"
```

## OpenCode vs Auto-Claude Comparison

### Feature Comparison

| Feature | OpenCode | Auto-Claude |
|---------|----------|-------------|
| **Provider** | Multi-provider | Anthropic only |
| **Scheduling** | None (wrapper needed) | launchd native |
| **Slack Integration** | Via MCP server | Native Block Kit |
| **Cost Tracking** | None | Per-run budgets |
| **JSONL Logging** | None | Native events.jsonl |
| **Anomaly Detection** | None | Built-in monitor |
| **Control Script** | None | pause/resume/status |
| **Session Storage** | SQLite | SQLite |
| **MCP Support** | Native | Via Claude Code |
| **LSP Support** | Native | Via Claude Code |
| **License** | MIT | Proprietary |

### Auto-Claude Customizations Not in OpenCode

1. **Slack Notifications** (Block Kit):
   - `run_started`, `run_completed`, `task_started`, `task_completed`
   - Threaded messages with parent/child relationship
   - Real-time status updates

2. **Budget Management**:
   - Per-run cost limits (`maxBudget`)
   - Budget exhaustion detection
   - Cost tracking per task

3. **Scheduled Execution**:
   - launchd calendar intervals
   - Multi-repository support
   - Staggered schedules

4. **Monitoring Infrastructure**:
   - JSONL event logging → OTEL/Cribl
   - Anomaly detection (context exhaustion, loops)
   - Consecutive failure alerts

5. **Control Interface**:
   - `auto-claude-ctl pause/resume/run/status`
   - Runtime pause with resume timestamps

### Can OpenCode Replace Auto-Claude?

**Short answer**: Not without significant wrapper development.

**What OpenCode provides**:
- Non-interactive mode (`-p` flag) for scripted use
- JSON output (`-f json`) for parsing
- Session persistence for context continuity
- MCP servers for external integrations

**What would need to be built**:
- Wrapper script for launchd scheduling
- Slack notification integration (via MCP or external)
- Cost tracking and budget enforcement
- JSONL event logging
- Anomaly detection logic

**Recommendation**: Run OpenCode alongside auto-claude as complementary tools:
- Use **auto-claude** for scheduled maintenance (existing infrastructure)
- Use **OpenCode** for interactive coding and multi-provider flexibility

## MCP Server Integration

OpenCode supports MCP servers for extensibility:

```json
{
  "mcp": {
    "slack": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-slack"]
    },
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "~"]
    }
  }
}
```

### Slack MCP Options

1. **slack-mcp-client** ([github](https://github.com/tuannvm/slack-mcp-client)):
   - Full bridge between Slack and MCP
   - Supports all transport methods
   - Prometheus metrics, OpenTelemetry tracing

2. **slack-mcp-server** ([github](https://github.com/korotovsky/slack-mcp-server)):
   - Read Slack channels from OpenCode
   - Stealth mode (no bot installation required)
   - DMs, Group DMs, message history

## OrbStack Integration

OpenCode can work with OrbStack/Kubernetes via:

1. **Direct CLI**: Run `kubectl` commands through OpenCode's shell
2. **MCP Server**: Create custom MCP server for K8s operations
3. **LSP**: Code intelligence for Kubernetes manifests

Example workflow:

```bash
# OpenCode can execute kubectl commands
opencode -p "List all pods in monitoring namespace"

# Or work with manifest files
opencode -p "Fix the deployment in modules/monitoring/k8s/"
```

## Future Roadmap

### Potential Enhancements

1. **auto-opencode wrapper**:
   - launchd-based scheduling (like auto-claude)
   - Slack notifications via MCP
   - Cost estimation (API-level, not native)

2. **OrbStack MCP Server**:
   - Container management operations
   - Log streaming integration
   - Volume mount helpers

3. **Terraform/Ansible Integration**:
   - MCP servers for infrastructure tools
   - State file operations
   - Playbook execution

## Related Documentation

- [Auto-Claude](../modules/home-manager/ai-cli/claude/TESTING.md)
- [Monitoring](MONITORING.md)
- [Slack Notifications](monitoring/SLACK.md)
- [Anthropic Ecosystem](ANTHROPIC-ECOSYSTEM.md)

## References

- [OpenCode GitHub](https://github.com/opencode-ai/opencode)
- [OpenCode Documentation](https://opencode.ai/docs/)
- [MCP Specification](https://modelcontextprotocol.org/)
- [OpenCode Nix Flake](https://github.com/AodhanHayter/opencode-flake)
- [Numtide LLM Agents](https://github.com/numtide/llm-agents.nix)
