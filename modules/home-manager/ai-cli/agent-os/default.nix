# Agent OS Configuration
#
# Returns home.file entries for Agent OS installation.
# Imported by common.nix for clean separation of AI CLI configs.
#
# Agent OS is a spec-driven development system for AI coding agents.
# It provides standards, workflows, agents, and commands.
#
# Installation structure (~/agent-os/):
#   ├── config.yml           # Nix-generated configuration
#   ├── CHANGELOG.md         # From upstream repo
#   ├── profiles/
#   │   └── default/         # Default profile (agents, commands, standards, workflows)
#   └── scripts/             # Installation and update scripts
#
# Usage:
#   1. Nix creates the base installation at ~/agent-os/
#   2. Run ~/agent-os/scripts/project-install.sh in any project
#   3. This compiles the profile into .claude/ and agent-os/ directories
#
# Reference: https://buildermethods.com/agent-os

{ config, pkgs, agent-os }:

let
  # Import configuration options
  options = import ./options.nix;

  # Import submodules
  configModule = import ./config.nix { inherit pkgs options; };
  scriptsModule = import ./scripts.nix { inherit agent-os; };
  defaultProfile = import ./profiles/default.nix { inherit agent-os; };
in
# Only include files if Agent OS is enabled
if options.enable then
  # Merge all file entries
  configModule.file
  // scriptsModule.files
  // defaultProfile.files
  // {
    # Include CHANGELOG from upstream
    "agent-os/CHANGELOG.md".source = "${agent-os}/CHANGELOG.md";
  }
else
  # Return empty set if disabled
  {}
