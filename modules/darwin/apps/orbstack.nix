# OrbStack Configuration Module
#
# Manages OrbStack Docker socket symlink configuration.
# OrbStack is a lightweight Docker & Linux VM manager for macOS.
#
# The Docker socket symlink allows tools expecting the default Docker
# socket location (/var/run/docker.sock) to work with OrbStack.
#
# Usage:
#   programs.orbstack.enable = true;
#   programs.orbstack.dockerSocketSymlink = true;  # default
#
# Note: OrbStack's helper tool can also create this symlink via its GUI.
# This module ensures the symlink exists declaratively after rebuilds.

{ lib, config, ... }:

let
  cfg = config.programs.orbstack;

  # TODO: Refactor to receive userConfig via specialArgs instead of import
  # See: https://github.com/JacobPEvans/nix/issues/XX
  userConfig = import ../../../lib/user-config.nix;

  # Script path for Docker socket setup
  setupScript = ./scripts/setup-docker-socket.sh;
in {
  options.programs.orbstack = {
    enable = lib.mkEnableOption "OrbStack configuration";

    dockerSocketSymlink = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Create /var/run/docker.sock symlink pointing to OrbStack's socket.
        This allows tools expecting the default Docker socket to work.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Create Docker socket symlink on system activation
    # This runs with root privileges during darwin-rebuild switch
    system.activationScripts.postActivation.text = lib.mkIf cfg.dockerSocketSymlink ''
      ${setupScript} "${userConfig.user.homeDir}"
    '';
  };
}
