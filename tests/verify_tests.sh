#!/bin/bash

# Verification script to ensure all tests are properly set up

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  Test Suite Verification"
echo "=========================================="
echo ""

# Check if test files exist
echo "Checking test files..."
files=(
  "tests/cache_cleanup.bats"
  "tests/run_tests_simple.sh"
  "tests/integration_test.sh"
  "tests/test_helpers.sh"
  "tests/README.md"
  "tests/TESTING.md"
  "tests/TEST_SUMMARY.md"
)

all_exist=true
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo -e "${GREEN}✓${NC} $file exists"
  else
    echo -e "${RED}✗${NC} $file missing"
    all_exist=false
  fi
done

echo ""
echo "Checking executability..."
exec_files=(
  "tests/run_tests_simple.sh"
  "tests/integration_test.sh"
  "tests/test_helpers.sh"
)

for file in "${exec_files[@]}"; do
  if [ -x "$file" ]; then
    echo -e "${GREEN}✓${NC} $file is executable"
  else
    echo -e "${YELLOW}!${NC} $file is not executable (fixing...)"
    chmod +x "$file"
  fi
done

echo ""
echo "Checking test script for..."
if [ -f "cache_cleanup.sh" ]; then
  echo -e "${GREEN}✓${NC} cache_cleanup.sh exists"
else
  echo -e "${RED}✗${NC} cache_cleanup.sh not found"
  all_exist=false
fi

echo ""
echo "Checking BATS installation..."
if command -v bats >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} BATS is installed ($(bats --version))"
  can_run_bats=true
else
  echo -e "${YELLOW}!${NC} BATS is not installed"
  echo "  Install with: sudo apt-get install bats (Ubuntu/Debian)"
  echo "  or: brew install bats-core (macOS)"
  can_run_bats=false
fi

echo ""
echo "Test file statistics..."
if [ -f "tests/cache_cleanup.bats" ]; then
  test_count=$(grep -c "^@test" tests/cache_cleanup.bats)
  echo "  BATS tests: $test_count"
fi

if [ -f "tests/run_tests_simple.sh" ]; then
  simple_count=$(grep -c "run_test" tests/run_tests_simple.sh)
  echo "  Simple tests: $simple_count"
fi

echo ""
echo "=========================================="
if $all_exist; then
  echo -e "${GREEN}All test files are present!${NC}"
else
  echo -e "${RED}Some files are missing!${NC}"
  exit 1
fi

echo ""
echo "Ready to run tests:"
echo "  1. Simple tests:  ./tests/run_tests_simple.sh"
if $can_run_bats; then
  echo "  2. BATS tests:    bats tests/cache_cleanup.bats"
else
  echo "  2. BATS tests:    (install BATS first)"
fi
echo "  3. Integration:   ./tests/integration_test.sh"
echo "=========================================="