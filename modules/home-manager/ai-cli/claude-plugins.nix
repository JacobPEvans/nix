# Claude Code Plugins Configuration
#
# Manages official Anthropic plugins and commands from:
# - anthropics/claude-code (plugin marketplace)
# - anthropics/claude-cookbooks (commands and agents)
#
# Strategy:
# 1. Configure plugin marketplaces and enabled plugins (modular structure)
# 2. Copy useful commands/agents from claude-cookbooks to ~/.claude/
#
# Plugin Configuration:
# - Marketplaces and plugins are defined in modules/home-manager/ai-cli/claude/plugins/
# - Organized by category: official, community, infrastructure, development, business
# - See claude/plugins/default.nix for the complete structure
#
# Migration Notes:
# - Removed: "review-pr-ci" - replaced by code-review plugin (/code-review)

{
  lib,
  claude-cookbooks,
  claude-code-workflows,
  claude-skills,
  jacobpevans-cc-plugins,
  claude-plugins-official,
  anthropic-skills,
  superpowers-marketplace,
  obsidian-skills,
  obsidian-visual-skills,
  cc-marketplace,
  cc-dev-tools,
  claude-code-plugins-plus,
  lunar-claude,
  bills-claude-skills,
  wakatime,
  ...
}:

let
  # Import modular plugin configuration
  # Pass all marketplace flake inputs for Nix-managed symlinks
  pluginModules = import ./claude/plugins/default.nix {
    inherit
      lib
      claude-code-workflows
      claude-skills
      jacobpevans-cc-plugins
      claude-plugins-official
      anthropic-skills
      superpowers-marketplace
      ;
  };

  # Map marketplace names to flake inputs for Nix-managed symlinks
  # Keys MUST match marketplace.nix keys exactly
  flakeInputMap = {
    "jacobpevans-cc-plugins" = jacobpevans-cc-plugins;
    "claude-plugins-official" = claude-plugins-official;
    "superpowers-marketplace" = superpowers-marketplace;
    "anthropic-agent-skills" = anthropic-skills; # Marketplace name differs from flake input name
    "claude-code-workflows" = claude-code-workflows;
    "claude-skills" = claude-skills;
    "obsidian-skills" = obsidian-skills;
    "obsidian-visual-skills" = obsidian-visual-skills;
    "cc-marketplace" = cc-marketplace;
    "cc-dev-tools" = cc-dev-tools;
    "claude-code-plugins-plus" = claude-code-plugins-plus;
    "lunar-claude" = lunar-claude;
    "bills-claude-skills" = bills-claude-skills;
    "wakatime" = wakatime;
  };

  # Enrich marketplaces with flakeInput attributes for Nix symlinks
  enrichedMarketplaces = lib.mapAttrs (
    name: marketplace:
    let
      flakeInput = flakeInputMap.${name} or null;
    in
    marketplace // lib.optionalAttrs (flakeInput != null) { inherit flakeInput; }
  ) pluginModules.marketplaces;

  # Commands from claude-cookbooks to install globally
  # These are copied directly to ~/.claude/commands/
  cookbookCommands = [
    "review-issue" # GitHub issue review
    "notebook-review" # Jupyter notebook review
    "model-check" # Model validation
    "link-review" # Link verification
  ];

  # Agents from claude-cookbooks to install globally
  # These are copied to ~/.claude/agents/
  cookbookAgents = [
    "code-reviewer" # Senior code review agent
  ];
in
{
  # Plugin marketplace and enabled plugins configuration
  # Merged into settings.json by claude.nix
  pluginConfig = {
    marketplaces = enrichedMarketplaces;
    inherit (pluginModules) enabledPlugins;
  };

  # Home-manager file entries for commands and agents
  # These copy files from the claude-cookbooks repo to ~/.claude/
  #
  # Helper function to reduce duplication
  # Creates file entries for a given type (command/agent) from a list of names
  files =
    let
      mkCookbookFileEntries =
        type: names:
        builtins.listToAttrs (
          map (name: {
            name = ".claude/${type}s/${name}.md";
            value = {
              source = "${claude-cookbooks}/.claude/${type}s/${name}.md";
            };
          }) names
        );
    in
    mkCookbookFileEntries "command" cookbookCommands // mkCookbookFileEntries "agent" cookbookAgents;
}
