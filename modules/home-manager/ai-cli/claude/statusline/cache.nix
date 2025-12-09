# Claude Code Statusline - Cache Configuration
#
# Caching settings for performance optimization.
# Cache isolation prevents contamination between repositories.
{
  cache = {
    base_directory = "auto";
    enable_universal_caching = true;
    enable_statistics = true;
    enable_corruption_detection = true;
    cleanup_stale_files = true;
    migrate_legacy_cache = true;

    # Cache durations (seconds, or "session" for session-wide)
    durations = {
      command_exists = "session";
      system_info = 86400; # 24 hours
      claude_version = 21600; # 6 hours
      git_config = 3600; # 1 hour
      git_submodules = 300; # 5 minutes
      git_branches = 30;
      git_status = 10;
      git_current_branch = 10;
      mcp_server_list = 120; # 2 minutes
      prayer_data = 3600;
      hijri_date = 3600;
      location_data = 604800; # 7 days
      directory_info = 5;
      file_operations = 2;
    };

    # Performance and reliability
    performance = {
      max_lock_retries = 10;
      lock_retry_delay_ms = "100-500";
      atomic_write_timeout = 10;
      cache_cleanup_interval = 300;
      max_cache_age_hours = 168; # 7 days
    };

    # Security and integrity
    security = {
      directory_permissions = "700";
      file_permissions = "600";
      enable_checksums = true;
      validate_on_read = true;
      secure_temp_files = true;
      instance_isolation = true;
    };

    # Instance isolation - prevent cache contamination between repos
    isolation = {
      mode = "repository";
      mcp = "repository";
      git = "repository";
      cost = "shared"; # Cost tracking is user-wide
      session = "repository";
      prayer = "shared";
      hijri = "shared";
    };

    # Legacy compatibility
    legacy = {
      version_duration = 3600;
      version_file = "/tmp/.claude_version_cache";
    };
  };
}
