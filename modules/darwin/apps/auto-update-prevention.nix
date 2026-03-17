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
# Example (Sparkle-based auto-updater):
#   "com.example.AppName" = {
#     SUEnableAutomaticChecks = false;
#     SUAutomaticallyUpdate = false;
#   };
#
# Note: VS Code already handled via programs.vscode settings (no action needed).
# Note: Postman moved to Homebrew cask (greedy = true) — no prevention needed.
# Note: Paw (RapidAPI) defaults-based prevention removed — app still installed via Nix,
#   but runs in a macOS sandbox container so `defaults write` cannot reach its preferences domain.

_:

{
  system.defaults.CustomUserPreferences = {
    # Add apps here as needed. See header example for the Sparkle pattern.
  };
}
