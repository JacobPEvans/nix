# Agent OS Scripts
#
# Symlinks Agent OS installation scripts from the flake input to ~/agent-os/scripts/
# These scripts handle project installation and updates.
#
# Scripts included:
#   - common-functions.sh: Shared utility functions
#   - create-profile.sh: Create custom profiles
#   - project-install.sh: Install Agent OS to a project
#   - project-update.sh: Update Agent OS in a project
#
# Note: base-install.sh is excluded as Nix handles base installation
#
# Usage: Run ~/agent-os/scripts/project-install.sh in any project directory

{ agent-os }:

let
  # Scripts to symlink (excluding base-install.sh which Nix replaces)
  scripts = [
    "common-functions.sh"
    "create-profile.sh"
    "project-install.sh"
    "project-update.sh"
  ];

  # Generate file entries for each script
  mkScriptEntry = name: {
    name = "agent-os/scripts/${name}";
    value = {
      source = "${agent-os}/scripts/${name}";
      executable = true;
    };
  };
in
{
  # Home-manager file entries for scripts
  files = builtins.listToAttrs (map mkScriptEntry scripts);
}
