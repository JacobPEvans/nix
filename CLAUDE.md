# AI Agent Instructions for Nix Configuration

Guidelines for AI agents (Claude, etc.) when modifying nix, nix-darwin, or home-manager configurations.

**This is a flakes-only configuration.** Do not use nix-channels or non-flake commands.

## Architecture Overview

This setup uses multiple tools working together:

| Tool | Responsibility |
|------|----------------|
| **Determinate Nix** | Manages Nix itself (the package manager, daemon, updates) |
| **nix-darwin** | Manages macOS system configuration, packages, and settings |
| **home-manager** | Manages user-level configuration (shell, dotfiles, user packages) |
| **nixpkgs** | The package repository - source for ALL packages |

## Core Principles

### 1. Nixpkgs First, Always
- **ALL packages must come from nixpkgs** whenever possible
- Homebrew is a **fallback only** for packages not in nixpkgs or severely outdated
- Before suggesting homebrew, search nixpkgs: `nix search nixpkgs <package>`

### 2. Determinate Nix Manages Nix
- Do NOT use nix-darwin to manage Nix itself
- `nix.enable = false` must remain in darwin configuration
- Determinate handles: nix daemon, nix updates, nix configuration

### 3. Comments and Documentation
- **Keep comments in config files** - they help with learning
- **Keep empty sections visible** with commented examples (e.g., empty `brews = []` with comment)
- User is learning nix - visibility of options is more important than minimal configs
- Example:
  ```nix
  brews = [
    # CLI tools (only if not available in nixpkgs)
  ];
  ```

### 4. No Version Pinning (Unless Critical)
- Use `_latest` variants when available (e.g., `nodejs_latest`)
- Breaking changes from upgrades are acceptable
- Don't add version suffixes unless specifically requested

## File Structure

```
~/.config/nix/
├── flake.nix                  # Main entry point - inputs and outputs
├── flake.lock                 # Locked dependencies (auto-managed)
├── darwin/
│   └── configuration.nix      # System packages, homebrew, macOS settings
├── home/
│   ├── home.nix               # User shell, aliases, dotfiles, Claude config
│   ├── claude-permissions.nix # Claude Code auto-approved commands (categorized)
│   └── zsh/                   # Modular shell configuration files
├── CLAUDE.md                  # This file - AI agent instructions
├── README.md                  # User documentation and commands
├── SETUP.md                   # Setup history and troubleshooting
├── CHANGELOG.md               # Version history
└── PLANNING.md                # Roadmap and future work
```

## Common Commands

```bash
# Rebuild and switch to new configuration
darwin-rebuild switch --flake ~/.config/nix#default

# Build without switching (test)
nix build ~/.config/nix#darwinConfigurations.default.system

# Search for packages
nix search nixpkgs <package>

# List generations (for rollback)
darwin-rebuild --list-generations

# Rollback to previous generation
darwin-rebuild --rollback

# Update flake inputs
nix flake update ~/.config/nix
```

## When Modifying Configurations

### Adding a Package
1. Search nixpkgs first: `nix search nixpkgs <name>`
2. Add to `darwin/configuration.nix` under `environment.systemPackages`
3. Include a comment explaining what it is
4. Rebuild: `darwin-rebuild switch --flake ~/.config/nix#default`

### Adding Shell Configuration
1. Modify `home/home.nix`
2. Shell aliases, functions, and environment go here
3. Rebuild to apply

### If Package Not in Nixpkgs
1. Check if there's a community flake for it
2. As last resort, add to homebrew.brews or homebrew.casks
3. Document why homebrew was needed

## Troubleshooting

### "packages not available" Error
The package name in nixpkgs might differ. Search with partial name:
```bash
nix search nixpkgs <partial-name>
```

### Changes Not Taking Effect
1. Ensure changes are committed to git (flakes require clean git state or explicit paths)
2. Run rebuild: `darwin-rebuild switch --flake ~/.config/nix#default`
3. Open new terminal session

### Packages "Disappearing"
Packages installed outside nix (manual brew, npm -g) are NOT managed by nix.
They may disappear after system updates. Always add packages to the nix config.

### Duplicate Packages (Homebrew vs Nix)
When adding packages to nix that were previously installed via homebrew:

1. **Check for duplicates first**:
   ```bash
   which <package>  # See which version is found first
   brew list --formula | grep <package>
   brew list --cask | grep <package>
   ```

2. **Verify existing configurations**:
   - GPG: `~/.gnupg` directory (preserve keys and trust database)
   - App settings: Check `~/Library/Application Support/<app>`
   - Backup important configs before uninstalling

3. **Remove homebrew version as user** (not root):
   ```bash
   sudo -u jevans brew uninstall <package>       # For formulas
   sudo -u jevans brew uninstall --cask <package> # For casks
   ```

4. **Verify nix version is now found**:
   ```bash
   which <package>  # Should show /run/current-system/sw/bin/<package>
   <package> --version  # Verify correct version
   ```

### PATH Priority Issues
If homebrew packages are found before nix packages:

1. **Check PATH order**:
   ```bash
   echo $PATH
   ```

2. **Expected order** (nix should come before homebrew):
   - `/Users/jevans/.nix-profile/bin`
   - `/etc/profiles/per-user/jevans/bin`
   - `/run/current-system/sw/bin` ← nix packages here
   - `/nix/var/nix/profiles/default/bin`
   - `/opt/homebrew/bin` ← homebrew packages here (fallback only)

3. **If homebrew comes first**, check:
   - `~/.zshrc` or `~/.zprofile` for homebrew shellenv
   - Remove manual PATH additions that prioritize homebrew
   - Let nix-darwin manage PATH via `/etc/zshenv`

### VS Code Configuration Deprecation
If you see "programs.vscode.userSettings has been renamed":

```nix
# OLD (deprecated):
programs.vscode = {
  enable = true;
  userSettings = { ... };
};

# NEW (correct):
programs.vscode = {
  enable = true;
  profiles.default.userSettings = { ... };
};
```

## Claude Code Configuration Management

This Nix configuration manages Claude Code settings declaratively while maintaining flexibility.

### Layered Configuration Strategy

**Nix-managed baseline** (`~/.claude/settings.json`):
- Defined in `home/claude-permissions.nix`
- Contains ~300+ pre-approved safe commands
- Version controlled and reproducible
- Updated via `darwin-rebuild switch`

**User-managed overrides** (`~/.claude/settings.local.json`):
- Intentionally NOT managed by Nix (remains writable)
- Claude writes here when you click "accept indefinitely"
- Allows ad-hoc approvals without rebuilding
- Local to this machine only

**How they merge:**
- Claude combines both files at runtime
- `settings.local.json` overrides `settings.json`
- Best of both worlds: reproducible + flexible

### Modifying Approved Commands

**To add commands to version-controlled baseline:**
1. Edit `home/claude-permissions.nix`
2. Add to appropriate category (gitCommands, dockerCommands, etc.)
3. Commit changes
4. Run: `darwin-rebuild switch --flake ~/.config/nix#default`

**To quickly approve during a session:**
- Just click "accept indefinitely" in Claude
- Command gets added to `settings.local.json` automatically
- Consider moving to baseline later for reproducibility

### Security Notes

The deny list blocks:
- Destructive operations (`rm -rf /`, system modifications)
- Sensitive file access (`.env`, SSH keys, AWS credentials)
- Write HTTP methods (POST, PUT, DELETE, PATCH)
- Privilege escalation (`sudo su`, `sudo -i`)
- Network listeners (reverse shells)

## Important Notes

- Git commits are required before rebuild (flakes track git state)
- `/run/current-system/sw/bin` contains nix-managed binaries
- `~/.nix-profile` is the user's nix profile symlink
- Determinate Nix config is at `/etc/nix/nix.conf` (don't modify directly)
- Homebrew should only contain packages NOT available in nixpkgs
- Always backup configuration files before uninstalling packages
