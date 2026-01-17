# Python Development Environments
#
# Shared, modular definitions for Python versions and package configurations.
# This module supports multiple Python versions with reusable package sets
# that can be composed into development shells.
#
# Available via Nix (nixpkgs-25.11): 3.10, 3.11, 3.12, 3.13
# For EOL versions (3.9): Use `uv` which downloads on-demand (see below)
#
# Used by: modules/common/packages.nix, shells/*/flake.nix
#
# Design goals:
# - DRY: Define each Python version and package set once
# - Composable: Shells import only what they need
# - Modular: Can add/remove versions independently without affecting others
# - Documented: Clear separation of concern for backwards compatibility testing
#
# Python 3.9 (EOL, not in nixpkgs):
#   Use `uv` for on-demand interpreter downloads from python-build-standalone:
#     uv venv --python 3.9 .venv-splunk
#     uv run --python 3.9 pytest tests/
#   Interpreters are cached in ~/.cache/uv/, not system-installed.
#   This is the recommended approach for Splunk development and CI testing.

{ pkgs }:

{
  # Python versions available via nixpkgs-25.11
  # Each version is defined once here and referenced everywhere
  # Format: pyXY = pkgs.pythonXY for easy lookup
  #
  # NOTE: Python 3.9 is EOL and removed from nixpkgs.
  # Use `uv run --python 3.9` for 3.9 testing (see header comment).
  versions = {
    py310 = pkgs.python310; # Older compatibility testing
    py311 = pkgs.python311; # Claude SDK development
    py312 = pkgs.python312; # General development, testing
    py313 = pkgs.python3; # Latest features (system default)
  };

  # Reusable package sets for different development contexts
  # These are functions that take a package set (ps) and return a list
  # They can be combined with any Python version via withPackages
  #
  # Pattern: packageSets.NAME = ps: with ps; [ package1 package2 ... ];
  packageSets = {
    # Minimal: pip and virtualenv only (for project-specific installs via uv)
    # Used by: shells/python310 (compatibility testing)
    minimal =
      ps: with ps; [
        pip # Python package installer
        virtualenv # Virtual environment tool
      ];

    # Full development suite: testing, linting, formatting, coverage
    # Used by: shells/python312 (backwards compat testing, pre-commit)
    full-dev =
      ps: with ps; [
        pip # Python package installer
        virtualenv # Virtual environment tool
        setuptools # Build system
        pytest # Testing framework
        ruff # Fast Python linter and formatter
        mypy # Static type checker
        black # Code formatter
        coverage # Code coverage measurement
      ];

    # Data science stack: analytical tools
    # Used by: shells/python-data/
    data-science =
      ps: with ps; [
        pip
        virtualenv
        pandas # Data manipulation
        numpy # Numerical computing
        scipy # Scientific computing
        jupyter # Interactive notebooks
      ];
  };

  # Helper function: Create Python environment with specified packages
  # Syntax: withPackages(pythonVersion, packageSet)
  # Example: withPackages(versions.py312, packageSets.full-dev)
  withPackages = python: packages: python.withPackages packages;
}
