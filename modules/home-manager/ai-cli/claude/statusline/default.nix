# Claude Statusline Module
#
# Declarative statusline theme selection for Claude Code.
# Provides a unified interface for managing statusline themes and configuration.
#
# This module follows NixOS module patterns:
# - Options defined in options.nix
# - Theme implementations in separate files (robbyrussell.nix, powerline.nix, advanced.nix)
# - Config logic uses lib.mkIf for conditional activation
#
# Usage:
#   programs.claudeStatusline = {
#     enable = true;
#     theme = "robbyrussell";  # robbyrussell | powerline | advanced
#   };
#
# Related Issues:
# - #80: This module (options framework)
# - #81: Powerline theme implementation
# - #82: Advanced theme implementation
{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.claudeStatusline;
in
{
  imports = [
    ./options.nix
    ./robbyrussell.nix
    ./powerline.nix
    ./advanced.nix
  ];

  config = lib.mkIf cfg.enable {
    assertions = [
      # Prevent conflicts between old and new statusline modules
      {
        assertion = !(config.programs.claude.statusLine.enable or false);
        message = ''
          Both programs.claude.statusLine and programs.claudeStatusline are enabled.

          Please use only one statusline module. The programs.claudeStatusline module
          is the new recommended interface.

          To migrate:
          1. Disable the old module: programs.claude.statusLine.enable = false;
          2. Keep using programs.claudeStatusline with your chosen theme
        '';
      }

      # Validate source configuration for robbyrussell theme
      # Note: This assertion allows powerline/advanced themes without source configuration,
      # since those themes will have their own source requirements in future implementations.
      # Only robbyrussell currently requires the legacy source configuration.
      {
        assertion =
          cfg.theme != "robbyrussell" || (config.programs.claude.statusLine.enhanced.source or null) != null;
        message = ''
          programs.claudeStatusline is enabled with theme 'robbyrussell', but source is not configured.

          The robbyrussell theme requires the claude-code-statusline source to be specified.
          Please configure it via the legacy interface (for now):

            programs.claude.statusLine = {
              enable = true;
              enhanced = {
                enable = true;
                source = inputs.claude-code-statusline;
              };
            };

          Then enable the new statusline module:
            programs.claudeStatusline = {
              enable = true;
              theme = "robbyrussell";
            };

          Note: This is a transitional requirement. Future versions will consolidate
          the source configuration into programs.claudeStatusline directly.
        '';
      }
    ];
  };
}
