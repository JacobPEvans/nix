# CI Claude Settings Generator
# Pure function that generates Claude Code settings.json for CI validation
# Takes nixpkgs, ai-assistant-instructions, and marketplace inputs
# Returns settings attrset (no derivations, cross-platform compatible)
{
  nixpkgs,
  ai-assistant-instructions,
  marketplaceInputs,
}:
let
  userConfig = import ./user-config.nix;

  # Import unified permissions using the common module
  # Minimal config for CI - only needs lib and placeholder homeDir
  aiCommon = import ../modules/home-manager/ai-cli/common {
    inherit ai-assistant-instructions;
    inherit (nixpkgs) lib;
    config = {
      home.homeDirectory = "/home/user"; # Placeholder for CI
    };
  };
  inherit (aiCommon) permissions formatters;
in
import ./claude-settings.nix {
  inherit (nixpkgs) lib; # Required for pure evaluation
  homeDir = "/home/user"; # Placeholder - CI only validates schema structure
  schemaUrl = userConfig.ai.claudeSchemaUrl;
  permissions = {
    allow = formatters.claude.formatAllowed permissions;
    deny = formatters.claude.formatDenied permissions;
    ask = [ ]; # No ask permissions defined yet
  };
  plugins =
    (import ../modules/home-manager/ai-cli/claude-plugins.nix (
      marketplaceInputs
      // {
        inherit (nixpkgs) lib;
        config = { }; # Unused but required by signature
      }
    )).pluginConfig;
}
