# Flake Rebuild

Update all flake inputs and rebuild nix-darwin.

**IMPORTANT**: This command has special auto-merge permission. Unlike normal PRs, this command may merge automatically if all conditions are met.

## Steps

### 1. Update Flake Inputs

Run `nix flake update` to update flake.lock.

**On failure**: Stop and report the error.

### 2. Check for Changes

If flake.lock is unchanged, report "All flake inputs already up to date" and stop.

### 3. Commit the Update

Commit flake.lock with message: `chore(deps): update flake.lock`

### 4. Rebuild nix-darwin

Run `sudo darwin-rebuild switch --flake ~/.config/nix`

**On failure**: Stop and report the error.

### 5. Create Branch and Push

Create a feature branch (chore/flake-update-YYYY-MM-DD), push it, and create a PR.

### 6. Wait for Checks and Auto-Merge

Watch PR checks. If all pass and PR is mergeable, squash merge and return to main. If checks fail, report status and do NOT merge.

### 7. Report Summary

Summarize what inputs were updated from the flake.lock diff.
