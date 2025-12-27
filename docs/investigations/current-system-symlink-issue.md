# Investigation: /run/current-system Symlink Not Updating

**Status**: ACTIVE INVESTIGATION
**Started**: 2024-12-26
**Issue**: `/run/current-system` symlink not updating after `darwin-rebuild switch`

## Problem Statement

After running `darwin-rebuild switch`, the build succeeds and a new generation is created,
but `/run/current-system` continues pointing to an old generation. This is a silent failure - the
command exits successfully but the system doesn't actually switch to the new configuration.

## Evidence

### Observed Behavior

```bash
# Before rebuild
$ readlink /run/current-system
/nix/store/afgn3l4zmpnn0p45b86q6wdp21rcqhyy-darwin-system-26.05.f0c8e1f

# After successful rebuild
$ readlink /nix/var/nix/profiles/system
system-287-link -> /nix/store/wa0fakj369ypibngf4issnj97afc7f44-darwin-system-26.05.f0c8e1f

# Symlink not updated
$ readlink /run/current-system
/nix/store/afgn3l4zmpnn0p45b86q6wdp21rcqhyy-darwin-system-26.05.f0c8e1f  # Still old!
```

### Activation Script Analysis

The activate script at `/nix/var/nix/profiles/system/activate` contains:

```bash
# Line ~1526
ln -sfn "$(readlink -f "$systemConfig")" /run/current-system
```

This command SHOULD update the symlink, but:

1. The postActivation verification (line 1413) runs BEFORE this command
2. The activation completes successfully (we see "Configuring custom file extension mappings...")
3. But the symlink is never updated

### What We Know

**✅ Confirmed Working**:

- Build succeeds
- New generation is created in `/nix/var/nix/profiles/`
- Activation scripts run to completion
- Terminal output shows activation reaching the end

**❌ Not Working**:

- The `ln -sfn` command at line 1526 either:
  - Doesn't execute (but why? no exit/crash before it)
  - Executes but fails silently
  - Executes but gets overwritten somehow

**🤔 Unclear**:

- Why does activation appear to complete but not run the final command?
- Is there a race condition?
- Is darwin-rebuild doing something after the activate script runs?

## Hypotheses

### Hypothesis 1: Command Not Executing

The `ln -sfn` command isn't running because something prevents execution.

**Evidence against**: We see "Configuring custom file extension mappings..." which is right before the ln command.

### Hypothesis 2: Silent Failure

The command runs but fails without reporting an error.

**How to test**: Add explicit error checking and logging around the ln command.

### Hypothesis 3: Overwrite After Success

The command succeeds but something overwrites the symlink afterward.

**How to test**: Add a final verification at the very end of the activate script.

### Hypothesis 4: Wrong Activate Script

darwin-rebuild is calling a different activate script than we think.

**How to test**: Add debugging to confirm which activate script is running.

### Hypothesis 5: Permission Timing

Permission changes during activation prevent the symlink update.

**How to test**: Check permissions before and after the ln command.

## Investigation Plan

1. **Add Debug Logging**: Instrument the activate script generation to add extensive logging
2. **Capture Full Output**: Run rebuild with all output captured
3. **Trace Execution**: Use set -x in activation scripts to see every command
4. **Verify Permissions**: Check /run permissions throughout activation
5. **Test Manual Activation**: Run the activate script directly to isolate the issue

## Workarounds

Until fixed, manually run:

```bash
sudo /nix/var/nix/profiles/system/activate
```

## Related Issues

- Fixed in PR #298: Marketplace directory conflicts that blocked activation
- This issue is separate and pre-existing

## Investigation Progress

### Completed

- ✅ Added set -x tracing to preActivation
- ✅ Added DEBUG logging to show execution flow
- ✅ Created debugging infrastructure:
  - `scripts/debug-activation.sh`: Diagnose current state
  - `scripts/test-rebuild-with-logging.sh`: Capture rebuild output
  - `scripts/analyze-rebuild-logs.sh`: Analyze log files
- ✅ Enhanced postActivation with detailed logging
- ✅ Spawned research agent to investigate nix-darwin source code
- ✅ Committed debugging infrastructure to git

### In Progress

- 🔄 Research agent investigating nix-darwin activation flow
  - Analyzing darwin-rebuild.sh source code
  - Examining activation-scripts.nix
  - Researching GitHub issues and PRs
  - Tracing systemConfig variable usage

### Next Steps

- [ ] Complete research agent investigation
- [ ] Document research findings
- [ ] Run test rebuild manually (requires sudo password)
- [ ] Analyze captured logs
- [ ] Identify root cause from combined research + logs
- [ ] Implement fix
- [ ] Verify fix works
- [ ] Update documentation with solution

## How to Use Debugging Tools

### Check Current State

```bash
./scripts/debug-activation.sh
```

### Run Test Rebuild with Logging

```bash
sudo ./scripts/test-rebuild-with-logging.sh
```

### Analyze Logs

```bash
./scripts/analyze-rebuild-logs.sh /tmp/darwin-rebuild-debug/rebuild-*.log
```
