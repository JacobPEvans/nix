# TEMPORARY WORKAROUND: direnv test-fish SIGKILL on macOS darwin
#
# direnv-2.37.1's test-fish check phase target is killed by signal 9 (SIGKILL)
# on darwin. The root cause is a Nix daemon bug where RewritingSink corrupts
# Mach-O code signatures, causing the kernel to kill the fish binary.
#
# This is NOT a direnv bug — the fish binary itself is corrupt after copying.
# All meaningful tests (Go, bash, zsh) continue to run.
#
# Upstream references:
#   - Nix daemon bug: https://github.com/NixOS/nix/issues/6065
#   - nixpkgs tracking: https://github.com/NixOS/nixpkgs/issues/507531
#   - Nix daemon fix PR: https://github.com/NixOS/nix/pull/15638
#
# REMOVE THIS OVERLAY when NixOS/nix#15638 is merged and the fixed Nix daemon
# is available in our Determinate Nix version.

_final: prev:

if prev.stdenv.isDarwin then
  {
    direnv = prev.direnv.overrideAttrs (_: {
      checkPhase = ''
        runHook preCheck
        make test-go test-bash test-zsh
        runHook postCheck
      '';
    });
  }
else
  { }
