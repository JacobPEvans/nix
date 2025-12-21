# Unified AI CLI Permission Definitions
#
# Single source of truth for command permissions across all AI tools.
# Each tool uses formatters to convert these to their specific format.
#
# STRUCTURE:
# - allow: Auto-approved commands (from ai-assistant-instructions)
# - deny: Permanently blocked, catastrophic operations
# - directories: Shared directory trust configuration
# - toolSpecific: Non-shell tool identifiers
#
# TOOL FORMATS (applied by formatters.nix):
# - Claude: Bash(cmd:*), Read(**), etc.
# - Gemini: ShellTool(cmd), ReadFileTool, etc.
# - Copilot: shell(cmd) patterns (runtime flags)
# - OpenCode: TBD

{
  lib,
  config,
  ai-assistant-instructions,
  ...
}:

let
  homeDir = config.home.homeDirectory;

  # Read all JSON files from a directory and extract commands
  readPermissionDir =
    dir:
    let
      files = builtins.readDir dir;
      jsonFiles = lib.filterAttrs (n: v: v == "regular" && lib.hasSuffix ".json" n) files;
      readJson = name: (builtins.fromJSON (builtins.readFile "${dir}/${name}")).commands or [ ];
    in
    lib.flatten (map readJson (builtins.attrNames jsonFiles));

  # Paths to permission directories in ai-assistant-instructions
  allowDir = "${ai-assistant-instructions}/agentsmd/permissions/allow";
  denyDir = "${ai-assistant-instructions}/agentsmd/permissions/deny";
  domainsFile = "${ai-assistant-instructions}/agentsmd/permissions/domains/webfetch.json";

  # Read deny file for both commands and patterns
  denyDangerousFile = "${denyDir}/dangerous.json";
  denyDangerousJson = builtins.fromJSON (builtins.readFile denyDangerousFile);

in
{
  # Auto-approved commands from ai-assistant-instructions
  allow = readPermissionDir allowDir;

  # Denied commands from ai-assistant-instructions
  # Combine all deny/*.json files into a flat list
  deny = readPermissionDir denyDir;

  # WebFetch domains
  webfetchDomains = (builtins.fromJSON (builtins.readFile domainsFile)).domains;

  # File patterns to deny (for Claude Read tool)
  # These come from dangerous.json's "patterns" field
  denyPatterns = denyDangerousJson.patterns or [ ];

  # Trusted directories (local config)
  directories = {
    development = [
      "${homeDir}/projects"
      "${homeDir}/repos"
      "${homeDir}/workspace"
      "${homeDir}/src"
      "${homeDir}/dev"
      "${homeDir}/git"
    ];

    config = [
      "${homeDir}/.config/nix"
      "${homeDir}/.dotfiles"
      "${homeDir}/.config"
      "${homeDir}/.claude"
    ];

    home = [ homeDir ];
  };

  # Tool-specific identifiers (non-shell, built-in tools)
  # NOTE: These are BUILT-IN tools (like ReadFileTool), not shell commands.
  # The attribute names here (builtin) refer to the tool's built-in capabilities,
  # not to be confused with the JSON key "tools.core" which restricts tool usage.
  toolSpecific = {
    # Gemini built-in tools (non-shell) - maps to tools.allowed, NOT tools.core
    gemini.builtin = [
      "ReadFileTool"
      "GlobTool"
      "GrepTool"
      "WebFetchTool"
    ];

    # Claude built-in tools (non-shell)
    # NOTE: Deny rules (denyRead) take precedence over allow rules (builtin)
    # as enforced by Claude Code at runtime when it evaluates these patterns,
    # not by this Nix configuration itself. Even though Read(**) allows reading
    # any file, the denyRead patterns will block sensitive files (.env, SSH keys,
    # etc.) when Claude Code processes the permission lists.
    claude = {
      # Core built-in tools with glob patterns
      builtin = [
        "Read(**)"
        "Glob(**)"
        "Grep(**)"
        "WebSearch"
        "TodoWrite"
        "TodoRead"
        "SlashCommand(**)"
      ];

      # WebFetch with allowed domains (dynamically generated from ai-assistant-instructions)
      # This will be populated by formatters.nix using webfetchDomains

      # Special read patterns
      read = [
        "Read(/nix/store/**)"
      ];

      # Deny patterns for sensitive files (Claude-specific Read tool)
      # Populated from ai-assistant-instructions deny/dangerous.json patterns field
      # This will be transformed by formatters.nix to Read(...) format
    };
  };
}
