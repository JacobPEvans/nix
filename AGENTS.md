# Nix Configuration - AI Agent Instructions

## Critical Constraints

1. **Flakes-only**: Never use `nix-env`, `nix-channels`, or imperative commands
2. **Determinate Nix**: Keep `nix.enable = false` in darwin config
3. **Nixpkgs first**: Use homebrew only when nixpkgs unavailable
4. **Worktrees required**: Run `/init-worktree` before any work
5. **No direct main commits**: Always use feature branches

## Worktree Workflow

```bash
cd ~/git/nix-config
git fetch origin
git worktree add <branch> -b <branch> origin/main
cd <branch>
```

## Test & Deploy

```bash
nix flake check
sudo darwin-rebuild switch --flake .
```

## File References

- **Permissions**: `ai-assistant-instructions` flake → `~/.claude/settings.json`
- **Plugins**: `modules/home-manager/ai-cli/claude/plugins/`
- **Rules**: `agentsmd/rules/` (worktrees, version-validation, branch-hygiene, security-alert-triage)
- **Security**: See SECURITY.md and `agentsmd/rules/security-alert-triage.md` for alert policies

## Skill and Agent Invocation Rules

**CRITICAL: Never guess namespaces. Use EXACT strings from system output.**

### How to Invoke Skills

The Skill tool uses namespace format:

- **Format**: `skill: "namespace:skill-name"` (colon separator)
- **Example correct**: `code-simplifier:code-simplifier`, `pr-review-toolkit:code-reviewer`
- **Example wrong**: `pr-review-toolkit:code-simplifier` (if error shows `code-simplifier:code-simplifier`)

### When You Get "Agent Not Found" or "Unknown Skill" Error

**DO NOT ASSUME. Follow these steps:**

1. Find the EXACT string in the error's "Available agents:" list
2. Copy and use that EXACT string
3. Never modify, abbreviate, or guess based on patterns
4. If error shows `code-simplifier:code-simplifier`, use `code-simplifier:code-simplifier` exactly

### Common Mistakes (NEVER DO THESE)

| ❌ Wrong Pattern | ✓ Fix | Why |
|---|---|---|
| Assuming pr-review-toolkit for unknown skills | Copy exact string from error | Claude defaults to wrong namespace |
| Using short names | Use full namespace:skill format | Ambiguity causes failures |
| Trusting assumptions over error output | Copy from error output always | Errors are authoritative |

For full details, see `/nix-config` repo CLAUDE.md "Skill Invocation Rules" section.

## PR Rules

- Never auto-merge without explicit user approval
- 50-comment limit per PR
- Batch commits locally, push once
