# Community Marketplace Plugins
#
# Plugins from community-maintained marketplaces:
# - cc-marketplace: General development tools
# - superpowers-marketplace: Enhanced Claude capabilities
# - awesome-claude-code-plugins: Curated community plugins

_:

{
  enabledPlugins = {
    # CC Marketplace - essential tools
    "analyze-issue@cc-marketplace" = true;
    "create-worktrees@cc-marketplace" = true;
    "python-expert@cc-marketplace" = true; # User actively uses Python

    # Superpowers - comprehensive Claude enhancement suite
    "superpowers@superpowers-marketplace" = true;
    "double-shot-latte@superpowers-marketplace" = true; # User requested restore
    "superpowers-lab@superpowers-marketplace" = true; # User requested add
    "superpowers-developing-for-claude-code@superpowers-marketplace" = true; # User requested restore

    # Awesome Claude Code Plugins - curated collection
    # DevOps automation (CI/CD, cloud infra, monitoring, deployment)
    "devops-automator@awesome-claude-code-plugins" = true;

    # REMOVED - redundant or unused:
    # double-check - unnecessary
    # infrastructure-maintainer - too generic
    # monitoring-observability-specialist - splunk repos don't need this
    # python-expert@awesome-claude-code-plugins - duplicate of cc-marketplace version (same author/content)
    # context7-docs-fetcher@awesome-claude-code-plugins - context7@claude-plugins-official is official MCP version
  };
}
