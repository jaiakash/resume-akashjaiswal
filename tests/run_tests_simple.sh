#!/bin/bash

# Simple test runner for cache_cleanup.sh
# This script can run basic tests without requiring BATS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_CLEANUP="${SCRIPT_DIR}/cache_cleanup.sh"
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test result tracking
print_test_header() {
  echo "=================================="
  echo "Testing: $1"
  echo "=================================="
}

run_test() {
  local test_name="$1"
  local test_command="$2"
  local expected_result="${3:-0}"
  
  TEST_COUNT=$((TEST_COUNT + 1))
  echo -n "Test ${TEST_COUNT}: ${test_name} ... "
  
  if eval "$test_command" >/dev/null 2>&1; then
    local result=0
  else
    local result=$?
  fi
  
  if [ "$result" -eq "$expected_result" ]; then
    echo -e "${GREEN}PASS${NC}"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo -e "${RED}FAIL${NC}"
    echo "  Expected exit code: $expected_result, got: $result"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# Verify script exists
if [ ! -f "$CACHE_CLEANUP" ]; then
  echo -e "${RED}ERROR: cache_cleanup.sh not found at ${CACHE_CLEANUP}${NC}"
  exit 1
fi

print_test_header "Basic Functionality Tests"

# Test 1: Script is readable
run_test "Script file exists and is readable" "[ -r '$CACHE_CLEANUP' ]"

# Test 2: Help flag works
run_test "Help flag (-h) works" "bash '$CACHE_CLEANUP' -h | grep -q 'Usage'"

# Test 3: Help with --help
run_test "Help flag (--help) works" "bash '$CACHE_CLEANUP' --help | grep -q 'Usage'"

# Test 4: Dry-run mode
run_test "Dry-run mode executes without errors" "bash '$CACHE_CLEANUP' -d"

# Test 5: Browser cache flag
run_test "Browser cache flag works" "bash '$CACHE_CLEANUP' -d -b"

# Test 6: Package manager cache flag
run_test "Package manager flag works" "bash '$CACHE_CLEANUP' -d -p"

# Test 7: Thumbnail flag
run_test "Thumbnail cache flag works" "bash '$CACHE_CLEANUP' -d -t"

# Test 8: All caches flag
run_test "All caches flag works" "bash '$CACHE_CLEANUP' -d -a"

# Test 9: Size reporting flag
run_test "Size reporting flag works" "bash '$CACHE_CLEANUP' -s"

# Test 10: Verbose mode
run_test "Verbose mode works" "bash '$CACHE_CLEANUP' -v -d"

print_test_header "Flag Combination Tests"

# Test 11: Multiple flags
run_test "Combine dry-run and verbose" "bash '$CACHE_CLEANUP' -d -v"

# Test 12: All flags together
run_test "Combine all compatible flags" "bash '$CACHE_CLEANUP' -d -v -s -a"

# Test 13: Browser and package manager
run_test "Combine browser and package flags" "bash '$CACHE_CLEANUP' -d -b -p"

print_test_header "Error Handling Tests"

# Test 14: Invalid flag should fail or show error
run_test "Invalid flag handling" "bash '$CACHE_CLEANUP' --invalid-flag 2>&1 | grep -qi 'invalid\|unknown\|error'" 0

# Test 15: Script runs without arguments
run_test "Script runs with no arguments" "bash '$CACHE_CLEANUP'"

print_test_header "Output Format Tests"

# Test 16: Help contains all major options
run_test "Help contains -h option" "bash '$CACHE_CLEANUP' -h | grep -q '\-h'"

# Test 17: Help contains -d option
run_test "Help contains -d option" "bash '$CACHE_CLEANUP' -h | grep -q '\-d'"

# Test 18: Help contains -b option
run_test "Help contains -b option" "bash '$CACHE_CLEANUP' -h | grep -q '\-b'"

# Test 19: Help contains -p option
run_test "Help contains -p option" "bash '$CACHE_CLEANUP' -h | grep -q '\-p'"

# Test 20: Help contains -a option
run_test "Help contains -a option" "bash '$CACHE_CLEANUP' -h | grep -q '\-a'"

print_test_header "Test Summary"
echo "=================================="
echo "Total tests: $TEST_COUNT"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
  echo -e "${RED}Failed: $FAIL_COUNT${NC}"
else
  echo "Failed: $FAIL_COUNT"
fi
echo "=================================="

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi