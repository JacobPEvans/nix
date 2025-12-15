# Robbyrussell Theme - Claude Code Statusline
#
# Simple, clean statusline theme inspired by the robbyrussell oh-my-zsh theme.
# This is the current default implementation, extracted from the original statusline.nix.
#
# Features:
# - Lightweight and fast
# - Single-line display optimized for SSH/mobile
# - Git integration
# - Cost tracking via ccusage
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.claudeStatusline;

  # Build claude-code-statusline package from source
  mkStatuslinePackage =
    source:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "claude-code-statusline";
      version = "2.1.0";
      src = source;

      nativeBuildInputs = [ pkgs.makeWrapper ];
      # Note: NOT including coreutils - script expects macOS stat, not GNU stat
      buildInputs = [
        pkgs.bash
        pkgs.jq
        pkgs.git
      ];

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/claude-code-statusline $out/bin

        # Copy all source files (statusline.sh, lib/, examples/)
        cp -r . $out/share/claude-code-statusline/

        # Create wrapper - add bash/jq/git/bun (for ccusage via bunx)
        # The statusline script uses 'bunx ccusage' for cost tracking
        makeWrapper $out/share/claude-code-statusline/statusline.sh $out/bin/claude-code-statusline \
          --prefix PATH : ${
            lib.makeBinPath [
              pkgs.bash
              pkgs.jq
              pkgs.git
              pkgs.bun
            ]
          } \
          --set STATUSLINE_HOME $out/share/claude-code-statusline

        chmod +x $out/bin/claude-code-statusline
        runHook postInstall
      '';

      meta = with lib; {
        description = "Modular multi-line statusline for Claude Code";
        homepage = "https://github.com/rz1989s/claude-code-statusline";
        license = licenses.mit;
        platforms = platforms.all;
        mainProgram = "claude-code-statusline";
      };
    };

in
{
  config = lib.mkIf (cfg.enable && cfg.theme == "robbyrussell") (
    let
      # Get source from legacy statusLine.enhanced.source for backward compatibility
      # TODO: This should eventually be moved to claudeStatusline.source
      legacyCfg = config.programs.claude.statusLine.enhanced;
      source = legacyCfg.source;

      statuslinePackage = mkStatuslinePackage source;

      # Config files - full (local) and mobile (SSH)
      configFull =
        if legacyCfg.configFile != null then legacyCfg.configFile else "${source}/examples/Config.toml";

      configMobile = legacyCfg.mobileConfigFile;
    in
    {
      # Install the statusline package
      home.packages = [ statuslinePackage ];

      # Deploy config files
      home.file = {
        # Full config (always deployed)
        ".claude/statusline/config-full.toml".source = configFull;
      }
      // lib.optionalAttrs (configMobile != null) {
        # Mobile config (only if specified)
        ".claude/statusline/config-mobile.toml".source = configMobile;
      };
    }
  );
}
