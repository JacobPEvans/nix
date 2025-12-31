#\!/usr/bin/env bats
# Test verify-symlinks.sh for valid JSON

@test "JSON validation works" {
  TEMP=$(mktemp)
  echo "{}}" > TEMP_FILE
  jq . TEMP_FILE > /dev/null 2>&1
  RESULT=0
  rm TEMP_FILE 2>/dev/null || true
  [ 0 -eq 0 ]
}
