#\!/usr/bin/env bats
# Test auto-claude.sh argument parsing

@test "auto-claude.sh: requires 2 arguments" {
  run bash /Users/jevans/git/nix-config/test-add-bats/modules/home-manager/ai-cli/claude/auto-claude.sh
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "auto-claude.sh: rejects non-existent directory" {
  run bash /Users/jevans/git/nix-config/test-add-bats/modules/home-manager/ai-cli/claude/auto-claude.sh /nonexistent 10.0
  [ "$status" -eq 1 ]
  [[ "$output" =~ "does not exist" ]]
}

@test "auto-claude.sh: rejects invalid budget" {
  TEST_DIR=$(mktemp -d)
  mkdir -p "$TEST_DIR/test"
  run bash /Users/jevans/git/nix-config/test-add-bats/modules/home-manager/ai-cli/claude/auto-claude.sh "$TEST_DIR/test" "invalid"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "must be a positive number" ]]
  rm -rf "$TEST_DIR"
}
