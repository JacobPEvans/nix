# Splunk Development Shell (Python 3.9 via uv)
#
# Development environment for Splunk apps and add-ons using Python 3.9.
# Since Python 3.9 is EOL and not available in nixpkgs, this shell uses `uv`
# to download the interpreter on-demand from python-build-standalone.
#
# Key feature: Python 3.9 is fetched by uv, not installed system-wide.
# This is the recommended approach for EOL Python versions.
#
# Usage:
#   1. Copy this file to your project: cp -r ~/.config/nix/shells/splunk-dev ./nix-shell
#   2. Create .envrc: echo "use flake ./nix-shell" > .envrc
#   3. Allow direnv: direnv allow
#
# Or manually: nix develop
#
# Python 3.9 commands (via uv):
#   uv venv --python 3.9 .venv           # Create virtualenv with Python 3.9
#   uv pip install splunk-sdk            # Install Splunk SDK
#   uv run --python 3.9 python app.py    # Run with Python 3.9
#   uv run --python 3.9 pytest tests/    # Test with Python 3.9

{
  description = "Splunk development environment (Python 3.9 via uv)";

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
            name = "splunk-dev";

            buildInputs = with pkgs; [
              # uv handles Python 3.9 interpreter download on-demand
              uv

              # Useful development tools
              git
            ];

            shellHook = ''
              echo "======================================"
              echo "Splunk Development Environment"
              echo "======================================"
              echo ""
              echo "Python 3.9 is provided by uv (on-demand download)"
              echo ""
              echo "Quick start:"
              echo "  1. Create virtualenv:  uv venv --python 3.9 .venv"
              echo "  2. Activate:           source .venv/bin/activate"
              echo "  3. Install SDK:        uv pip install splunk-sdk"
              echo ""
              echo "Or run directly:"
              echo "  uv run --python 3.9 python script.py"
              echo "  uv run --python 3.9 pytest tests/"
              echo ""
              echo "First run will download Python 3.9 (~30MB, cached in ~/.cache/uv/)"
              echo ""

              # Pre-fetch Python 3.9 so it's ready when user needs it
              if ! uv python find 3.9 >/dev/null 2>&1; then
                echo "Downloading Python 3.9..."
                uv python install 3.9
              fi
            '';
          };
        }
      );
    };
}
