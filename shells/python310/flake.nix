# Python 3.10 Development Shell
#
# Minimal Python 3.10 environment for older compatibility testing.
# Install project-specific packages via pip or uv as needed.
#
# Usage:
#   1. Copy this file to your project: cp -r ~/.config/nix/shells/python310 ./nix-shell
#   2. Create .envrc: echo "use flake ./nix-shell" > .envrc
#   3. Allow direnv: direnv allow
#
# Or manually: nix develop
#
# Or with uv (recommended for per-project installs):
#   uv venv --python 3.10 .venv
#   uv pip install <packages>

{
  description = "Python 3.10 development environment (older compatibility)";

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
      envs = { pkgs }: import ../../lib/python-environments.nix { inherit pkgs; };
    in
    {
      devShells = forAllSystems (
        { pkgs }:
        let
          pythonEnvs = envs { inherit pkgs; };
        in
        {
          default = pkgs.mkShell {
            name = "python310-dev";

            buildInputs = with pkgs; [
              # Python 3.10 with minimal tools for project-specific installation
              (pythonEnvs.versions.py310.withPackages pythonEnvs.packageSets.minimal)
            ];

            shellHook = ''
              echo "======================================"
              echo "Python 3.10 Development Environment"
              echo "======================================"
              echo ""
              echo "$(python --version)"
              echo ""
              echo "Usage:"
              echo "  - For system-wide installs: pip install <package>"
              echo "  - For project isolation: uv venv --python 3.10 .venv"
              echo ""
            '';
          };
        }
      );
    };
}
