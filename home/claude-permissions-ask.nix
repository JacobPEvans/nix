# Claude Code User-Prompted Commands
#
# This file defines commands that require explicit user approval.
# These are potentially dangerous but may be necessary in specific contexts.
#
# Security Strategy:
# - User must explicitly approve each execution (not auto-approved)
# - Useful for ad-hoc tasks but not automation
# - Moved from allow list after security review
#
# Philosophy:
# - Principle of least privilege
# - Dangerous capabilities excluded from baseline
# - User can still approve on a per-case basis
#

{ ... }:

let
  # System modification and scripting
  # osascript can execute arbitrary AppleScript, posing injection/system modification risks
  systemScriptCommands = [
    "Bash(osascript:*)"
    "Bash(osascript -e:*)"
  ];

  # System information disclosure
  # system_profiler reveals detailed hardware/software configuration
  systemInfoDisclosureCommands = [
    "Bash(system_profiler:*)"
  ];

  # macOS system configuration reading
  # defaults read can expose sensitive system settings
  macosConfigCommands = [
    "Bash(defaults read:*)"
  ];

  # Dangerous file operations (require user approval)
  # chmod can remove critical permissions
  # rm/rmdir without restrictions could delete important files
  dangerousFileCommands = [
    "Bash(chmod:*)"
    "Bash(rm:*)"
    "Bash(rmdir:*)"
    "Bash(sudo rm:*)"
  ];

  # Docker privileged operations
  # These can expose host system or create security issues
  dockerPrivilegedCommands = [
    "Bash(docker exec:*)"
    "Bash(docker run:*)"
  ];

  # Kubernetes destructive operations
  kubeDeleteCommands = [
    "Bash(kubectl delete:*)"
  ];

  # AWS infrastructure modification
  # These can create/delete cloud resources
  awsDestructiveCommands = [
    "Bash(aws s3 rm:*)"
    "Bash(aws ec2 terminate:*)"
  ];

  # Database modification commands (write operations)
  databaseModifyCommands = [
    "Bash(sqlite3:*)"  # Can execute arbitrary SQL
    "Bash(mongosh:*)"  # Can modify MongoDB
  ];

in
{
  # Export the ask list
  askList = systemScriptCommands
    ++ systemInfoDisclosureCommands
    ++ macosConfigCommands
    ++ dangerousFileCommands
    ++ dockerPrivilegedCommands
    ++ kubeDeleteCommands
    ++ awsDestructiveCommands
    ++ databaseModifyCommands;
}
