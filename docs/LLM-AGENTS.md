# LLM Agents via numtide/llm-agents.nix

Nix packages for 40+ AI coding agents and development tools with daily updates.

## Overview

This configuration uses [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix)
as the source for AI coding agent packages. Benefits:

- **Daily updates**: Packages rebuilt automatically via CI
- **Binary cache**: Pre-built binaries from Numtide cache (fast installs)
- **Multi-platform**: aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
- **Single source**: Consistent versions across all AI tools

## Installed Agents

The following agents are installed via `modules/darwin/common.nix`:

| Package | Description |
|---------|-------------|
| `claude-code` | Anthropic's agentic coding CLI |
| `crush` | Charmbracelet's AI coding agent (successor to OpenCode) |
| `gemini-cli` | Google's Gemini CLI |
| `copilot-cli` | GitHub Copilot CLI |
| `goose-cli` | Block's open-source AI agent |

### Available but Not Installed

```nix
# Enable in modules/darwin/common.nix if needed:
llmAgentsPkgs.codex      # OpenAI Codex agent
llmAgentsPkgs.qwen-code  # Alibaba's Qwen3-Coder
llmAgentsPkgs.droid      # Android development agent
llmAgentsPkgs.catnip     # Cat-themed AI assistant
llmAgentsPkgs.kilocode-cli
llmAgentsPkgs.letta-code
llmAgentsPkgs.mistral-vibe
llmAgentsPkgs.nanocoder
```

## Flake Configuration

The flake input in `flake.nix`:

```nix
inputs = {
  llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Usage in modules:

```nix
{ pkgs, llm-agents, ... }:
let
  llmAgentsPkgs = llm-agents.packages.${pkgs.system};
in
{
  environment.systemPackages = [
    llmAgentsPkgs.claude-code
    llmAgentsPkgs.crush
  ];
}
```

## Binary Cache

The flake automatically uses Numtide's binary cache. For faster builds,
add to your Nix configuration:

```nix
nix.settings = {
  extra-substituters = [ "https://cache.numtide.com" ];
  extra-trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
};
```

## Try Without Installing

```bash
# Run any agent directly
nix run github:numtide/llm-agents.nix#claude-code
nix run github:numtide/llm-agents.nix#crush
nix run github:numtide/llm-agents.nix#gemini-cli
nix run github:numtide/llm-agents.nix#goose-cli
```

## Update Packages

To get the latest versions:

```bash
# Update the flake input
nix flake lock --update-input llm-agents

# Rebuild
sudo darwin-rebuild switch --flake .
```

## Configuration Files

Each agent has its own configuration:

| Agent | Config Location | Module |
|-------|-----------------|--------|
| Claude Code | `~/.claude/settings.json` | `modules/home-manager/ai-cli/claude/` |
| Crush | `~/.config/crush/crush.json` | `modules/home-manager/ai-cli/crush.nix` |
| Gemini | `~/.config/gemini/settings.json` | `modules/home-manager/ai-cli/gemini.nix` |
| Copilot | `~/.config/github-copilot/` | `modules/home-manager/ai-cli/copilot.nix` |

## Related Documentation

- [Crush AI Agent](CRUSH.md) - Detailed Crush configuration
- [Anthropic Ecosystem](ANTHROPIC-ECOSYSTEM.md) - Claude Code ecosystem
- [Permissions](PERMISSIONS.md) - Unified permission system

## References

- [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix)
- [Charmbracelet Crush](https://github.com/charmbracelet/crush)
- [Numtide Cache](https://cache.numtide.com)
