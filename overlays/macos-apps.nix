# macOS Application Overlays
#
# Packages for macOS apps distributed as .dmg files that aren't in nixpkgs.
# These are extracted and installed to $out/Applications for use with
# home.packages or environment.systemPackages.
#
# To add a new app:
# 1. Get the .dmg URL from GitHub releases
# 2. Get hash: nix-prefetch-url <url>
# 3. Convert to SRI: nix hash convert --hash-algo sha256 <hash>
# 4. Add derivation below following the pattern

_final: prev: {
  # ClaudeBar: macOS menu bar app for AI coding assistant quota monitoring
  # Tracks usage across Claude, GitHub Copilot, Gemini, Codex, etc.
  # https://github.com/tddworks/ClaudeBar
  claudebar = prev.stdenvNoCC.mkDerivation rec {
    pname = "ClaudeBar";
    version = "0.3.6";

    src = prev.fetchurl {
      url = "https://github.com/tddworks/ClaudeBar/releases/download/v${version}/ClaudeBar-${version}.dmg";
      hash = "sha256-Z9FX3w7RHpiHa2xNrQmgkc7PxvNY28YYbn/Zxw4UO2s=";
    };

    nativeBuildInputs = [ prev.undmg ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r ClaudeBar.app $out/Applications/
      runHook postInstall
    '';

    meta = {
      description = "macOS menu bar app for AI coding assistant quota monitoring";
      homepage = "https://github.com/tddworks/ClaudeBar";
      license = prev.lib.licenses.mit;
      platforms = prev.lib.platforms.darwin;
      mainProgram = "ClaudeBar";
    };
  };
}
