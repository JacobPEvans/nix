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

  # OrbStack: Docker & Linux VM manager
  # Data symlink configured in hosts/<host>/home.nix
  programs.orbstack = {
    enable = true;
    dataVolume = {
      enable = true;
      name = "ContainerData";
      apfsContainer = "disk3";
    };
  };
}
