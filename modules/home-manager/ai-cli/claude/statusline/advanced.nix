# Advanced Theme - Claude Code Statusline
#
# Full-featured statusline with system information and theming.
# Uses the claude-code-statusline repository with 18+ color themes.
#
# Features:
# - System information display (CPU, memory, disk)
# - 18+ customizable color themes (gruvbox, nord, dracula, etc.)
# - Extended git information
# - Performance metrics
# - Context-aware segments
{
  config,
  lib,
  pkgs,
  claude-code-statusline,
  ...
}:

let
  cfg = config.programs.claudeStatusline;
  advancedCfg = cfg.advanced;

  # Import shared package builder
  inherit (import ./package.nix { inherit lib pkgs; }) mkStatuslinePackage;
in
{
  config = lib.mkIf (cfg.enable && cfg.theme == "advanced") (
    let
      statuslinePackage = mkStatuslinePackage claude-code-statusline;

      # Generate config file with selected theme
      configFile = pkgs.writeText "claude-statusline-advanced.toml" ''
        # Advanced Claude Code Statusline Configuration
        # Generated from Nix configuration
        # Theme: ${advancedCfg.theme}

        [theme]
        name = "${advancedCfg.theme}"

        [display]
        show_system_info = ${lib.boolToString advancedCfg.showSystemInfo}

        # Additional configuration from claude-code-statusline examples
        # Uses the repository's theme definitions
      '';
    in
    {
      # Install the statusline package
      home.packages = [ statuslinePackage ];

      # Deploy config file
      home.file.".claude/statusline/config-full.toml".source = configFile;
    }
  );
}
