# Claude Code Statusline - Configuration Module
#
# Merges split configuration files and generates Config.toml.
# This provides a clean, modular approach to statusline configuration.
#
# Files:
#   theme.nix    - Theme selection and custom colors
#   display.nix  - Line layout, components, labels
#   plugins.nix  - Git extended, system info plugins
#   profiles.nix - Context-aware profile switching
#   cache.nix    - Caching and performance
#   advanced.nix - Platform, paths, debugging
{ pkgs, lib, ... }:

let
  # Import split configuration files
  themeConfig = import ./theme.nix;
  displayConfig = import ./display.nix;
  pluginsConfig = import ./plugins.nix;
  profilesConfig = import ./profiles.nix;
  cacheConfig = import ./cache.nix;
  advancedConfig = import ./advanced.nix;

  # Merge all configurations (order matters for overrides)
  mergedConfig = lib.recursiveUpdate (lib.recursiveUpdate (lib.recursiveUpdate
    (lib.recursiveUpdate (lib.recursiveUpdate themeConfig displayConfig)
      pluginsConfig) profilesConfig) cacheConfig) advancedConfig;

  # Generate TOML file from merged config
  tomlFormat = pkgs.formats.toml { };
  configToml = tomlFormat.generate "Config.toml" mergedConfig;

in configToml
