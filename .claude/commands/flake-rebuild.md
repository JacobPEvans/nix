# Flake Rebuild

Update all flake inputs and rebuild nix-darwin.

## Steps

1. Update flake.lock with latest versions: `nix flake update`
2. Rebuild and switch: `sudo darwin-rebuild switch --flake ~/.config/nix`
3. Report what was updated (check git diff on flake.lock)
