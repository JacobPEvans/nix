# OpenCode Module Options
#
# Configuration options for the programs.opencode module.
# Follows the pattern established by programs.claude.
{ lib, pkgs, ... }:

with lib;

let
  # Provider configuration submodule
  providerModule = types.submodule {
    options = {
      apiKey = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "API key for the provider (use null to read from environment)";
      };

      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Enable this provider";
      };

      models = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of available models for this provider";
      };
    };
  };

in
{
  options.programs.opencode = {
    enable = mkEnableOption "OpenCode AI coding agent";

    package = mkOption {
      type = types.package;
      default = pkgs.opencode or pkgs.hello; # Placeholder until opencode is in nixpkgs
      description = "OpenCode package to use";
    };

    settings = {
      theme = mkOption {
        type = types.enum [
          "dark"
          "light"
          "auto"
        ];
        default = "auto";
        description = "UI theme for OpenCode";
      };

      defaultModel = mkOption {
        type = types.str;
        default = "claude-sonnet-4-20250514";
        description = "Default AI model to use";
      };

      # Provider configuration
      providers = mkOption {
        type = types.attrsOf providerModule;
        default = {
          claude = {
            enabled = true;
            models = [
              "claude-sonnet-4-20250514"
              "claude-opus-4-20250514"
            ];
          };
          openai = {
            enabled = false;
            models = [
              "gpt-4-turbo"
              "gpt-4o"
            ];
          };
          google = {
            enabled = false;
            models = [
              "gemini-2.0-flash-exp"
              "gemini-exp-1206"
            ];
          };
          local = {
            enabled = false;
            models = [
              "qwen3-coder:30b"
              "qwen3-next:80b"
            ];
          };
        };
        description = "Provider configurations for different AI backends";
      };

      # Environment variables for OpenCode
      env = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = ''
          Environment variables passed to OpenCode.
          Common variables:
          - OPENCODE_API_KEY: API key for default provider
          - OPENCODE_BASE_URL: Custom API endpoint
          - OPENCODE_TIMEOUT: Request timeout in seconds
        '';
        example = {
          OPENCODE_TIMEOUT = "120";
        };
      };
    };

    # Permissions configuration
    permissions = {
      useShared = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Use shared permission definitions from ai-assistant-instructions.
          When true, OpenCode will use the same permission patterns as Claude.
        '';
      };

      allow = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "OpenCode-specific commands to auto-approve (added to shared if useShared is true)";
      };

      deny = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "OpenCode-specific commands to deny (added to shared if useShared is true)";
      };

      ask = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "OpenCode-specific commands requiring confirmation (added to shared if useShared is true)";
      };
    };

    # Placeholder for future plugin support (Issue #140)
    plugins = {
      oh-my-opencode = {
        enable = mkEnableOption "Oh-My-OpenCode plugin manager";

        source = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to oh-my-opencode flake input";
        };
      };

      enabled = mkOption {
        type = types.attrsOf types.bool;
        default = { };
        description = "Map of plugin names to enabled status";
      };
    };

    # Configuration file paths
    configDir = mkOption {
      type = types.str;
      default = ".config/opencode";
      description = "Directory for OpenCode configuration files";
    };

    schemaUrl = mkOption {
      type = types.str;
      default = "https://json.schemastore.org/opencode-settings.json";
      description = "JSON schema URL for settings validation";
    };
  };
}
