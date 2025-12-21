# OpenCode Configuration Module
#
# Proper Home Manager module for OpenCode AI coding agent.
# Provides declarative configuration with enable option and settings.
#
# OpenCode is a provider-agnostic AI coding agent that supports:
# - Claude (Anthropic)
# - GPT-4 (OpenAI)
# - Gemini (Google)
# - Local models (Ollama)
#
# Configuration format:
# - theme: UI theme (dark, light, auto)
# - model.default: Default AI model to use
# - permissions: Uses unified permission system from common/permissions.nix
#
# Reference: https://github.com/sst/opencode

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.opencode;

  # Import unified permission definitions (commented out until needed)
  # TODO: Uncomment when OpenCode permission format is determined
  # permissions = import ./common/permissions.nix { inherit lib config; };
  # formatters = import ./common/formatters.nix { inherit lib; };

  # OpenCode settings object
  settings = {
    # UI configuration
    inherit (cfg) theme;

    # Model configuration
    model = {
      # Default AI model to use
      default = cfg.defaultModel;
    };

    # TODO: Add shared permissions once OpenCode permission format is determined
    # The formatters.opencode placeholder exists but needs implementation
    # based on OpenCode's actual permission syntax
  };
in
{
  options.programs.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding agent";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "auto";
      description = "UI theme for OpenCode (dark, light, auto).";
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      default = "claude-sonnet-4-20250514";
      description = "Default AI model for OpenCode.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/opencode/opencode.json".source =
      pkgs.formats.json.generate "opencode-settings.json" settings;
  };
}
