# Claude Code Statusline - Plugins Configuration
#
# Built-in plugins: git_extended, system_info, weather
# Custom plugins can be loaded from plugin_dirs.
{
  plugins = {
    # Plugin system
    enabled = true;
    auto_discovery = true;
    plugin_dirs = [ "~/.config/claude-code-statusline/plugins" ];
    timeout_per_plugin = "10s";

    # Git Extended Plugin - shows additional git info
    git_extended = {
      enabled = true;
      show_stash_count = true; # Number of stashed changes
      show_ahead_behind = true; # Commits ahead/behind remote
      show_branch_age = true; # Age of current branch
    };

    # System Info Plugin - shows system metrics
    system_info = {
      enabled = true;
      show_load_average = true; # CPU load average
      show_memory_usage = true; # RAM usage
      show_disk_usage = true; # Disk space
    };

    # Weather Plugin - DISABLED (requires API key)
    weather = {
      enabled = false;
      api_key = "";
      location = "auto";
      units = "metric";
    };
  };
}
