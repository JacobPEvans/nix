# Powerline Theme - Claude Code Statusline
#
# Multi-line statusline with powerline-style graphics powered by claude-powerline.
# Uses npx to run the @owloops/claude-powerline Node.js package.
#
# Features:
# - Powerline-style arrow separators
# - Multi-line layout
# - Enhanced git status display
# - 6 customizable color themes
#
# Repository: https://github.com/Owloops/claude-powerline
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.claudeStatusline;
  powerlineStyle = cfg.powerline.style;
in
{
  config = lib.mkIf (cfg.enable && cfg.theme == "powerline") {
    # Create statusline-command.sh that uses npx to run claude-powerline
    home.file.".claude/statusline-command.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Claude Powerline statusline wrapper
        # Uses npx to run @owloops/claude-powerline with the configured theme

        # Pass the theme as an argument if not default
        ${
          if powerlineStyle == "default" then
            ''${pkgs.nodejs}/bin/npx --yes @owloops/claude-powerline "$@"''
          else
            ''${pkgs.nodejs}/bin/npx --yes @owloops/claude-powerline --theme=${powerlineStyle} "$@"''
        }
      '';
    };
  };
}
