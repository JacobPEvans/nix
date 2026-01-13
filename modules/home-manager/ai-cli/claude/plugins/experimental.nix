# Experimental Plugins
#
# WARNING: Experimental plugins may have autonomous behavior
#
# CRITICAL: Plugin Reference Format
# ============================================================================
# Format: "plugin-name@marketplace-name"
#
# The marketplace-name MUST match the key in marketplaces.nix, which MUST
# match the `name` field from the marketplace's .claude-plugin/marketplace.json
#
# How to verify: See docs/TESTING-MARKETPLACES.md
# ============================================================================

_:

{
  enabledPlugins = {
    # ========================================================================
    # Autonomous Iteration (DISABLED - plugin removed from marketplace)
    # ========================================================================
    # Ralph-wiggum was removed from claude-plugins-official
    # If restored upstream, re-enable here
    "ralph-wiggum@claude-plugins-official" = false;
  };
}
