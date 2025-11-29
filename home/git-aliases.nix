# Git Aliases (Cross-Platform)
#
# Git command aliases (used as: git st, git lg, etc.)
# Imported by home.nix for programs.git.aliases

{
  # Status & info
  st = "status -sb";              # Short status with branch info
  ll = "log --oneline -20";       # Quick log view
  lg = "log --graph --oneline --decorate --all";  # Visual branch graph
  last = "log -1 HEAD --stat";    # Show last commit with stats

  # Branch operations
  co = "checkout";
  cob = "checkout -b";            # Create and checkout branch
  br = "branch -vv";              # Verbose branch list with tracking

  # Staging & commits
  aa = "add --all";               # Stage everything
  cm = "commit -m";               # Quick commit with message
  ca = "commit --amend";          # Amend last commit
  can = "commit --amend --no-edit";  # Amend without changing message

  # Sync operations
  pl = "pull --rebase";           # Pull with rebase
  pf = "push --force-with-lease"; # Safe force push

  # Diff shortcuts
  df = "diff";
  dfs = "diff --staged";          # Diff staged changes
  dfn = "diff --name-only";       # Just show changed files

  # Undo operations
  unstage = "reset HEAD --";      # Unstage files
  undo = "reset --soft HEAD~1";   # Undo last commit, keep changes staged

  # Stash shortcuts
  ss = "stash save";
  sp = "stash pop";
  sl = "stash list";

  # Cleanup
  cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
}
