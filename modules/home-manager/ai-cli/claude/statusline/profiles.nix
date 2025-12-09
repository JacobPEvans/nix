# Claude Code Statusline - Profiles & Conditional Configuration
#
# Context-aware configuration that auto-switches based on:
# - Time of day (work hours)
# - Git repository context
{
  # Configuration profiles
  profiles = {
    enabled = true;
    default_profile = "default";
    auto_switch = true;

    # Work profile - focused, cost-aware
    work = {
      theme = "classic";
      show_cost_tracking = true;
      show_reset_info = true;
      mcp_timeout = "10s";
    };

    # Personal profile - relaxed
    personal = {
      theme = "catppuccin";
      show_cost_tracking = false;
      show_reset_info = false;
      mcp_timeout = "10s";
    };

    # Demo profile - minimal
    demo = {
      theme = "garden";
      show_cost_tracking = false;
      show_commits = false;
    };
  };

  # Conditional configuration triggers
  conditional = {
    enabled = true;

    # Work hours - auto-switch profiles by time
    work_hours = {
      enabled = true;
      start_time = "09:00";
      end_time = "17:00";
      timezone = "local";
      work_profile = "work";
      off_hours_profile = "personal";
    };

    # Git repository context - auto-switch by repo
    git_context = {
      enabled = true;
      work_repos = [ ]; # Add paths like "/Users/you/work/*"
      personal_repos = [ ]; # Add paths like "/Users/you/personal/*"
    };
  };
}
