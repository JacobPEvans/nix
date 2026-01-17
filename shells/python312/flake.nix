# Python 3.12 Development Shell
#
# Full-featured Python 3.12 environment with comprehensive development tools
# for testing, linting, formatting, and type checking. Ideal for backwards
# compatibility testing and pre-commit hooks.
#
# Usage:
#   1. Copy this file to your project: cp -r ~/.config/nix/shells/python312 ./nix-shell
#   2. Create .envrc: echo "use flake ./nix-shell" > .envrc
#   3. Allow direnv: direnv allow
#
# Or manually: nix develop
#
# Included tools:
#   - pytest: Testing framework
#   - ruff: Fast Python linter and formatter
#   - mypy: Static type checker
#   - black: Code formatter
#   - coverage: Code coverage measurement
#   - pre-commit: Git hook framework

{
  description = "Python 3.12 development environment (testing, linting, formatting)";

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
            name = "python312-dev";

            buildInputs = with pkgs; [
              # Python 3.12 with comprehensive development tools
              (python312.withPackages (
                ps: with ps; [
                  # Package management
                  pip # Python package installer
                  virtualenv # Virtual environment tool
                  setuptools # Build system

                  # Testing
                  pytest # Testing framework
                  pytest-asyncio # Async test support
                  pytest-cov # Coverage plugin for pytest
                  coverage # Code coverage measurement

                  # Linting and formatting
                  ruff # Fast Python linter and formatter (replaces flake8 + isort + black)
                  black # Code formatter (backup for style consistency)
                  mypy # Static type checker for Python

                  # Utilities
                  ipython # Enhanced interactive shell
                ]
              ))

              # Version control
              git # Git CLI (often useful in dev shells)
            ];

            shellHook = ''
              echo "======================================"
              echo "Python 3.12 Development Environment"
              echo "======================================"
              echo ""
              echo "$(python --version)"
              echo ""
              echo "Tools available:"
              echo "  - pytest: pytest [test_file] or pytest --cov"
              echo "  - ruff: ruff check . && ruff format ."
              echo "  - mypy: mypy [file]"
              echo "  - black: black [file]"
              echo "  - coverage: coverage run -m pytest && coverage report"
              echo "  - ipython: ipython (for interactive testing)"
              echo ""
              echo "Usage tips:"
              echo "  - For project isolation: uv venv --python 3.12 .venv"
              echo "  - Run tests: pytest"
              echo "  - Check types: mypy src/"
              echo "  - Format code: ruff format . && ruff check --fix ."
              echo ""
            '';
          };
        }
      );
    };
}
