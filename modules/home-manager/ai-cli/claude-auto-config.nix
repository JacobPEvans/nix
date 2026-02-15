# Auto-Claude Configuration Module
# Autonomous maintenance scheduler for Claude Code
# Takes config and lib, returns autoClaude attrset
{ config, lib }:
let
  userConfig = import ../../../lib/user-config.nix;

  # Local repo path - ONLY used for autoClaude (needs writable git for commits)
  # All other ai-assistant-instructions content comes from Nix store (flake input)
  autoClaudeLocalRepoPath = userConfig.ai.instructionsRepo;
in
{
  # Auto-Claude: Scheduled autonomous maintenance
  # ENABLED - Uses Haiku model for cost-efficiency (via per-repo CLAUDE_MODEL env var)
  # Interactive sessions use the default model, autoClaude overrides to Haiku
  # Resource limits: max 10 PRs, max 50 issues, max 1 analysis per item per run
  enable = true;
  repositories = {
    # ai-assistant-instructions: every 4 hours starting at midnight
    # Uses local repo (not Nix store) because autoClaude needs writable git
    # Schedule: 0, 4, 8, 12, 16, 20 (6 times/day)
    ai-assistant-instructions = {
      enabled = true;
      path = autoClaudeLocalRepoPath;
      schedule.times = map (hour: {
        inherit hour;
        minute = 0;
      }) (lib.lists.genList (i: i * 4) 6);
      maxBudget = 20.0;
    };
    # nix config: every 4 hours starting at 1am (offset +1 to prevent concurrent runs)
    # Schedule: 1, 5, 9, 13, 17, 21 (6 times/day)
    nix = {
      enabled = true;
      path = "${config.home.homeDirectory}/.config/nix";
      schedule.times = map (hour: {
        inherit hour;
        minute = 0;
      }) (lib.lists.genList (i: i * 4 + 1) 6);
      maxBudget = 20.0;
    };
    # terraform-proxmox: every 4 hours starting at 2am (offset +2 to prevent concurrent runs)
    # Schedule: 2, 6, 10, 14, 18, 22 (6 times/day)
    terraform-proxmox = {
      enabled = true;
      path = "${config.home.homeDirectory}/git/terraform-proxmox/main";
      schedule.times = map (hour: {
        inherit hour;
        minute = 0;
      }) (lib.lists.genList (i: i * 4 + 2) 6);
      maxBudget = 20.0;
    };
  };

  # Reporting: Twice-daily utilization reports and real-time anomaly alerts
  reporting = {
    enable = true;

    # Scheduled digest reports (8am and 5pm EST)
    scheduledReports = {
      times = [
        "08:00"
        "17:00"
      ]; # 8am and 5pm EST
      slackChannel = ""; # Retrieve from BWS at runtime
    };

    # Real-time anomaly detection
    alerts = {
      enable = true;
      contextThreshold = 90;
      budgetThreshold = 50;
      tokensNoOutput = 50000;
      consecutiveFailures = 2;
    };
  };
}
