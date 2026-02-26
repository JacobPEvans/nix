# Granola Watcher Options
#
# Implementation: ../granola-watcher.nix
{ lib, ... }:

{
  options.programs.claude.granolaWatcher = {
    enable = lib.mkEnableOption "Granola file watcher for automatic meeting migration";

    vaultPath = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the Obsidian vault containing granola/ folder";
      example = "/Users/<username>/obsidian/<vault-name>";
    };

    maxBudgetPerRun = lib.mkOption {
      type = lib.types.float;
      default = 3.0;
      description = "Maximum USD per Claude invocation (appropriate for 5-file batches)";
    };

    dailyBudgetCap = lib.mkOption {
      type = lib.types.float;
      default = 20.0;
      description = "Maximum cumulative USD per calendar day (raised to clear backlogs faster; lower to 10 once caught up)";
    };

    batchSize = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Number of Granola files to process per Claude invocation";
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = "sonnet";
      description = "Claude model for headless migration (sonnet, haiku, or opus)";
    };

    maxTurns = lib.mkOption {
      type = lib.types.int;
      default = 80;
      description = "Maximum conversation turns per Claude invocation";
    };

    debounce = lib.mkOption {
      type = lib.types.str;
      default = "30s";
      description = "Delay after last file change before triggering migration";
    };
  };
}
