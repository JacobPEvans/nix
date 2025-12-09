# Claude Code Statusline - Advanced Settings
#
# Platform, compatibility, paths, performance tuning, and debugging.
{
  # Advanced behavior
  advanced = {
    warn_missing_deps = false;
    debug_mode = false;
    performance_mode = true;
    strict_validation = true;
  };

  # Bash compatibility
  compatibility = {
    auto_detect_bash = true;
    enable_compatibility_mode = true;
    compatibility_warnings = true;
    bash_path = "";
  };

  # Platform-specific settings
  platform = {
    prefer_gtimeout = true;
    use_gdate = false;
    color_support_level = "full";
  };

  # Path configurations
  paths = {
    temp_dir = "/tmp";
    config_dir = "~/.config/claude-code-statusline";
    cache_dir = "~/.cache/claude-code-statusline";
    log_file = "~/.cache/claude-code-statusline/statusline.log";
  };

  # Performance tuning
  performance = {
    parallel_data_collection = true;
    max_concurrent_operations = 3;
    git_operation_timeout = "10s";
    network_operation_timeout = "10s";
    enable_smart_caching = true;
    cache_compression = false;
  };

  # Debugging & logging
  debug = {
    log_level = "error";
    log_config_loading = false;
    log_theme_application = false;
    log_validation_details = false;
    benchmark_performance = false;
    export_debug_info = false;
  };
}
