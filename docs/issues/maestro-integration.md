# feat: Add Maestro mobile UI testing framework to Nix configuration

## Summary

Add [Maestro](https://maestro.dev/) to the Nix configuration to enable automated end-to-end UI testing for mobile and web applications. This would provide a reproducible, declarative way to run Maestro tests as part of development and CI/CD workflows.

## Motivation

As we expand automation capabilities in this repository, having a robust UI testing framework becomes essential for:

- **Automated QA pipelines**: Run E2E tests on every PR or deployment
- **Cross-platform testing**: Single framework for Android, iOS, and web applications
- **AI-assisted development**: Enable Claude and other AI agents to validate UI changes before creating PRs
- **Reproducible test environments**: Nix guarantees consistent Maestro versions across all machines

Maestro's YAML-based flow syntax makes it particularly well-suited for AI-generated tests, as the human-readable format is easy to programmatically create and modify.

## Technical Details

### Maestro Overview
- **What it is**: Open-source E2E UI testing framework for mobile (Android/iOS) and web
- **Test format**: YAML-based flows with commands like `launchApp`, `tapOn`, `assertVisible`
- **Key features**: Built-in flakiness tolerance, automatic waiting, visual flow builder (Maestro Studio)
- **Platforms**: macOS, Linux, Windows (WSL)
- **Requirement**: Java 17+

### Current Availability
- ❌ **Not in nixpkgs** - `nix search nixpkgs maestro` returns no results
- ✅ Available via Homebrew (`brew install maestro`)
- ✅ Available via install script: `curl -fsSL "https://get.maestro.mobile.dev" | bash`

### Proposed Implementation

Following the repository's package hierarchy (nixpkgs → homebrew → custom packaging):

**Option A: Homebrew Integration (Recommended for initial implementation)**
Add to `modules/darwin/homebrew.nix`:
```nix
brews = [
  "maestro"  # Mobile/web UI testing framework - not in nixpkgs
];
```

**Option B: Dedicated Development Shell**
Create `shells/mobile-testing/flake.nix` with:
- Maestro CLI (via fetchzip or buildGo/buildRust if applicable)
- Java 17 (required dependency)
- Android SDK tools (optional, for local emulator testing)
- Supporting tools (jq, yq for YAML manipulation)

**Option C: Custom Nix Package**
Package Maestro directly in the flake for full reproducibility:
- Fetch the release tarball
- Handle Java 17 dependency via `makeWrapper`
- Add to system or home packages

## Acceptance Criteria

- [ ] Maestro CLI is available in the development environment
- [ ] `maestro --version` returns expected output after rebuild
- [ ] Java 17+ dependency is satisfied
- [ ] Works on both `aarch64-darwin` and `x86_64-darwin`
- [ ] Documentation added to relevant README or shell description
- [ ] `nix flake check` passes

## Additional Context

### Example Maestro Flow
```yaml
appId: com.example.app
---
- launchApp
- tapOn: "Login"
- inputText:
    id: "email"
    text: "test@example.com"
- tapOn: "Submit"
- assertVisible: "Welcome"
```

### Related Resources
- [Maestro Documentation](https://docs.maestro.dev)
- [GitHub Repository](https://github.com/mobile-dev-inc/Maestro)
- [Maestro on Homebrew](https://formulae.brew.sh/formula/maestro)

---

Slack thread: https://jacobpevans.slack.com/archives/C0A648CS1K4/p1767720102487199
