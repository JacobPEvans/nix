# Claude Code Statusline - Display Configuration
#
# Line layout, components, labels, and formatting.
# Available components (18 total):
#   Repository: repo_info, commits, submodules, git_stats, version_info
#   Model/Session: model_info, cost_repo, cost_live, reset_timer
#   Cost Analytics: cost_monthly, cost_weekly, cost_daily, cost_period
#   Block Metrics: burn_rate, token_usage, cache_efficiency, block_projection
#   System: mcp_status, time_display
#   Spiritual: prayer_times (disabled)
{
  # Feature toggles
  features = {
    show_commits = true;
    show_version = true;
    show_submodules = true;
    show_mcp_status = true;
    show_cost_tracking = true;
    show_reset_info = true;
    show_session_info = true;
    show_prayer_times = false;
    show_hijri_date = false;
  };

  # Display configuration
  display = {
    # Number of lines (1-9)
    lines = 4;

    # Line 1: Repository Core
    line1 = {
      components = [
        "repo_info"
        "commits"
        "submodules"
        "version_info"
        "time_display"
      ];
      separator = " │ ";
      show_when_empty = true;
    };

    # Line 2: Model + Cost Analytics
    line2 = {
      components = [
        "model_info"
        "cost_repo"
        "cost_monthly"
        "cost_weekly"
        "cost_daily"
        "cost_live"
      ];
      separator = " │ ";
      show_when_empty = true;
    };

    # Line 3: Block Metrics
    line3 = {
      components = [
        "burn_rate"
        "token_usage"
        "cache_efficiency"
        "block_projection"
      ];
      separator = " │ ";
      show_when_empty = true;
    };

    # Line 4: System Status & Timer
    line4 = {
      components = [ "mcp_status" "reset_timer" ];
      separator = " │ ";
      show_when_empty = true;
    };

    # Lines 5-9: Available for future expansion
    line5 = {
      components = [ ];
      separator = " │ ";
      show_when_empty = false;
    };
    line6 = {
      components = [ ];
      separator = " │ ";
      show_when_empty = false;
    };
    line7 = {
      components = [ ];
      separator = " │ ";
      show_when_empty = false;
    };
    line8 = {
      components = [ ];
      separator = " │ ";
      show_when_empty = false;
    };
    line9 = {
      components = [ ];
      separator = " │ ";
      show_when_empty = false;
    };

    # Formats
    time_format = "%H:%M";
    date_format = "%Y-%m-%d";
    date_format_compact = "%Y%m%d";
  };

  # Display labels
  labels = {
    commits = "Commits:";
    repo = "REPO";
    monthly = "30DAY";
    weekly = "7DAY";
    daily = "DAY";
    mcp = "MCP";
    version_prefix = "ver";
    submodule = "SUB:";
    session_prefix = "S:";
    live = "LIVE";
    reset = "RESET";
  };

  # Error/fallback messages
  messages = {
    no_ccusage = "No ccusage";
    ccusage_install = "Install ccusage for cost tracking";
    no_active_block = "No active block";
    mcp_unknown = "unknown";
    mcp_none = "none";
    unknown_version = "?";
    no_submodules = "--";
  };

  # Timeouts
  timeouts = {
    mcp = "10s";
    version = "10s";
    ccusage = "10s";
    prayer = "10s";
  };
}
