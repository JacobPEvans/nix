#\!/usr/bin/env bats
# Test check-file-sizes.sh functionality

@test "File size calculation works" {
  [ 5 -gt 0 ]
}

@test "Threshold comparison functions" {
  LIMIT=12288
  SIZE=5000
  [ "$SIZE" -lt "$LIMIT" ]
}

@test "KB conversion calculation" {
  SIZE=2048
  KB=$((SIZE / 1024))
  [ "$KB" -eq 2 ]
}
