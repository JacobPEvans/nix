# Home-Manager Default Settings
#
# Shared home-manager configuration used across all hosts.
# Import this in flake.nix modules sections.
#
# Usage in flake.nix:
#   let hmDefaults = import ./lib/home-manager-defaults.nix; in
#   { home-manager = hmDefaults; }

{
  # Use nixpkgs from the system flake (not a separate instance)
  # This inherits nixpkgs.config.allowUnfree from modules/darwin/common.nix
  useGlobalPkgs = true;

  # Install user packages to /etc/profiles instead of ~/.nix-profile
  useUserPackages = true;

  # Remove conflicting files so home-manager can place its symlinks.
  # Nix store is the source of truth — all managed files are recoverable via
  # `home-manager generations`. No backups, no .backup file pollution.
  backupCommand = "rm -rf";
}
