# Git utility functions

# gw-a - Create worktree with new branch and cd into it
# Usage: gw-a <branch-name>
# Example: gw-a feat/my-feature
#
# Works with bare repo structure:
#   ~/git/<repo>/       (bare repo)
#   ├── main/           (worktree)
#   ├── feat/branch/    (worktree)
#
# Creates worktree at ~/git/<repo>/<branch-name>/ from origin/main
gw-a() {
  if [[ -z "$1" ]]; then
    echo "Usage: gw-a <branch-name>"
    echo "Example: gw-a feat/my-feature"
    return 1
  fi

  local branch="$1"

  # Find the bare repo root (common dir for worktrees)
  local bare_root
  bare_root=$(git rev-parse --git-common-dir 2>/dev/null)

  if [[ -z "$bare_root" || "$bare_root" == ".git" ]]; then
    echo "Error: Not in a worktree-based repo. Use from within an existing worktree."
    return 1
  fi

  # For bare repos, the common dir IS the bare repo
  # Navigate to the parent of .git (or the bare repo itself)
  local repo_root
  repo_root=$(dirname "$bare_root")

  # Ensure we have latest from origin
  git fetch origin

  # Add worktree with new branch tracking origin/main
  git worktree add "$repo_root/$branch" -b "$branch" origin/main

  # Change into the new worktree
  cd "$repo_root/$branch"
}
