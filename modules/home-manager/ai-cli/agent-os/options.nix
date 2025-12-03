# Agent OS Configuration Options
#
# Defines all configurable options for Agent OS integration.
# These map to ~/agent-os/config.yml settings.
#
# Reference: https://buildermethods.com/agent-os/modes

{
  # Whether to enable Agent OS
  enable = true;

  # Profile to use (only "default" supported currently)
  # Custom profiles can be added to ~/agent-os/profiles/
  profile = "default";

  # Claude Code Commands Integration
  # When true, installs Agent OS commands to .claude/commands/agent-os/
  # Provides: /shape-spec, /write-spec, /create-tasks, etc.
  claudeCodeCommands = true;

  # Claude Code Subagents
  # When true, allows commands to delegate to specialized subagents
  # Requires claudeCodeCommands = true
  # More autonomous but higher token usage
  useClaudeCodeSubagents = true;

  # Standards as Claude Code Skills
  # When true, standards become Claude Code Skills in .claude/skills/
  # Claude applies them automatically based on context
  # Requires claudeCodeCommands = true
  standardsAsClaudeCodeSkills = false;

  # Agent OS Commands (for other AI tools)
  # When true, generates commands in agent-os/commands/
  # For use with Cursor, Windsurf, Codex, Gemini, etc.
  agentOsCommands = false;
}
