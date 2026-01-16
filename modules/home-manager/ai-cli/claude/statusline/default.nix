# Claude Statusline Module
#
# Multi-line statusline for Claude Code using @owloops/claude-powerline.
# Uses bunx at runtime for simplicity - no build-time hashes to maintain.
#
# This module follows NixOS module patterns:
# - Options defined in options.nix
# - Theme implementation in powerline.nix
# - Config logic uses lib.mkIf for conditional activation
#
# Usage:
#   programs.claudeStatusline.enable = true;
#
# Configuration is hardcoded to Rose Pine theme with capsule style.
# See powerline.nix for the full configuration.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.claudeStatusline;

  # Platform detection: Check if we're on Darwin (macOS)
  # The statusline packages use BSD stat which only works on Darwin
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  imports = [
    ./options.nix
    ./powerline.nix
  ];

  config = lib.mkIf cfg.enable {
    assertions = [
      # Platform check: statusline packages require Darwin (macOS)
      # The underlying scripts use BSD stat (stat -f "%m") which is not available on Linux
      {
        assertion = isDarwin;
        message = ''
          programs.claudeStatusline requires macOS/Darwin.

          The statusline packages use BSD stat command (stat -f "%m") which is
          Darwin-specific. Linux support would require updating the scripts to
          detect and use GNU stat syntax (stat -c "%Y") instead.

          Current platform: ${pkgs.stdenv.hostPlatform.system}
          Required: *-darwin (e.g., aarch64-darwin, x86_64-darwin)
        '';
      }

      # Prevent conflicts between old and new statusline modules
      {
        assertion = !(config.programs.claude.statusLine.enhanced.enable or false);
        message = ''
          Both programs.claude.statusLine.enhanced and programs.claudeStatusline are enabled.

          This creates a conflict as both modules will try to deploy the statusline.
          Please use only one statusline module. The programs.claudeStatusline module
          is the new recommended interface.

          To fix:
          1. Set programs.claude.statusLine.enhanced.enable = false;
          2. Use programs.claudeStatusline with the powerline theme
        '';
      }
    ];
  };
}
