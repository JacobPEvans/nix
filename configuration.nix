{ pkgs, lib, ... }:
{
  # Nix configuration ------------------------------------------------------------------------------

  system.stateVersion = 6;

  nix.binaryCaches = [
    "https://cache.nixos.org/"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.trustedUsers = [
    "@admin"
  ];

  # 2025-10-25
  #  Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  #users.${username} = {
  users = {
    users.jevans = {
      #home = "/Users/${username}";
      home = "/Users/jevans";
      #name = "${username}";
      name = "jevans";
    };
  };

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    terminal-notifier
  ];

  programs.nix-index.enable = true;

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Add ability to used TouchID for sudo authentication
  #security.pam.enableSudoTouchIdAuth = true;
  security.pam.services.sudo_local.touchIdAuth = true;
}
