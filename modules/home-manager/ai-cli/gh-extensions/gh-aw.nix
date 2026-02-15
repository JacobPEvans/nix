{
  pkgs,
  lib,
  fetchFromGitHub,
}:

pkgs.buildGoModule rec {
  pname = "gh-aw";
  version = "0.1.0"; # Update from https://github.com/github/gh-aw/releases

  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-aw";
    rev = "v${version}"; # Use commit SHA if no tags exist
    sha256 = "sha256-dOr0H8affUFwYb6WSUlQARtAKD/iM1haBZE2dAy3FQ8=";
  };

  vendorHash = "sha256-UGKScdleZXgT4F1ezu74KpyNE1kWwr2kHqeHqD4OliE=";

  # Build from cmd/gh-aw directory
  subPackages = [ "cmd/gh-aw" ];

  # Ensure binary is named gh-aw for gh extension discovery
  postInstall = ''
    mkdir -p $out/bin
    mv $out/bin/cmd $out/bin/gh-aw 2>/dev/null || true
  '';

  meta = with lib; {
    description = "GitHub Agentic Workflows CLI extension";
    homepage = "https://github.com/github/gh-aw";
    license = licenses.mit; # Verify actual license from repo
    maintainers = [ ];
    platforms = platforms.darwin ++ platforms.linux;
  };
}
