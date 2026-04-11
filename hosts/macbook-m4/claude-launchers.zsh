# Custom-auth launchers for `claude` (Claude Code).
# Sibling of gh-token-switching.zsh; sourced from home.nix initContent.
#
# Provides:
#   av-claude <profile> [claude-args...]   aws-vault exec <profile> -- claude ...
#   gh-claude-restricted [claude-args...]  claude with GH_PAT_RESTRICTED (subshell-scoped)
#   gh-claude-private    [claude-args...]  claude with GH_PAT_PRIVATE    (subshell-scoped)
#   gh-claude-admin      [claude-args...]  claude with GH_PAT_ADMIN      (subshell-scoped)
#
# The gh-claude-* wrappers run inside a subshell so GITHUB_TOKEN / GH_ENV_MODE
# set by the underlying gh-* functions (see gh-token-switching.zsh) do NOT
# leak into the parent shell after claude exits. This preserves the shell's
# default least-privilege tier.

av-claude() {
  if (( $# == 0 )); then
    echo "usage: av-claude <aws-vault-profile> [claude-args...]" >&2
    echo "       profiles: see ~/.aws/config" >&2
    echo "       e.g.  av-claude terraform" >&2
    echo "             av-claude tf-proxmox --resume" >&2
    return 2
  fi
  local profile="$1"
  shift
  aws-vault exec "$profile" -- claude "$@"
}

gh-claude-restricted() { ( gh-restricted >/dev/null && exec claude "$@" ); }
gh-claude-private()    { ( gh-private    >/dev/null && exec claude "$@" ); }
gh-claude-admin()      { ( gh-admin      >/dev/null && exec claude "$@" ); }
