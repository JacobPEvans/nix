# Unified AI CLI Allowed Commands
#
# Auto-approved commands organized by category.
# Imported by permissions.nix - do not use directly.
#
# ORGANIZATION:
# Large permission lists split into category-specific files in allow/ directory.
# This keeps each file under 200 lines and makes it easier to find/update commands.
#
# CATEGORIES:
# - git.nix: Git and GitHub CLI operations
# - nix.nix: Nix package manager and Homebrew
# - languages.nix: Python, Node.js, Rust toolchains
# - containers.nix: Docker and Kubernetes
# - cloud.nix: AWS, Terraform, Terragrunt
# - tools.nix: Database, version managers, dev environments
# - system.nix: File operations, system info, network

_:

let
  # Dynamically import all .nix files from the allow/ directory
  # This eliminates the need to manually list each category file
  allowDir = ./allow;

  # Get all files in the allow directory
  files = builtins.attrNames (builtins.readDir allowDir);

  # Filter for only .nix files and import them
  nixFiles = builtins.filter (f: builtins.match ".*\\.nix$" f != null) files;
  modules = builtins.map (file: import (allowDir + "/${file}") { }) nixFiles;
in

# Merge all category modules into a single attribute set
# foldl' processes the list left-to-right, merging each module's attributes
builtins.foldl' (acc: attrs: acc // attrs) { } modules
