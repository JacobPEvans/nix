# Official Claude Code Plugins Migration Plan

## Executive Summary

This document outlines a plan to migrate from custom Claude commands to
official Anthropic plugins, managed declaratively via Nix. The goal is to
leverage officially maintained plugins while preserving unique functionality
that doesn't exist in official offerings.

## Current State

### Official Claude Code Plugins (13 available)

| Plugin | Commands | Agents | Skills | Hooks |
|--------|----------|--------|--------|-------|
| agent-sdk-dev | `/new-sdk-app` | `agent-sdk-verifier-py`, `agent-sdk-verifier-ts` | - | - |
| claude-opus-4-5-migration | - | - | claude-opus-4-5-migration | - |
| code-review | `/code-review` | 4 parallel agents (compliance x2, bug detection, history) | - | - |
| commit-commands | `/commit`, `/commit-push-pr`, `/clean_gone` | - | - | - |
| explanatory-output-style | - | - | - | SessionStart |
| feature-dev | `/feature-dev` | `code-explorer`, `code-architect`, `code-reviewer` | - | - |
| frontend-design | - | - | frontend-design | - |
| hookify | `/hookify`, `/hookify:list`, `/hookify:configure` | `conversation-analyzer` | - | - |
| learning-output-style | - | - | - | SessionStart |
| plugin-dev | `/plugin-dev:create-plugin` | `agent-creator`, `plugin-validator`, `skill-reviewer` | 7 skills | - |
| pr-review-toolkit | `/pr-review-toolkit:review-pr` | 6 agents (comment, test, failure, type, quality, simplifier) | - | - |
| ralph-wiggum | `/ralph-loop`, `/cancel-ralph` | - | - | Stop |
| security-guidance | - | - | - | PreToolUse |

### Custom Commands (26 in user's config)

**Categories:**

1. **Git/Commit Workflow**: `commit`, `git-refresh`, `pull-request`, `pull-request-review-feedback`
2. **Code Review**: `review-pr`, `review-pr-ci`, `review-code`, `review-docs`, `review-issue`
3. **Specialized Reviews**: `infrastructure-review`, `link-review`, `model-check`, `notebook-review`
4. **Code Generation**: `generate-code`
5. **Agent OS (Spec Workflow)**: `plan-product`, `shape-spec`, `write-spec`, `create-tasks`, `implement-tasks`, `orchestrate-tasks`
6. **ROK Workflow (Shape Up)**: `rok-shape-issues`, `rok-resolve-issues`, `rok-review-pr`, `rok-respond-to-reviews`
7. **Skills Management**: `improve-skills`

### Custom Agents (8)

- `code-reviewer` - Anthropic Cookbooks specific
- `implementer` - Agent OS
- `product-planner` - Agent OS
- `spec-writer` - Agent OS
- `spec-shaper` - Agent OS
- `spec-initializer` - Agent OS
- `spec-verifier` - Agent OS
- `tasks-list-creator` - Agent OS
- `implementation-verifier` - Agent OS

### Custom Skills (16)

- Backend: `backend-api`, `backend-migrations`, `backend-models`, `backend-queries`
- Frontend: `frontend-accessibility`, `frontend-components`, `frontend-css`, `frontend-responsive`
- Global: `global-coding-style`, `global-commenting`, `global-conventions`, `global-error-handling`, `global-tech-stack`, `global-validation`
- Testing: `testing-test-writing`

## Comparison Matrix

### Commands with Official Plugin Equivalents

| Custom Command | Official Plugin | Overlap Analysis | Recommendation |
|---------------|-----------------|------------------|----------------|
| `/commit` | commit-commands: `/commit` | **FULL OVERLAP** - Official is simpler, custom adds markdownlint validation, pre-commit checks, branch strategy | **REPLACE** - Enable official plugin, document differences |
| `/pull-request` | commit-commands: `/commit-push-pr` | **PARTIAL** - Official is basic push+PR, custom has full PR lifecycle, GraphQL thread resolution, CI monitoring | **KEEP** - Custom is significantly more comprehensive |
| `/review-pr` | code-review: `/code-review` | **PARTIAL** - Official uses 4-agent confidence scoring, custom uses subagent delegation with user approval | **HYBRID** - Use official for auto-review, keep custom for interactive |
| `/review-pr-ci` | code-review: `/code-review` | **FULL OVERLAP** - Both designed for CI automation | **REPLACE** - Official has better confidence filtering |
| `/review-code` | pr-review-toolkit | **DIFFERENT SCOPE** - Custom is guidelines doc, official has 6 specialized agents | **REPLACE** - Official is more comprehensive |

### Commands WITHOUT Official Equivalents (KEEP)

| Custom Command | Purpose | Why Keep |
|---------------|---------|----------|
| `/git-refresh` | Auto-merge PRs, sync repo | No official equivalent |
| `/pull-request-review-feedback` | GraphQL thread resolution docs | No official equivalent |
| `/review-docs` | Markdownlint compliance | No official equivalent |
| `/review-issue` | GitHub issue triage | No official equivalent |
| `/infrastructure-review` | Terraform/Terragrunt review | No official equivalent |
| `/link-review` | Link validation | No official equivalent |
| `/model-check` | Claude model validation | No official equivalent |
| `/notebook-review` | Jupyter notebook review | No official equivalent |
| `/generate-code` | Code generation standards | No official equivalent |

### Agent OS Commands (ALL KEEP)

| Command | Purpose | Why Keep |
|---------|---------|----------|
| `/plan-product` | Product planning | Agent OS workflow |
| `/shape-spec` | Spec shaping (Shape Up) | Agent OS workflow |
| `/write-spec` | Spec writing | Agent OS workflow |
| `/create-tasks` | Task breakdown | Agent OS workflow |
| `/implement-tasks` | Task implementation | Agent OS workflow |
| `/orchestrate-tasks` | Multi-agent orchestration | Agent OS workflow |

### ROK Commands (ALL KEEP)

| Command | Purpose | Why Keep |
|---------|---------|----------|
| `/rok-shape-issues` | Shape Up issue shaping | Comprehensive Shape Up methodology |
| `/rok-resolve-issues` | Issue resolution workflow | Comprehensive workflow |
| `/rok-review-pr` | PR review with thinking mode | Different approach than official |
| `/rok-respond-to-reviews` | Review response workflow | GraphQL thread resolution |

## Gap Analysis

### What Custom Commands Do That Official Plugins DON'T

1. **Pre-commit Validation** (`/commit`)
   - Markdownlint validation (MD013 160-char)
   - Code formatting checks (terraform fmt, prettier, black)
   - Security scanning for sensitive data
   - Official `/commit` is just basic staging and commit

2. **Complete PR Lifecycle** (`/pull-request`)
   - Full PR resolution loop with health checks
   - GraphQL-based thread resolution
   - Line-level review comment retrieval
   - Pre-handoff verification checklist
   - Official `/commit-push-pr` is just push + create PR

3. **Documentation Review** (`/review-docs`)
   - Markdownlint-cli2 integration
   - Auto-fix then verify workflow
   - Memory Bank integration checks
   - AI-friendly formatting guidelines
   - No official equivalent

4. **Infrastructure Review** (`/infrastructure-review`)
   - Terraform/Terragrunt validation
   - Security review (secrets, IAM, network)
   - Cost optimization checks
   - No official equivalent

5. **Shape Up Methodology** (ROK commands)
   - Timebox-based prioritization
   - Circuit breaker patterns
   - Issue formation workflows
   - No official equivalent

6. **Agent OS Spec Workflow**
   - Multi-phase spec development
   - Orchestrated task implementation
   - Standards compliance checking
   - No official equivalent

7. **Specialized Reviews**
   - `notebook-review` for Jupyter/Python
   - `model-check` for Claude model validation
   - `link-review` for link quality
   - No official equivalents

### What Official Plugins Do That Custom Commands DON'T

1. **Confidence Scoring** (code-review)
   - 0-100 confidence ratings
   - Filters issues below 80 threshold
   - Reduces false positives

2. **Multi-Agent Parallel Review** (code-review, feature-dev)
   - 4-6 parallel specialized agents
   - Different perspectives simultaneously

3. **Feature Development Workflow** (feature-dev)
   - 7-phase structured approach
   - Code explorer, architect, reviewer agents
   - Architecture design with multiple approaches

4. **Hook-Based Extensions** (hookify)
   - Custom behavior prevention
   - Runtime rule creation
   - No restart required

5. **Output Style Modifications** (explanatory/learning)
   - Educational insights
   - Interactive learning mode
   - Session-level modifications

6. **Iterative Loops** (ralph-wiggum)
   - Self-referential AI loops
   - Completion promises
   - Max iteration limits

## Nix Implementation Strategy

### Current Plugin Management

```nix
# claude-plugins.nix enables official plugins via settings.json
enabledPlugins = {
  "commit-commands@anthropics/claude-code" = true;
  "code-review@anthropics/claude-code" = true;
  # ... etc
};
```

### Proposed Architecture

```text
~/.claude/
├── settings.json          # Nix-managed (plugins, permissions)
├── commands/              # Hybrid: official + custom
│   ├── <official-plugin-commands>  # From enabled plugins
│   └── <custom-commands>/          # Symlinked from ai-instructions
├── agents/                # Hybrid: official + custom
│   ├── <official-plugin-agents>    # From enabled plugins
│   └── <custom-agents>/            # From claude-cookbooks or ai-instructions
└── skills/                # Custom skills (no official overlap)
    └── <custom-skills>/            # From ai-instructions/agent-os
```

### Plugin vs Custom Source Strategy

| Type | Source | Management |
|------|--------|------------|
| Official Plugins | anthropics/claude-code marketplace | `enabledPlugins` in settings.json |
| Claude Cookbooks Commands | anthropics/claude-cookbooks | Nix file copy |
| AI Instructions Commands | Local repo | Nix out-of-store symlink |
| Agent OS Components | agent-os input | Nix file copy |

### Recommended Migration Steps

#### Phase 1: Enable All Official Plugins

- Already done in current config
- Verify all 12 plugins working (ralph-wiggum optional)

#### Phase 2: Remove Redundant Custom Commands

```nix
# Remove from aiInstructionsCommands:
# - "commit" (replaced by commit-commands plugin)
# - "review-pr-ci" (replaced by code-review plugin if using CI)

# Keep all others that have unique functionality
```

#### Phase 3: Document Command Naming Conflicts

- Custom `/commit` vs official `/commit`
- Custom `/review-pr` vs official `/code-review`
- Solution: Rename custom commands if keeping both

#### Phase 4: Verify No NixOS-Specific Issues

- Issue #4946: ripgrep color codes in paths
- Issue #12880: ralph-wiggum hardcoded shebang
- Test all agents/commands work after migration

## Implementation Checklist

### Commands to REMOVE (replaced by official plugins)

- [ ] Remove custom `/commit` (use official commit-commands)
- [ ] Remove custom `/review-pr-ci` (use official code-review)

### Commands to KEEP (unique functionality)

- [ ] `/pull-request` - Full PR lifecycle management
- [ ] `/git-refresh` - Auto-merge and sync
- [ ] `/pull-request-review-feedback` - GraphQL docs
- [ ] `/review-pr` - Interactive review with user approval
- [ ] `/review-docs` - Markdownlint compliance
- [ ] `/review-issue` - Issue triage
- [ ] `/review-code` - Code review guidelines (reference doc)
- [ ] `/infrastructure-review` - IaC review
- [ ] `/link-review` - Link validation
- [ ] `/model-check` - Model validation
- [ ] `/notebook-review` - Jupyter review
- [ ] `/generate-code` - Code generation standards
- [ ] All Agent OS commands (6)
- [ ] All ROK commands (4)
- [ ] `/improve-skills`

### Agents to KEEP (no official equivalent)

- [ ] `code-reviewer` (claude-cookbooks, Anthropic Cookbooks specific)
- [ ] All Agent OS agents (8)

### Skills to KEEP (no official equivalent)

- [ ] All 16 custom skills

### Official Plugins to ENABLE

- [x] commit-commands
- [x] code-review
- [x] feature-dev
- [x] pr-review-toolkit
- [x] security-guidance
- [x] plugin-dev
- [x] hookify
- [x] agent-sdk-dev
- [x] frontend-design
- [x] explanatory-output-style
- [x] learning-output-style
- [x] claude-opus-4-5-migration
- [ ] ralph-wiggum (optional - experimental)

## GitHub Issues to Track

- [#11676](https://github.com/anthropics/claude-code/issues/11676): `claude plugin update-all` feature request (OPEN)
- [#4946](https://github.com/anthropics/claude-code/issues/4946): NixOS agents/commands bug (OPEN, mostly resolved)
- [#12880](https://github.com/anthropics/claude-code/issues/12880): ralph-wiggum NixOS shebang issue

## Recommended Final State

### Enabled Official Plugins

All 12 official plugins enabled (ralph-wiggum optional).

### Custom Commands Retained

22 commands (removed: `commit`, `review-pr-ci`):

- Git/PR workflow: 3 (git-refresh, pull-request, pull-request-review-feedback)
- Reviews: 6 (review-pr, review-code, review-docs, review-issue, infrastructure-review, link-review)
- Specialized: 3 (model-check, notebook-review, generate-code)
- Agent OS: 6 (plan-product, shape-spec, write-spec, create-tasks, implement-tasks, orchestrate-tasks)
- ROK: 4 (rok-shape-issues, rok-resolve-issues, rok-review-pr, rok-respond-to-reviews)
- Skills: 1 (improve-skills)

### Configuration Changes Required

1. **claude-plugins.nix**: No changes (already enables all plugins)
2. **claude.nix**: Remove `commit` and `review-pr-ci` from `aiInstructionsCommands`
3. **ai-assistant-instructions repo**: Consider renaming `/review-pr` to `/review-pr-interactive` to avoid confusion with official `/code-review`

## Next Steps

1. Create PR implementing the changes above
2. Test all official plugins work correctly
3. Verify custom commands still function alongside plugins
4. Update documentation to reflect new command structure
5. Consider contributing valuable custom commands back to official repos
