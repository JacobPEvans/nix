# Auto-Update Prevention for Nix-Managed Apps
#
# Disables built-in auto-updaters (Sparkle) for macOS apps managed via Nix
# to prevent version conflicts.
#
# Problem:
#   Apps with built-in updaters silently update themselves.
#   On next darwin-rebuild, Nix restores the older version via copyApps,
#   but the app's data was already migrated to the newer schema.
#   Result: "Version mismatch detected" errors and broken apps.
#
# Solution:
#   Use macOS defaults to disable auto-updaters declaratively.
#   This prevents the updater from running at all.
#
# Note: VS Code already handled via programs.vscode settings (no action needed).
# Note: Postman moved to Homebrew cask (greedy = true) — no prevention needed.
#
# To verify settings are applied:
#   defaults read com.luckymarmot.Paw SUEnableAutomaticChecks

_:

{
  system.defaults.CustomUserPreferences = {
    # RapidAPI (formerly Paw) - Disable Sparkle auto-updater
    "com.luckymarmot.Paw" = {
      SUEnableAutomaticChecks = false;
      SUAutomaticallyUpdate = false;
      SUAllowsAutomaticUpdates = false; # Sparkle-specific
    };
  };
}
