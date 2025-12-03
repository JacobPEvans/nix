# Claude Agent SDK - Python Development Shell
#
# Nix development environment for working with the Claude Agent SDK for Python.
#
# Source: https://github.com/anthropics/claude-agent-sdk-python
#
# Features:
# - Python 3.11+ with pip and virtualenv
# - Anthropic Python SDK
# - Development tools (pytest, black, mypy, ruff)
# - Pre-configured for agent development
#
# Usage:
#   cd /path/to/your/claude-agent-project
#   nix develop /path/to/nix/shells/claude-sdk-python
#
# Or with direnv (create .envrc):
#   use flake /path/to/nix/shells/claude-sdk-python

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "claude-sdk-python";

  buildInputs = with pkgs; [
    # Python runtime and package management
    python311
    python311Packages.pip
    python311Packages.virtualenv
    python311Packages.setuptools

    # Anthropic SDK dependencies
    python311Packages.anthropic  # Claude API SDK
    python311Packages.httpx      # HTTP client
    python311Packages.pydantic   # Data validation

    # Development tools
    python311Packages.pytest     # Testing framework
    python311Packages.pytest-asyncio  # Async test support
    python311Packages.black      # Code formatter
    python311Packages.mypy       # Type checker
    python311Packages.ruff       # Fast linter

    # Useful utilities
    python311Packages.ipython    # Interactive shell
    python311Packages.rich       # Pretty printing
    
    # Version control
    git
  ];

  shellHook = ''
    echo "🤖 Claude Agent SDK - Python Development Environment"
    echo ""
    echo "Python version: $(python --version)"
    echo "Available tools:"
    echo "  - anthropic: Claude API Python SDK"
    echo "  - pytest: Testing framework"
    echo "  - black: Code formatter"
    echo "  - mypy: Type checker"
    echo "  - ruff: Fast linter"
    echo ""
    echo "Quick start:"
    echo "  1. Install the SDK: pip install anthropic"
    echo "  2. Set API key: export ANTHROPIC_API_KEY=<your-key>"
    echo "  3. Run examples from: https://github.com/anthropics/claude-agent-sdk-python"
    echo ""
    echo "Documentation:"
    echo "  - SDK: https://github.com/anthropics/claude-agent-sdk-python"
    echo "  - API Docs: https://docs.anthropic.com/"
    echo "  - Examples: https://github.com/anthropics/claude-agent-sdk-demos"
    echo ""
    
    # Create local virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
      echo "Creating Python virtual environment..."
      python -m venv .venv
      echo "Run 'source .venv/bin/activate' to activate the virtual environment"
    fi
  '';

  # Environment variables
  ANTHROPIC_SDK_ENV = "development";
  PYTHON_PATH = ".venv/bin/python";
}
