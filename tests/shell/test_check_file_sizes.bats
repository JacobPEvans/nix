#!/usr/bin/env bats
# Test check-file-sizes.sh functionality
# Script reads .file-size.yml from cwd, with built-in defaults matching shared workflow

SCRIPT_UNDER_TEST="$BATS_TEST_DIRNAME/../../scripts/workflows/check-file-sizes.sh"

setup() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR" || exit 1
  # No .file-size.yml — script uses built-in defaults:
  # warn=6144, error=12288, scan=[.md,.nix,.tf], exempt=[CHANGELOG]
}

teardown() {
  cd /
  rm -rf "$TEST_DIR"
}

@test "accepts small files (< 6KB)" {
  head -c 5120 /dev/zero > small.md
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ "warning" ]]
  [[ ! "$output" =~ "error" ]]
}

@test "warns for medium files (6KB-12KB)" {
  head -c 8192 /dev/zero > medium.md
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "::warning" ]]
  [[ "$output" =~ "medium.md" ]]
}

@test "errors for oversized files (> 12KB)" {
  head -c 16384 /dev/zero > large.md
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "::error" ]]
  [[ "$output" =~ "large.md" ]]
}

@test "extended files allowed up to 32KB via .file-size.yml" {
  head -c 20480 /dev/zero > extended.md
  cat > .file-size.yml <<'YAML'
extended:
  limit: 32768
  files:
    - extended
YAML
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ "::error" ]]
}

@test "extended files error beyond 32KB" {
  head -c 40960 /dev/zero > extended.md
  cat > .file-size.yml <<'YAML'
extended:
  limit: 32768
  files:
    - extended
YAML
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "::error" ]]
  [[ "$output" =~ "extended.md" ]]
}

@test "exempt files are skipped (additive to CHANGELOG default)" {
  head -c 20480 /dev/zero > exempt.md
  cat > .file-size.yml <<'YAML'
exempt:
  - exempt
YAML
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ "exempt.md" ]]
}

@test "CHANGELOG is exempt by default (no .file-size.yml needed)" {
  head -c 20480 /dev/zero > CHANGELOG.md
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ "CHANGELOG" ]]
}

@test "checks .md and .nix files" {
  head -c 16384 /dev/zero > config.nix
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "config.nix" ]]
}

@test "counts multiple errors correctly" {
  head -c 16384 /dev/zero > file1.md
  head -c 16384 /dev/zero > file2.md
  head -c 16384 /dev/zero > file3.nix
  run bash "$SCRIPT_UNDER_TEST"
  [ "$status" -eq 3 ]
}
