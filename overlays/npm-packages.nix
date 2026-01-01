# NPM Package Overlays
#
# Custom npm packages not available in nixpkgs.
# This allows us to package npm tools as Nix derivations.
#
# How overlays work:
# - `final` = the final package set (after all overlays applied)
# - `prev` = the previous package set (before this overlay)
# - We return an attrset of packages to add/override

_final: prev: {
  # cclint: Fast, extensible linter for CLAUDE.md context files
  # Source: https://github.com/felixgeelhaar/cclint
  # NPM: @felixgeelhaar/cclint
  # Validates CLAUDE.md files against Anthropic best practices
  # Uses npx to always get the latest version without manual hash updates
  cclint = prev.writeShellScriptBin "cclint" ''
    exec ${prev.nodejs}/bin/npx --yes @felixgeelhaar/cclint "$@"
  '';

  # ccusage: Claude Code usage analyzer
  # Source: https://github.com/ryoppippi/ccusage
  # NPM: ccusage
  # Analyzes Claude Code usage from local JSONL files
  # Uses npx to always get the latest version without manual hash updates
  ccusage = prev.writeShellScriptBin "ccusage" ''
    exec ${prev.nodejs}/bin/npx --yes ccusage@latest "$@"
  '';
}
