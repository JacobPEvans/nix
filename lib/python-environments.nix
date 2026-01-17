# Python Development Environments
#
# Shared, modular definitions for Python versions and package configurations.
# This module supports multiple Python versions (3.9, 3.12, 3.13) with
# reusable package sets that can be composed into development shells.
#
# Used by: modules/common/packages.nix, shells/*/flake.nix
#
# Design goals:
# - DRY: Define each Python version and package set once
# - Composable: Shells import only what they need
# - Modular: Can add/remove versions independently without affecting others
# - Documented: Clear separation of concern for backwards compatibility testing

{ pkgs }:

{
  # Python versions available across all environments
  # Each version is defined once here and referenced everywhere
  # Format: pyXY = pkgs.pythonXY for easy lookup
  versions = {
    py39 = pkgs.python39; # Splunk development, backwards compatibility
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
    # Used by: shells/python39 (Splunk dev - install SDK per-project)
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
    # Used by: potential shells/python-data/
    # (Currently in shells/python-data/flake.nix as hardcoded example)
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
