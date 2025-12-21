# OpenCode Configuration Module
#
# Declarative home-manager module for OpenCode AI coding agent.
# Follows the pattern established by programs.claude.
#
# Features:
# - Declarative provider configuration (Claude, OpenAI, Google, local)
# - Shared permission integration via ai-assistant-instructions
# - Extensible plugin system (placeholder for Issue #140)
# - Cross-platform support
#
# Usage:
#   programs.opencode = {
#     enable = true;
#     settings.defaultModel = "claude-sonnet-4-20250514";
#     permissions.useShared = true;
#   };
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.opencode;
in
{
  imports = [
    ./options.nix
    ./settings.nix
  ];

  config = lib.mkIf cfg.enable {
    # Install OpenCode package
    home.packages = [ cfg.package ];

    # Ensure config directory exists
    home.activation.opencodeSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create OpenCode configuration directory
      mkdir -p "${config.home.homeDirectory}/${cfg.configDir}"

      # Create plugins directory for future use (Issue #140)
      ${lib.optionalString cfg.plugins.oh-my-opencode.enable ''
        mkdir -p "${config.home.homeDirectory}/${cfg.configDir}/plugins"
      ''}
    '';

    # Warnings and validations
    warnings =
      lib.optional (cfg.permissions.useShared && !config.programs.claude.enable or false) ''
        programs.opencode.permissions.useShared is enabled but programs.claude is not.
        Shared permissions require the claude module for ai-assistant-instructions access.
        Either:
          1. Set programs.opencode.permissions.useShared = false;
          2. Enable programs.claude.enable = true;
      ''
      ++ lib.optional (cfg.plugins.oh-my-opencode.enable && cfg.plugins.oh-my-opencode.source == null) ''
        programs.opencode.plugins.oh-my-opencode.enable is true but source is not set.
        Plugin support requires a flake input. This will be implemented in Issue #140.
      '';

    assertions = [
      {
        assertion = cfg.settings.defaultModel != "";
        message = ''
          programs.opencode.settings.defaultModel must be set to a valid model name.
          Example: programs.opencode.settings.defaultModel = "claude-sonnet-4-20250514";
        '';
      }
      {
        assertion = (lib.length (lib.attrNames (lib.filterAttrs (_: p: p.enabled) cfg.settings.providers))) > 0;
        message = ''
          programs.opencode requires at least one enabled provider.
          Enable a provider with:
            programs.opencode.settings.providers.<provider>.enabled = true;
        '';
      }
    ];
  };
}
