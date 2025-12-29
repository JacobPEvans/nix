# Crush Auto-Approved Commands (ALLOW List)
#
# Uses unified permission definitions from ai-cli/common/permissions.nix
# with Crush-specific formatting via formatters.nix.
#
# SINGLE SOURCE OF TRUTH:
# Command definitions are in ai-cli/common/permissions.nix
# This file only applies Crush-specific formatting.

{
  config,
  lib,
  ...
}:

let
  # Import unified permissions and formatters
  aiCommon = import ../ai-cli/common { inherit lib config; };
  inherit (aiCommon) permissions formatters;

in
{
  # Export allowedCommands list (auto-approved commands)
  # Crush uses shell_allowlist in permissions config
  allowedCommands = formatters.crush.formatShellCommands (
    formatters.utils.flattenCommands permissions.allow
  );
}
