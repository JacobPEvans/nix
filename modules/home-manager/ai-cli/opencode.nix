# OpenCode Configuration
#
# Returns home.file entries for OpenCode AI coding agent.
# Imported by home.nix for clean separation of AI CLI configs.
#
# OpenCode is an open-source, provider-agnostic AI coding agent:
# - Works with Claude, OpenAI, Google, or local models
# - Terminal-based with LSP support
# - Two built-in agents: "build" (full access) and "plan" (read-only)
# - MIT licensed
#
# Configuration format:
# - opencode.json: Contains theme, model, and other settings
# - Permissions: Uses unified permission system from common/permissions.nix

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Import permissions (prepared for future use)
  # opencodeAllow = import ../permissions/opencode-permissions-allow.nix { inherit config lib; };
  # opencodeDeny = import ../permissions/opencode-permissions-deny.nix { inherit config lib; };

  # OpenCode settings object
  # See: https://github.com/opencode-ai/opencode (documentation TBD)
  settings = {
    # Theme setting (auto follows terminal theme)
    theme = "auto";

    # Default model configuration
    model = {
      default = "claude-sonnet-4-20250514";
    };

    # Additional settings can be added here as OpenCode evolves
    # Permissions integration pending OpenCode's permission system design
  };

  # Generate JSON config file using writeText + builtins.toJSON
  # This matches the pattern used by other AI CLI configs (e.g., powerline.nix)
  settingsJson = pkgs.writeText "opencode.json" (builtins.toJSON settings);
in
{
  # XDG config path: ~/.config/opencode/opencode.json
  ".config/opencode/opencode.json".source = settingsJson;
}
