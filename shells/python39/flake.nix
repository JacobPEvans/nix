# Python 3.9 Development Shell
#
# Minimal Python 3.9 environment for Splunk development and backwards compatibility.
# Install project-specific packages via pip or uv as needed.
#
# Usage:
#   1. Copy this file to your project: cp -r ~/.config/nix/shells/python39 ./nix-shell
#   2. Create .envrc: echo "use flake ./nix-shell" > .envrc
#   3. Allow direnv: direnv allow
#
# Or manually: nix develop
#
# Or with uv (recommended for per-project installs):
#   uv venv --python 3.9 .venv
#   uv pip install splunk-sdk

{
  description = "Python 3.9 development environment (Splunk, backwards compatibility)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      # Support multiple systems
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs systems (system: f { pkgs = import nixpkgs { inherit system; }; });
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            name = "python39-dev";

            buildInputs = with pkgs; [
              # Python 3.9 with minimal tools for project-specific installation
              (python39.withPackages (
                ps: with ps; [
                  pip # Python package installer
                  virtualenv # Virtual environment tool
                  # Add project-specific packages here as needed:
                  # ps.requests
                  # ps.pyyaml
                ]
              ))
            ];

            shellHook = ''
              echo "======================================"
              echo "Python 3.9 Development Environment"
              echo "======================================"
              echo ""
              echo "$(python --version)"
              echo ""
              echo "Usage:"
              echo "  - For system-wide installs: pip install <package>"
              echo "  - For project isolation: uv venv --python 3.9 .venv"
              echo ""
              echo "Splunk SDK:"
              echo "  pip install splunk-sdk"
              echo "  OR"
              echo "  uv pip install splunk-sdk"
              echo ""
            '';
          };
        }
      );
    };
}
