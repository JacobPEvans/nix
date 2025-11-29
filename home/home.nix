{ config, pkgs, ... }:

let
  # VS Code settings imports
  vscodeGeneralSettings = import ./vscode-settings.nix { inherit config; };
  vscodeGithubCopilotSettings = import ./vscode-copilot-settings.nix { };

  # AI CLI configuration imports (home.file entries)
  claudeFiles = import ./ai-cli/claude.nix { inherit config pkgs; };
in
{
  home.stateVersion = "24.05";

  # ==========================================================================
  # VS Code
  # ==========================================================================
  # Settings from vscode-settings.nix and vscode-copilot-settings.nix
  # WARNING: Will overwrite local VS Code settings
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "editor.formatOnSave" = true;
    } // vscodeGeneralSettings // vscodeGithubCopilotSettings;
  };

  # ==========================================================================
  # Shell (zsh)
  # ==========================================================================
  programs.zsh = {
    enable = true;

    shellAliases = {
      # Directory listing
      ll = "ls -ahlFG -D '%Y-%m-%d %H:%M:%S'";
      llt = "ls -ahltFG -D '%Y-%m-%d %H:%M:%S'";
      lls = "ls -ahlsFG -D '%Y-%m-%d %H:%M:%S'";

      # Docker
      dps = "docker ps -a";
      dcu = "docker compose up -d";
      dcd = "docker compose down";

      # Nix
      d-r = "sudo darwin-rebuild switch --flake ~/.config/nix#default";

      # Python (use macOS built-in)
      python = "python3";

      # Tar (macOS-friendly)
      tgz = "tar --disable-copyfile --exclude='.DS_Store' -czf";
    };

    # Source modular shell functions
    # NOTE: session-logging.zsh MUST be last (takes over terminal)
    initContent = ''
      source ${./zsh/git-functions.zsh}
      source ${./zsh/docker-functions.zsh}
      source ${./zsh/macos-setup.zsh}
      source ${./zsh/session-logging.zsh}
    '';
  };

  # ==========================================================================
  # Home Manager
  # ==========================================================================
  programs.home-manager.enable = true;

  # ==========================================================================
  # AI CLI Configurations
  # ==========================================================================
  # Claude Code configuration in ai-cli/claude.nix
  # Permission definitions in claude-permissions.nix and claude-permissions-ask.nix
  home.file = claudeFiles;
}
