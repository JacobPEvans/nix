# GitHub Copilot CLI Trusted Directories (ALLOW List)
#
# This file defines directory trust for GitHub Copilot CLI (config.json).
#
# FILE STRUCTURE:
# - copilot-permissions-allow.nix (this file) - Trusted directories
# - copilot-permissions-ask.nix - Commands that would require confirmation (reference only)
# - copilot-permissions-deny.nix - Recommended --deny-tool flags (reference)
#
# NOTE: These permission lists are kept in sync across Claude, Gemini, and Copilot.
# Currently each AI has separate files. Future improvement: DRY refactor to share
# common command lists across all AI tools.
#
# COPILOT CLI PERMISSION MODEL:
# - trusted_folders: List of directories where Copilot can operate (config.json)
# - --allow-tool / --deny-tool: CLI flags for runtime permission control
#
# NOTE: Unlike Claude Code and Gemini CLI, Copilot CLI's config.json only
# contains trusted_folders. Permission controls are managed via command-line
# flags (--allow-tool, --deny-tool) which must be specified at runtime.
#
# PRINCIPLE OF LEAST PRIVILEGE:
# - Only trust directories you actively work in
# - Use --allow-tool and --deny-tool flags for fine-grained control
# - Default behavior requires approval for each tool execution

{ config, ... }:

let
  # User home directory
  homeDir = config.home.homeDirectory;

  # Home directory access
  # Allows Copilot to operate anywhere under home directory
  # Note: Explicit subdirectories are not needed when home dir is trusted
  trustedHomeDir = [
    homeDir
  ];

in
{
  # Export trusted_folders list for config.json
  # Home dir grants access to all subdirectories
  trusted_folders = trustedHomeDir;
}
