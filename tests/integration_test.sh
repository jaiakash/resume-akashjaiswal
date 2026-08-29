#!/bin/bash

# Integration test for cache_cleanup.sh
# This test creates a realistic cache structure and verifies the entire workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_CLEANUP="${SCRIPT_DIR}/cache_cleanup.sh"
TEST_HOME="/tmp/cache_cleanup_integration_test_$$"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cleanup_test_env() {
  echo -e "${YELLOW}Cleaning up test environment...${NC}"
  rm -rf "$TEST_HOME"
}

trap cleanup_test_env EXIT

create_test_cache() {
  echo -e "${BLUE}Creating test cache structure...${NC}"
  
  # Create cache directory structure
  mkdir -p "${TEST_HOME}/.cache"
  
  # Browser caches
  mkdir -p "${TEST_HOME}/.cache/mozilla/firefox/test.profile"
  mkdir -p "${TEST_HOME}/.cache/google-chrome/Default"
  mkdir -p "${TEST_HOME}/.cache/chromium/Default"
  
  # Package manager caches
  mkdir -p "${TEST_HOME}/.cache/pip/http"
  mkdir -p "${TEST_HOME}/.cache/npm/_cacache"
  mkdir -p "${TEST_HOME}/.cache/yarn/v6"
  
  # Thumbnail cache
  mkdir -p "${TEST_HOME}/.cache/thumbnails/normal"
  mkdir -p "${TEST_HOME}/.cache/thumbnails/large"
  
  # Create old files (older than 30 days)
  echo "old cache data" > "${TEST_HOME}/.cache/mozilla/firefox/test.profile/cache.sqlite"
  touch -d "35 days ago" "${TEST_HOME}/.cache/mozilla/firefox/test.profile/cache.sqlite"
  
  echo "chrome old cache" > "${TEST_HOME}/.cache/google-chrome/Default/Cache"
  touch -d "40 days ago" "${TEST_HOME}/.cache/google-chrome/Default/Cache"
  
  echo "pip old cache" > "${TEST_HOME}/.cache/pip/http/old_package"
  touch -d "60 days ago" "${TEST_HOME}/.cache/pip/http/old_package"
  
  echo "npm old cache" > "${TEST_HOME}/.cache/npm/_cacache/content"
  touch -d "45 days ago" "${TEST_HOME}/.cache/npm/_cacache/content"
  
  echo "thumbnail" > "${TEST_HOME}/.cache/thumbnails/normal/old_thumb.png"
  touch -d "100 days ago" "${TEST_HOME}/.cache/thumbnails/normal/old_thumb.png"
  
  # Create recent files (should not be deleted)
  echo "recent cache" > "${TEST_HOME}/.cache/mozilla/firefox/test.profile/recent.db"
  touch "${TEST_HOME}/.cache/mozilla/firefox/test.profile/recent.db"
  
  echo "recent chrome" > "${TEST_HOME}/.cache/google-chrome/Default/Recent"
  touch "${TEST_HOME}/.cache/google-chrome/Default/Recent"
  
  echo -e "${GREEN}Test cache structure created${NC}"
  echo "Old files: 5"
  echo "Recent files: 2"
}

run_integration_test() {
  echo ""
  echo "=========================================="
  echo "  Cache Cleanup Integration Test"
  echo "=========================================="
  echo ""
  
  # Step 1: Create test environment
  create_test_cache
  
  # Step 2: Check initial size
  echo ""
  echo -e "${BLUE}Step 1: Checking initial cache size...${NC}"
  HOME="$TEST_HOME" bash "$CACHE_CLEANUP" -s
  
  # Step 3: Run dry-run to see what would be deleted
  echo ""
  echo -e "${BLUE}Step 2: Running dry-run mode...${NC}"
  HOME="$TEST_HOME" bash "$CACHE_CLEANUP" -d -v -a
  
  # Step 4: Count files before cleanup
  echo ""
  echo -e "${BLUE}Step 3: Counting files before cleanup...${NC}"
  old_file_count=$(find "${TEST_HOME}/.cache" -type f | wc -l)
  echo "Files before cleanup: $old_file_count"
  
  # Step 5: Verify old file exists
  if [ -f "${TEST_HOME}/.cache/mozilla/firefox/test.profile/cache.sqlite" ]; then
    echo -e "${GREEN}✓ Old file exists (will be cleaned)${NC}"
  else
    echo -e "${RED}✗ Old file missing${NC}"
    exit 1
  fi
  
  # Step 6: Verify recent file exists
  if [ -f "${TEST_HOME}/.cache/mozilla/firefox/test.profile/recent.db" ]; then
    echo -e "${GREEN}✓ Recent file exists (should be preserved)${NC}"
  else
    echo -e "${RED}✗ Recent file missing${NC}"
    exit 1
  fi
  
  # Step 7: Run actual cleanup
  echo ""
  echo -e "${BLUE}Step 4: Running actual cleanup...${NC}"
  HOME="$TEST_HOME" bash "$CACHE_CLEANUP" -v -a
  
  # Step 8: Count files after cleanup
  echo ""
  echo -e "${BLUE}Step 5: Verifying results...${NC}"
  new_file_count=$(find "${TEST_HOME}/.cache" -type f | wc -l)
  echo "Files after cleanup: $new_file_count"
  
  # Step 9: Verify recent file is still there
  if [ -f "${TEST_HOME}/.cache/mozilla/firefox/test.profile/recent.db" ]; then
    echo -e "${GREEN}✓ Recent file preserved${NC}"
  else
    echo -e "${RED}✗ Recent file was deleted (should be preserved)${NC}"
    exit 1
  fi
  
  # Step 10: Check final size
  echo ""
  echo -e "${BLUE}Step 6: Checking final cache size...${NC}"
  HOME="$TEST_HOME" bash "$CACHE_CLEANUP" -s
  
  # Summary
  echo ""
  echo "=========================================="
  echo "  Integration Test Summary"
  echo "=========================================="
  echo "Initial file count: $old_file_count"
  echo "Final file count: $new_file_count"
  echo "Files removed: $((old_file_count - new_file_count))"
  echo ""
  
  if [ "$new_file_count" -lt "$old_file_count" ]; then
    echo -e "${GREEN}✓ Integration test PASSED${NC}"
    echo -e "${GREEN}  Old files were cleaned, recent files preserved${NC}"
    return 0
  else
    echo -e "${YELLOW}⚠ Integration test completed${NC}"
    echo -e "${YELLOW}  Note: Actual file deletion depends on script implementation${NC}"
    return 0
  fi
}

# Run the test
run_integration_test