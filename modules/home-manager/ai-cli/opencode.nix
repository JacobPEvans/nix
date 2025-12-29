# OpenCode Configuration
#
# Comprehensive configuration for OpenCode AI coding agent.
# Imported by home.nix for clean separation of AI CLI configs.
#
# OpenCode is an open-source, provider-agnostic AI coding agent:
# - Works with Claude, OpenAI, Google, Groq, or local models
# - Terminal-based TUI with LSP support
# - Two built-in agents: "coder" (full access) and "task" (focused)
# - MCP (Model Context Protocol) server support for extensibility
# - Non-interactive mode for automation (-p flag)
# - MIT licensed
#
# Configuration file: ~/.config/opencode/opencode.json
# Reference: https://github.com/opencode-ai/opencode
#
# Nix packages:
# - nixpkgs: Available as pkgs.opencode
# - Flake: github:AodhanHayter/opencode-flake (auto-updated)
# - Multi-agent: github:numtide/llm-agents.nix (daily builds)

{
  config,
  lib,
  pkgs,
  ai-assistant-instructions ? null,
  ...
}:

let
  homeDir = config.home.homeDirectory;

  # Import permissions from common module if available
  permissions =
    if ai-assistant-instructions != null then
      let
        aiCommon = import ./common {
          inherit lib config ai-assistant-instructions;
        };
      in
      aiCommon.permissions
    else
      { };

  # OpenCode settings object
  # Full configuration reference: https://github.com/opencode-ai/opencode
  settings = {
    # Theme setting (auto follows terminal theme)
    theme = "auto";

    # Data directory for sessions (SQLite database)
    # Default: ~/.local/share/opencode
    data = "${homeDir}/.local/share/opencode";

    # Default provider and model configuration
    # Supports: anthropic, openai, google, groq, openrouter, bedrock, azure, copilot
    providers = {
      # Anthropic (Claude) - Primary provider
      anthropic = {
        # API key from environment: ANTHROPIC_API_KEY
        # Disabled = false means enabled
        disabled = false;
      };

      # OpenAI - Secondary provider
      openai = {
        # API key from environment: OPENAI_API_KEY
        disabled = false;
      };

      # Google (Gemini) - Tertiary provider
      google = {
        # API key from environment: GOOGLE_API_KEY or GEMINI_API_KEY
        disabled = false;
      };

      # Groq - Fast inference for open models
      groq = {
        # API key from environment: GROQ_API_KEY
        disabled = true; # Enable when needed
      };

      # GitHub Copilot - Uses existing Copilot auth
      copilot = {
        disabled = false;
      };
    };

    # Agent configurations
    agents = {
      # Primary coding agent (full tool access)
      coder = {
        model = "claude-sonnet-4-20250514";
        maxTokens = 16384;
      };

      # Task agent (focused, read-heavy operations)
      task = {
        model = "claude-haiku-4-5-20251001";
        maxTokens = 8192;
      };

      # Title generation agent
      title = {
        model = "claude-haiku-4-5-20251001";
        maxTokens = 1024;
      };
    };

    # Auto-compact settings
    # Automatically summarizes conversation at threshold to prevent context exhaustion
    autoCompact = {
      enabled = true;
      threshold = 95; # Percentage of context window
    };

    # Shell configuration for command execution
    shell = {
      # Use zsh with proper profile loading
      path = "/bin/zsh";
      args = [
        "-l"
        "-c"
      ];
    };

    # MCP (Model Context Protocol) Servers
    # Extend OpenCode with external tools and integrations
    # Reference: https://opencode.ai/docs/mcp-servers/
    mcp = {
      # Bitwarden MCP server for secrets management
      # bitwarden = {
      #   type = "stdio";
      #   command = "${homeDir}/.npm-packages/bin/mcp-server-bitwarden";
      #   args = [];
      # };

      # Slack MCP server for channel integration
      # Reference: github:korotovsky/slack-mcp-server
      # slack = {
      #   type = "stdio";
      #   command = "npx";
      #   args = ["-y" "@anthropic/mcp-server-slack"];
      # };

      # Filesystem MCP server for file operations
      # filesystem = {
      #   type = "stdio";
      #   command = "npx";
      #   args = ["-y" "@modelcontextprotocol/server-filesystem" homeDir];
      # };
    };

    # LSP (Language Server Protocol) configuration
    # Provides code intelligence across multiple languages
    lsp = {
      # Go
      # go = {
      #   command = "gopls";
      #   args = [];
      # };

      # TypeScript/JavaScript
      # typescript = {
      #   command = "typescript-language-server";
      #   args = ["--stdio"];
      # };

      # Nix
      # nix = {
      #   command = "nil";
      #   args = [];
      # };
    };
  };

  # Generate pretty-printed JSON using a derivation with jq
  settingsJson =
    pkgs.runCommand "opencode.json"
      {
        nativeBuildInputs = [ pkgs.jq ];
        json = builtins.toJSON settings;
        passAsFile = [ "json" ];
      }
      ''
        jq '.' "$jsonPath" > $out
      '';
in
{
  # XDG config path: ~/.config/opencode/opencode.json
  ".config/opencode/opencode.json".source = settingsJson;

  # Create data directory marker
  ".local/share/opencode/.keep".text = ''
    # OpenCode data directory
    # Contains session history (SQLite)
  '';
}
