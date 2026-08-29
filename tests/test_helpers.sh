#!/bin/bash

# Test helper functions for cache_cleanup.sh tests
# Source this file in your test scripts for common functionality

# Color definitions
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Create a mock cache directory structure
create_mock_cache_structure() {
  local base_dir="${1:-${TEST_HOME:-/tmp/cache_test}/.cache}"
  
  # Browser caches
  mkdir -p "${base_dir}/mozilla/firefox/default.profile"
  mkdir -p "${base_dir}/google-chrome/Default"
  mkdir -p "${base_dir}/chromium/Default"
  
  # Package manager caches
  mkdir -p "${base_dir}/pip/http"
  mkdir -p "${base_dir}/pip/wheels"
  mkdir -p "${base_dir}/npm/_cacache/content-v2"
  mkdir -p "${base_dir}/yarn/v6"
  
  # System caches
  mkdir -p "${base_dir}/thumbnails/normal"
  mkdir -p "${base_dir}/thumbnails/large"
  mkdir -p "${base_dir}/thumbnails/fail"
  
  echo "Created mock cache structure at ${base_dir}"
}

# Create mock files with specific ages
create_aged_file() {
  local file_path="$1"
  local days_old="$2"
  local content="${3:-mock cache data}"
  
  mkdir -p "$(dirname "$file_path")"
  echo "$content" > "$file_path"
  touch -d "${days_old} days ago" "$file_path"
}

# Create a set of test cache files
populate_test_cache() {
  local cache_dir="${1:-${TEST_HOME:-/tmp/cache_test}/.cache}"
  
  # Old files (should be cleaned)
  create_aged_file "${cache_dir}/mozilla/firefox/default.profile/cache.sqlite" 35 "firefox cache"
  create_aged_file "${cache_dir}/mozilla/firefox/default.profile/cache.db" 40 "firefox db"
  create_aged_file "${cache_dir}/google-chrome/Default/Cache_Data" 45 "chrome cache"
  create_aged_file "${cache_dir}/chromium/Default/Cache" 50 "chromium cache"
  create_aged_file "${cache_dir}/pip/http/old_package.whl" 60 "old pip package"
  create_aged_file "${cache_dir}/npm/_cacache/content-v2/sha512" 70 "old npm cache"
  create_aged_file "${cache_dir}/yarn/v6/old-package.tgz" 80 "old yarn package"
  create_aged_file "${cache_dir}/thumbnails/normal/old_thumb.png" 120 "old thumbnail"
  
  # Recent files (should be kept)
  create_aged_file "${cache_dir}/mozilla/firefox/default.profile/recent.db" 5 "recent firefox"
  create_aged_file "${cache_dir}/google-chrome/Default/Recent" 10 "recent chrome"
  create_aged_file "${cache_dir}/pip/http/recent.whl" 15 "recent pip"
  create_aged_file "${cache_dir}/thumbnails/normal/recent.png" 20 "recent thumb"
  
  echo "Populated test cache with old and recent files"
}

# Count files in a directory
count_files() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f | wc -l
  else
    echo "0"
  fi
}

# Get total size of directory
get_dir_size() {
  local dir="$1"
  if [ -d "$dir" ]; then
    du -sb "$dir" 2>/dev/null | cut -f1
  else
    echo "0"
  fi
}

# Assert file exists
assert_file_exists() {
  local file="$1"
  local message="${2:-File should exist: $file}"
  
  if [ -f "$file" ]; then
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    echo -e "${RED}✗${NC} $message"
    return 1
  fi
}

# Assert file does not exist
assert_file_not_exists() {
  local file="$1"
  local message="${2:-File should not exist: $file}"
  
  if [ ! -f "$file" ]; then
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    echo -e "${RED}✗${NC} $message"
    return 1
  fi
}

# Assert directory exists
assert_dir_exists() {
  local dir="$1"
  local message="${2:-Directory should exist: $dir}"
  
  if [ -d "$dir" ]; then
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    echo -e "${RED}✗${NC} $message"
    return 1
  fi
}

# Assert command succeeds
assert_success() {
  local command="$1"
  local message="${2:-Command should succeed}"
  
  if eval "$command" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    echo -e "${RED}✗${NC} $message (exit code: $?)"
    return 1
  fi
}

# Assert command fails
assert_failure() {
  local command="$1"
  local message="${2:-Command should fail}"
  
  if ! eval "$command" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    echo -e "${RED}✗${NC} $message (command succeeded unexpectedly)"
    return 1
  fi
}

# Assert output contains string
assert_output_contains() {
  local command="$1"
  local expected="$2"
  local message="${3:-Output should contain: $expected}"
  
  local output=$(eval "$command" 2>&1)
  if echo "$output" | grep -q "$expected"; then
    echo -e "${GREEN}✓${NC} $message"
    return 0
  else
    echo -e "${RED}✗${NC} $message"
    echo "  Got output: $output"
    return 1
  fi
}

# Setup test environment
setup_test_env() {
  export TEST_HOME="${TEST_HOME:-/tmp/cache_cleanup_test_$$}"
  export TEST_CACHE_DIR="${TEST_HOME}/.cache"
  
  mkdir -p "$TEST_HOME"
  mkdir -p "$TEST_CACHE_DIR"
  
  echo "Test environment setup at $TEST_HOME"
}

# Cleanup test environment
cleanup_test_env() {
  if [ -n "$TEST_HOME" ] && [ -d "$TEST_HOME" ]; then
    rm -rf "$TEST_HOME"
    echo "Test environment cleaned up"
  fi
}

# Print test section header
print_section() {
  local title="$1"
  echo ""
  echo "=========================================="
  echo "  $title"
  echo "=========================================="
  echo ""
}

# Print test result summary
print_summary() {
  local total="$1"
  local passed="$2"
  local failed="$3"
  
  print_section "Test Summary"
  echo "Total tests: $total"
  echo -e "${GREEN}Passed: $passed${NC}"
  if [ "$failed" -gt 0 ]; then
    echo -e "${RED}Failed: $failed${NC}"
  else
    echo "Failed: $failed"
  fi
  echo "=========================================="
  
  if [ "$failed" -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
  else
    echo -e "${RED}Some tests failed.${NC}"
  fi
}

# Export functions for use in test scripts
export -f create_mock_cache_structure
export -f create_aged_file
export -f populate_test_cache
export -f count_files
export -f get_dir_size
export -f assert_file_exists
export -f assert_file_not_exists
export -f assert_dir_exists
export -f assert_success
export -f assert_failure
export -f assert_output_contains
export -f setup_test_env
export -f cleanup_test_env
export -f print_section
export -f print_summary