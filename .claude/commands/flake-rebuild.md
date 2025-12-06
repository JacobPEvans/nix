# Flake Rebuild

Update all flake inputs and rebuild nix-darwin.

**IMPORTANT**: This command has special auto-merge permission. Unlike normal PRs, this command may merge automatically if all conditions are met.

## Steps

### 1. Update Flake Inputs

Run `nix flake update` to update flake.lock.

**On failure**: Stop and report the error.

### 2. Check for Changes

If flake.lock is unchanged, report "All flake inputs already up to date" and stop.

### 3. Create Feature Branch

Create and switch to branch: `chore/flake-update-YYYY-MM-DD` (use today's date).

### 4. Commit the Update

Commit flake.lock with message summarizing what was updated (from nix flake update output).

### 5. Rebuild nix-darwin

Run `sudo darwin-rebuild switch --flake .`

**On failure**: Stop and report the error.

### 6. Push and Create PR

Push the feature branch and create a PR.

### 7. Wait for Checks and Auto-Merge

Watch PR checks. If all pass and PR is mergeable, squash merge and return to main. If checks fail, report status and do NOT merge.

### 8. Report Summary

Summarize what inputs were updated.
