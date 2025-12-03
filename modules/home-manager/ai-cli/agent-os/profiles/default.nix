# Agent OS Default Profile
#
# Symlinks the default profile from the flake input to ~/agent-os/profiles/default/
# The profile contains agents, commands, standards, and workflows.
#
# Structure:
#   profiles/default/
#   ├── agents/           # 8 specialized agents
#   ├── commands/         # 7 command categories
#   ├── standards/        # Coding standards by category
#   ├── workflows/        # Implementation/planning/specification workflows
#   └── claude-code-skill-template.md
#
# Note: We symlink the entire directory tree to preserve structure
# Individual files are linked to allow project-install.sh to work correctly

{ agent-os }:

let
  # The profile directory in the flake input
  profilePath = "${agent-os}/profiles/default";
in
{
  # Symlink the entire default profile directory
  # Home-manager will recursively link all files
  files = {
    "agent-os/profiles/default".source = profilePath;
  };
}
