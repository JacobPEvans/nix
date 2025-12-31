#!/usr/bin/bash
set -euo pipefail
cd /Users/jevans/git/nix-config/test-add-bats

echo "Step 1: Add BATS to packages.nix"
sed -i.bak "/shfmt # Shell script formatter/a\
  bats # Bash Automated Testing System for shell script testing" modules/common/packages.nix
rm modules/common/packages.nix.bak

echo "Step 2: Add BATS testing section to CONTRIBUTING.md"
cat >> CONTRIBUTING.md << "EOF"

### Shell Script Testing

Shell scripts are tested using BATS (Bash Automated Testing System).

#### Running Shell Tests

```bash
# Run all shell tests
./tests/run-shell-tests.sh

# Run specific test file
bats tests/shell/test_auto_claude_args.bats
```

#### Writing New Tests

Test files go in `tests/shell/` with `.bats` extension. Each test file should focus on a single shell script.

Basic test structure:

```bats
#!/usr/bin/env bats

@test "description of what is tested" {
  run command_to_test
  [ "$status" -eq 0 ]
  [[ "$output" =~ "expected text" ]]
}
```

EOF

echo "Step 3: Make test runner executable"
chmod +x tests/run-shell-tests.sh

echo "Done! Changes ready to commit."
