# Third-Party GUI Application Defaults
#
# macOS preferences for third-party GUI applications.
# Uses system.defaults.CustomUserPreferences to set defaults.
#
# Add new app configuration files here and import them below.

{ ... }:

{
  imports = [
    ./orbstack.nix
    ./raycast.nix
  ];

  # Enable OrbStack Docker socket symlink management
  programs.orbstack.enable = true;
}
