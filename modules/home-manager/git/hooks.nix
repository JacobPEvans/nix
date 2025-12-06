# Git Hooks (Auto-installed via templates)
#
# These hooks are installed automatically on new git clones via init.templateDir.
# They delegate to pre-commit framework if .pre-commit-config.yaml exists.
#
# Layer 1 of 3-layer defense:
#   1. Auto-install hooks (this) - fast local feedback
#   2. AI deny list - blocks --no-verify bypass attempts
#   3. GitHub branch protection - server-side guarantee
#
# For existing repos, run: git config init.templateDir ~/.git-templates && pre-commit install

{ config, pkgs, ... }:

let
  # Pre-commit hook: runs on every commit
  preCommitHook = pkgs.writeShellScript "pre-commit" ''
    # Skip if no pre-commit config
    if [ ! -f .pre-commit-config.yaml ]; then
      exit 0
    fi

    # Check for pre-commit framework
    if ! command -v pre-commit &> /dev/null; then
      echo "Error: .pre-commit-config.yaml exists but pre-commit is not installed"
      echo "Install with: nix-env -iA nixpkgs.pre-commit"
      exit 1
    fi

    # Run pre-commit hooks
    exec pre-commit run --hook-stage commit
  '';

  # Pre-push hook: runs before push (secondary gate)
  prePushHook = pkgs.writeShellScript "pre-push" ''
    # Skip if no pre-commit config
    if [ ! -f .pre-commit-config.yaml ]; then
      exit 0
    fi

    # Check for pre-commit framework
    if ! command -v pre-commit &> /dev/null; then
      exit 0  # Don't block push if pre-commit not available
    fi

    # Run all pre-commit hooks on all files
    exec pre-commit run --all-files --hook-stage push
  '';
in
{
  home.file = {
    ".git-templates/hooks/pre-commit" = {
      source = preCommitHook;
      executable = true;
    };
    ".git-templates/hooks/pre-push" = {
      source = prePushHook;
      executable = true;
    };
  };
}
