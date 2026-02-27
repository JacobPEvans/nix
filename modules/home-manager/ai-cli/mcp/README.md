# MCP Servers - Nix-Native Configuration

MCP server definitions are declared in `default.nix` and deployed to `~/.claude.json`
automatically on every `darwin-rebuild switch` via a `home.activation` script.

**Nix is the sole manager of user-scoped MCP servers.** Any entries added manually via
`claude mcp add --scope user` will be overwritten on the next rebuild.

## Transports

### stdio (local processes)

Run a local command as the MCP server. Use `mkServer` or `officialServer` helpers:

```nix
# Official Anthropic server via bunx
fetch = officialServer { name = "fetch"; enabled = true; };

# nixpkgs binary (resolved via PATH)
github = mkServer { enabled = true; command = "github-mcp-server"; };

# npm package via bunx
context7 = mkServer {
  enabled = true;
  command = "bunx";
  args = [ "@context7/mcp-server" ];
};
```

### SSE / HTTP (remote servers)

Connect to a running HTTP server using SSE or HTTP transport. Use `mkRemoteServer`:

```nix
# SSE server (default type)
cribl = mkRemoteServer {
  enabled = true;
  url = "http://localhost:30030/mcp";
};

# HTTP server with custom headers
my-server = mkRemoteServer {
  enabled = true;
  type = "http";
  url = "http://localhost:8080/mcp";
  headers = { Authorization = "Bearer \${TOKEN}"; };
};
```

## Enabling Servers

Edit `modules/home-manager/ai-cli/mcp/default.nix` and set `enabled = true`.
Then run `darwin-rebuild switch --flake .` to deploy.

## Secrets Management

### Environment variables (default)

Servers requiring API keys read them from environment variables at runtime.
Use your secrets manager (Doppler, Keychain, 1Password, etc.) to inject env vars.

Required env vars are documented in comments above each server definition.
The config does NOT store any secrets — it only references commands and URLs.

### Doppler injection via `withDoppler`

For servers whose secrets live in Doppler (project `ai-ci-automation`, config `prd`),
wrap the server definition with `withDoppler`:

```nix
pal = withDoppler (mkServer {
  enabled = true;
  command = "uvx";
  args = [ "--from" "git+https://..." "pal-mcp-server" ];
});
```

This sets `command = "doppler-mcp"` and shifts the original command into `args[0]`.
The `doppler-mcp` script (defined in `ai-tools.nix`) runs:

```bash
doppler run -p ai-ci-automation -c prd -- <original-command> [args...]
```

Secrets are fetched at subprocess launch time and injected as environment variables.
They are never written to `~/.claude.json` or any other file Claude Code can read.

**Non-secret config belongs in Nix, not Doppler.** Use the `env` attr on `mkServer` for
configuration values that are not sensitive (feature flags, timeouts, log levels). `withDoppler`
preserves all attrs from the original server — `env` is merged into the deployed config unchanged:

```nix
pal = withDoppler (mkServer {
  enabled = true;
  command = "uvx";
  args = [ "--from" "git+https://..." "pal-mcp-server" ];
  env = {
    DISABLED_TOOLS = "";         # non-secret config → Nix
    LOG_LEVEL = "INFO";          # non-secret config → Nix
    # GEMINI_API_KEY, OLLAMA_HOST → injected by Doppler at runtime
  };
});
```

**Adding a new Doppler-wrapped server:**

```nix
my-server = withDoppler (mkServer {
  enabled = true;
  command = "uvx";
  args = [ "my-mcp-server" ];
});

# Or with an official server:
exa = withDoppler (officialServer { name = "exa"; enabled = true; });
```

## PAL MCP Tools

The PAL server exposes 16 tools for multi-model AI orchestration.
The last 6 are disabled upstream by default; `DISABLED_TOOLS = ""` enables all of them.

| Tool | Description |
|------|-------------|
| `chat` | Single-model conversation |
| `thinkdeep` | Extended reasoning with chain-of-thought |
| `planner` | Architecture and design planning |
| `codereview` | Multi-model code review |
| `precommit` | Pre-commit review |
| `debug` | Systematic debugging |
| `apilookup` | API documentation lookup |
| `challenge` | Devil's advocate reasoning |
| `clink` | Multi-model parallel query |
| `consensus` | Multi-model consensus debate |
| `analyze` | Code analysis |
| `refactor` | Code refactoring |
| `testgen` | Test generation |
| `secaudit` | Security audit |
| `docgen` | Documentation generation |
| `tracer` | Execution tracing |

### Prerequisites for `clink`

`clink` bridges to other AI CLIs. These must be installed and on `PATH`:

- `gemini` — Homebrew brew: `gemini-cli`
- `claude` — Homebrew cask: `claude-code`

## PAL Ollama Model Discovery

PAL's model registry (`custom_models.json`) is generated automatically from `ollama list`
during every `darwin-rebuild switch`. This keeps PAL's model list in sync with your locally
installed Ollama models without manual configuration.

### How it works

1. `claude/pal-models.nix` adds a `palCustomModels` activation script and injects
   `CUSTOM_MODELS_CONFIG_PATH=~/.config/pal-mcp/custom_models.json` into the PAL server env.
2. The activation script sources `mcp/scripts/generate-pal-models.sh`, which runs
   `ollama list` and writes a JSON registry entry for each model.
3. PAL reads the registry at startup. All Ollama models appear under **Custom/Local API**.

If Ollama is not running at rebuild time the existing file is kept unchanged (no error).

### Adding new models

```bash
ollama pull qwen3-coder:30b
sync-ollama-models          # Regenerate registry (no rebuild required)
# Restart Claude Code to pick up the new models
```

### The colon alias trick

PAL's `parse_model_option()` strips `:tag` from model names before registry lookup. A model
named `glm-5:cloud` must therefore be registered with alias `glm-5`. The generator handles
this automatically:

| Ollama name | model_name sent to API | Aliases |
|-------------|------------------------|---------|
| `glm-5:cloud` | `glm-5:cloud` | `glm-5`, `glm-5-cloud` |
| `qwen3-coder:30b` | `qwen3-coder:30b` | `qwen3-coder`, `qwen3-coder-30b` |
| `qwen3-next:latest` | `qwen3-next` | `qwen3-next` |

When PAL sees `glm-5`, it strips the (absent) colon-suffix, looks up `glm-5` in the registry,
resolves to `glm-5:cloud`, and sends that tag to the Ollama API.

### Intelligence score heuristic

Scores are estimated from model file size. Adjust if needed by editing
`mcp/scripts/generate-pal-models.sh`.

| Size | Score |
|------|-------|
| cloud / 0 GB | 14 |
| < 5 GB | 5 |
| 5–20 GB | 8 |
| 20–40 GB | 11 |
| 40–70 GB | 14 |
| 70+ GB | 17 |

## Adding New Servers

1. Choose the right helper:
   - Local stdio process → `mkServer` or `officialServer`
   - Local stdio with Doppler secrets → wrap with `withDoppler`
   - Remote SSE/HTTP endpoint → `mkRemoteServer`

2. Set `enabled = false` initially, test, then enable.

3. Run `darwin-rebuild switch --flake .` to deploy.

4. Verify: `cat ~/.claude.json | jq .mcpServers`

## Troubleshooting

### Server not appearing in Claude Code

1. Check `enabled = true` in `mcp/default.nix`
2. Run `darwin-rebuild switch --flake .`
3. Restart Claude Code
4. Check `~/.claude.json` contains the server: `jq .mcpServers ~/.claude.json`

### SSE server shows connection error

Expected when the remote server is not running (e.g., OrbStack k8s is stopped).
The server definition is still deployed — it will connect when the server is available.

### "command not found" for a stdio server

Verify the binary is in PATH. For nixpkgs packages, ensure it's installed in your profile
or system packages. For bunx/uvx, ensure bun/uv is installed.
