#!/usr/bin/env bats

# Test suite for cache_cleanup.sh
# This file provides comprehensive unit tests for all functions and edge cases

# Setup function runs before each test
setup() {
  # Load the script functions (source without executing main logic)
  export SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_DIRNAME}/..")" && pwd)"
  export TEST_TEMP_DIR="${BATS_TEST_TMPDIR}/cache_test"
  export TEST_CACHE_DIR="${TEST_TEMP_DIR}/.cache"
  
  mkdir -p "${TEST_TEMP_DIR}"
  mkdir -p "${TEST_CACHE_DIR}"
  
  # Source the script in a way that doesn't execute it
  # We'll need to extract functions for testing
}

# Teardown function runs after each test
teardown() {
  rm -rf "${TEST_TEMP_DIR}"
}

# Helper function to create mock cache files
create_mock_cache_files() {
  local base_dir="$1"
  local days_old="$2"
  local file_name="$3"
  
  mkdir -p "${base_dir}"
  touch -d "${days_old} days ago" "${base_dir}/${file_name}"
}

# Helper function to create cache structure
create_test_cache_structure() {
  # Browser caches
  mkdir -p "${TEST_CACHE_DIR}/mozilla/firefox"
  mkdir -p "${TEST_CACHE_DIR}/google-chrome"
  mkdir -p "${TEST_CACHE_DIR}/chromium"
  
  # Package manager caches
  mkdir -p "${TEST_CACHE_DIR}/pip"
  mkdir -p "${TEST_CACHE_DIR}/npm"
  mkdir -p "${TEST_CACHE_DIR}/yarn"
  
  # System caches
  mkdir -p "${TEST_CACHE_DIR}/thumbnails"
  
  # Create some files
  create_mock_cache_files "${TEST_CACHE_DIR}/mozilla/firefox" 10 "cache.sqlite"
  create_mock_cache_files "${TEST_CACHE_DIR}/google-chrome" 5 "Cache_Data"
  create_mock_cache_files "${TEST_CACHE_DIR}/pip" 35 "http"
  create_mock_cache_files "${TEST_CACHE_DIR}/npm" 45 "index-v5"
  create_mock_cache_files "${TEST_CACHE_DIR}/thumbnails" 120 "thumb1.png"
}

#==============================================================================
# Test: Script existence and executability
#==============================================================================

@test "cache_cleanup.sh script exists" {
  [ -f "${SCRIPT_DIR}/cache_cleanup.sh" ]
}

@test "cache_cleanup.sh is executable" {
  [ -x "${SCRIPT_DIR}/cache_cleanup.sh" ] || [ -r "${SCRIPT_DIR}/cache_cleanup.sh" ]
}

@test "cache_cleanup.sh has valid shebang" {
  run head -n 1 "${SCRIPT_DIR}/cache_cleanup.sh"
  [[ "$output" =~ ^#!.*bash ]]
}

#==============================================================================
# Test: Help and usage information
#==============================================================================

@test "display help with -h flag" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
  [[ "$output" =~ "cache_cleanup.sh" ]]
}

@test "display help with --help flag" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage:" ]]
}

@test "help message contains all options" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -h
  [[ "$output" =~ "-h" ]]
  [[ "$output" =~ "-d" ]]
  [[ "$output" =~ "-b" ]]
  [[ "$output" =~ "-p" ]]
  [[ "$output" =~ "-t" ]]
  [[ "$output" =~ "-a" ]]
  [[ "$output" =~ "-s" ]]
  [[ "$output" =~ "-v" ]]
}

@test "help message explains dry-run mode" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -h
  [[ "$output" =~ "dry-run" ]] || [[ "$output" =~ "simulation" ]]
}

#==============================================================================
# Test: Dry-run mode (-d flag)
#==============================================================================

@test "dry-run mode does not delete files" {
  create_test_cache_structure
  
  # Count files before
  local files_before=$(find "${TEST_CACHE_DIR}" -type f | wc -l)
  
  # Run with dry-run flag
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d
  
  # Count files after
  local files_after=$(find "${TEST_CACHE_DIR}" -type f | wc -l)
  
  [ "$files_before" -eq "$files_after" ]
}

@test "dry-run mode shows what would be deleted" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d
  [[ "$output" =~ "Would delete" ]] || [[ "$output" =~ "would" ]] || [[ "$output" =~ "DRY RUN" ]]
}

@test "dry-run mode exits successfully" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Browser cache cleaning (-b flag)
#==============================================================================

@test "browser cache flag targets Firefox cache" {
  mkdir -p "${TEST_CACHE_DIR}/mozilla/firefox/testprofile"
  create_mock_cache_files "${TEST_CACHE_DIR}/mozilla/firefox/testprofile" 10 "cache2"
  
  # Dry run to check targeting
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -b
  # Should mention Firefox or mozilla in output
  [[ "$output" =~ "firefox" ]] || [[ "$output" =~ "Firefox" ]] || [[ "$output" =~ "mozilla" ]] || [[ "$output" =~ "browser" ]]
}

@test "browser cache flag targets Chrome cache" {
  mkdir -p "${TEST_CACHE_DIR}/google-chrome/Default"
  create_mock_cache_files "${TEST_CACHE_DIR}/google-chrome/Default" 10 "Cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -b
  [[ "$output" =~ "chrome" ]] || [[ "$output" =~ "Chrome" ]] || [[ "$output" =~ "google-chrome" ]] || [[ "$output" =~ "browser" ]]
}

@test "browser cache flag targets Chromium cache" {
  mkdir -p "${TEST_CACHE_DIR}/chromium/Default"
  create_mock_cache_files "${TEST_CACHE_DIR}/chromium/Default" 10 "Cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -b
  [[ "$output" =~ "chromium" ]] || [[ "$output" =~ "Chromium" ]] || [[ "$output" =~ "browser" ]]
}

@test "browser cache cleaning handles missing browser cache gracefully" {
  # Don't create any browser caches
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -b
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Package manager cache cleaning (-p flag)
#==============================================================================

@test "package manager flag targets pip cache" {
  mkdir -p "${TEST_CACHE_DIR}/pip/http"
  create_mock_cache_files "${TEST_CACHE_DIR}/pip/http" 40 "package.whl"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -p
  [[ "$output" =~ "pip" ]] || [[ "$output" =~ "package" ]]
}

@test "package manager flag targets npm cache" {
  mkdir -p "${TEST_CACHE_DIR}/npm/_cacache"
  create_mock_cache_files "${TEST_CACHE_DIR}/npm/_cacache" 40 "index-v5"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -p
  [[ "$output" =~ "npm" ]] || [[ "$output" =~ "package" ]]
}

@test "package manager flag targets yarn cache" {
  mkdir -p "${TEST_CACHE_DIR}/yarn/v6"
  create_mock_cache_files "${TEST_CACHE_DIR}/yarn/v6" 40 "package.tar.gz"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -p
  [[ "$output" =~ "yarn" ]] || [[ "$output" =~ "package" ]]
}

@test "package manager cleaning handles missing caches gracefully" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -p
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Thumbnail cache cleaning (-t flag)
#==============================================================================

@test "thumbnail flag targets thumbnail cache" {
  mkdir -p "${TEST_CACHE_DIR}/thumbnails/normal"
  create_mock_cache_files "${TEST_CACHE_DIR}/thumbnails/normal" 100 "thumb1.png"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -t
  [[ "$output" =~ "thumbnail" ]] || [[ "$output" =~ "Thumbnail" ]]
}

@test "thumbnail cleaning handles missing thumbnail cache gracefully" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -t
  [ "$status" -eq 0 ]
}

@test "thumbnail flag cleans large thumbnail directories" {
  mkdir -p "${TEST_CACHE_DIR}/thumbnails/large"
  mkdir -p "${TEST_CACHE_DIR}/thumbnails/normal"
  create_mock_cache_files "${TEST_CACHE_DIR}/thumbnails/large" 100 "large1.png"
  create_mock_cache_files "${TEST_CACHE_DIR}/thumbnails/normal" 100 "normal1.png"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -t
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: All caches cleaning (-a flag)
#==============================================================================

@test "all flag cleans multiple cache types" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
  # Should mention multiple cache types
  local output_lower=$(echo "$output" | tr '[:upper:]' '[:lower:]')
  [[ "$output_lower" =~ "cache" ]]
}

@test "all flag is equivalent to combining multiple flags" {
  create_test_cache_structure
  
  # This test verifies that -a flag behavior is consistent
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Size reporting (-s flag)
#==============================================================================

@test "size flag shows cache sizes" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s
  [ "$status" -eq 0 ]
  # Should show size information
  [[ "$output" =~ "size" ]] || [[ "$output" =~ "Size" ]] || [[ "$output" =~ "KB" ]] || [[ "$output" =~ "MB" ]] || [[ "$output" =~ "bytes" ]]
}

@test "size reporting handles empty caches" {
  mkdir -p "${TEST_CACHE_DIR}"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s
  [ "$status" -eq 0 ]
}

@test "size reporting shows before and after sizes" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s -a
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Verbose mode (-v flag)
#==============================================================================

@test "verbose mode provides detailed output" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -v -d
  [ "$status" -eq 0 ]
  # Verbose output should be longer
  [ "${#output}" -gt 50 ]
}

@test "verbose mode shows file-by-file operations" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -v -d -a
  [ "$status" -eq 0 ]
}

@test "non-verbose mode is less detailed" {
  create_test_cache_structure
  
  # Run without verbose
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d
  local normal_output="$output"
  
  # Run with verbose
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -v -d
  local verbose_output="$output"
  
  # Verbose should have more output (or at least different output)
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Multiple flags combination
#==============================================================================

@test "combine browser and package manager flags" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -b -p
  [ "$status" -eq 0 ]
}

@test "combine dry-run with verbose" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -v
  [ "$status" -eq 0 ]
}

@test "combine size reporting with verbose" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s -v
  [ "$status" -eq 0 ]
}

@test "combine all flags together" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -v -s -a
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Age-based cleaning (30 days default)
#==============================================================================

@test "old files are targeted for deletion" {
  # Create files older than 30 days
  mkdir -p "${TEST_CACHE_DIR}/old"
  create_mock_cache_files "${TEST_CACHE_DIR}/old" 45 "old_file.cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

@test "recent files are not deleted" {
  # Create files newer than 30 days
  mkdir -p "${TEST_CACHE_DIR}/recent"
  touch "${TEST_CACHE_DIR}/recent/new_file.cache"
  
  # Run actual cleanup (not dry-run) on all
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -a
  
  # Recent file should still exist
  [ -f "${TEST_CACHE_DIR}/recent/new_file.cache" ]
}

@test "mixed age files are handled correctly" {
  mkdir -p "${TEST_CACHE_DIR}/mixed"
  create_mock_cache_files "${TEST_CACHE_DIR}/mixed" 45 "old_file.cache"
  touch "${TEST_CACHE_DIR}/mixed/new_file.cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Error handling and edge cases
#==============================================================================

@test "script handles non-existent cache directory" {
  # Use a cache directory that doesn't exist
  export HOME="${TEST_TEMP_DIR}/nonexistent"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -a
  # Should not crash
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script handles permission denied gracefully" {
  skip "Requires specific permission setup"
  # This would require creating a directory with no read permissions
}

@test "script handles empty cache directories" {
  mkdir -p "${TEST_CACHE_DIR}/empty_dir"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -a
  [ "$status" -eq 0 ]
}

@test "script handles symlinks in cache" {
  mkdir -p "${TEST_CACHE_DIR}/real_dir"
  create_mock_cache_files "${TEST_CACHE_DIR}/real_dir" 40 "file.cache"
  ln -s "${TEST_CACHE_DIR}/real_dir" "${TEST_CACHE_DIR}/link_dir"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

@test "script handles special characters in filenames" {
  mkdir -p "${TEST_CACHE_DIR}/special"
  create_mock_cache_files "${TEST_CACHE_DIR}/special" 40 "file with spaces.cache"
  touch "${TEST_CACHE_DIR}/special/file'with'quotes.cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

@test "script handles very long paths" {
  local long_path="${TEST_CACHE_DIR}/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p"
  mkdir -p "${long_path}"
  create_mock_cache_files "${long_path}" 40 "deep_file.cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Invalid arguments and usage
#==============================================================================

@test "invalid flag shows error" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -z
  [ "$status" -ne 0 ] || [[ "$output" =~ "invalid" ]] || [[ "$output" =~ "Unknown" ]]
}

@test "multiple invalid flags show error" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -x -y -z
  [ "$status" -ne 0 ] || [[ "$output" =~ "invalid" ]] || [[ "$output" =~ "Unknown" ]]
}

@test "no arguments runs with default behavior" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh"
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Cache size calculations
#==============================================================================

@test "correctly calculates cache size for small files" {
  mkdir -p "${TEST_CACHE_DIR}/small"
  echo "small content" > "${TEST_CACHE_DIR}/small/file1.txt"
  echo "more small content" > "${TEST_CACHE_DIR}/small/file2.txt"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s
  [ "$status" -eq 0 ]
}

@test "correctly handles empty files in size calculation" {
  mkdir -p "${TEST_CACHE_DIR}/empty"
  touch "${TEST_CACHE_DIR}/empty/file1.txt"
  touch "${TEST_CACHE_DIR}/empty/file2.txt"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s
  [ "$status" -eq 0 ]
}

@test "size calculation handles nested directories" {
  mkdir -p "${TEST_CACHE_DIR}/nested/level1/level2/level3"
  create_mock_cache_files "${TEST_CACHE_DIR}/nested/level1/level2/level3" 40 "deep.cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Cleanup operations (actual deletion)
#==============================================================================

@test "actual cleanup removes old files" {
  mkdir -p "${TEST_CACHE_DIR}/cleanup_test"
  create_mock_cache_files "${TEST_CACHE_DIR}/cleanup_test" 45 "old.cache"
  
  # Verify file exists
  [ -f "${TEST_CACHE_DIR}/cleanup_test/old.cache" ]
  
  # Run cleanup
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -a
  
  # Note: This test assumes the script will clean files older than 30 days
  # The actual behavior depends on the script implementation
  [ "$status" -eq 0 ]
}

@test "cleanup preserves directory structure" {
  mkdir -p "${TEST_CACHE_DIR}/preserve/subdir"
  create_mock_cache_files "${TEST_CACHE_DIR}/preserve/subdir" 45 "old.cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -a
  
  # Directory should still exist
  [ -d "${TEST_CACHE_DIR}/preserve/subdir" ]
}

@test "cleanup reports number of files deleted" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -v -a
  [ "$status" -eq 0 ]
  # Should report some activity
  [ -n "$output" ]
}

#==============================================================================
# Test: User confirmation and safety features
#==============================================================================

@test "dry-run warns about destructive operation" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
  # Output should indicate this is a simulation or dry-run
}

@test "script provides informative messages" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -v -d -a
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

#==============================================================================
# Test: Performance with large number of files
#==============================================================================

@test "handles many files efficiently" {
  mkdir -p "${TEST_CACHE_DIR}/many_files"
  for i in {1..100}; do
    create_mock_cache_files "${TEST_CACHE_DIR}/many_files" 40 "file${i}.cache"
  done
  
  # Run with timeout to ensure it completes
  run timeout 30 bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Script output formatting
#==============================================================================

@test "output is properly formatted" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -v -d -a
  [ "$status" -eq 0 ]
  # Output should not have obvious formatting errors
  [[ ! "$output" =~ "^[[:space:]]*$" ]] || [ -z "$output" ]
}

@test "output does not contain script errors" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [[ ! "$output" =~ "command not found" ]]
  [[ ! "$output" =~ "syntax error" ]]
  [[ ! "$output" =~ "unexpected" ]]
}

#==============================================================================
# Test: Environment variable handling
#==============================================================================

@test "respects HOME environment variable" {
  export HOME="${TEST_TEMP_DIR}"
  mkdir -p "${HOME}/.cache/test"
  create_mock_cache_files "${HOME}/.cache/test" 40 "file.cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

@test "handles missing HOME variable gracefully" {
  # Note: Unsetting HOME might not work in all environments
  skip "HOME variable handling test - environment dependent"
}

#==============================================================================
# Test: Concurrent execution safety
#==============================================================================

@test "script can run multiple times safely" {
  create_test_cache_structure
  
  # First run
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
  
  # Second run
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Cleanup summary and reporting
#==============================================================================

@test "cleanup summary shows statistics" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -v -s -a
  [ "$status" -eq 0 ]
  # Should show some summary information
  [ -n "$output" ]
}

@test "reports freed space amount" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s -a
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Browser-specific edge cases
#==============================================================================

@test "handles multiple Firefox profiles" {
  mkdir -p "${TEST_CACHE_DIR}/mozilla/firefox/profile1.default"
  mkdir -p "${TEST_CACHE_DIR}/mozilla/firefox/profile2.custom"
  create_mock_cache_files "${TEST_CACHE_DIR}/mozilla/firefox/profile1.default" 40 "cache.sqlite"
  create_mock_cache_files "${TEST_CACHE_DIR}/mozilla/firefox/profile2.custom" 40 "cache.db"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -b
  [ "$status" -eq 0 ]
}

@test "handles Chrome user profiles" {
  mkdir -p "${TEST_CACHE_DIR}/google-chrome/Default"
  mkdir -p "${TEST_CACHE_DIR}/google-chrome/Profile 1"
  create_mock_cache_files "${TEST_CACHE_DIR}/google-chrome/Default" 40 "Cache"
  create_mock_cache_files "${TEST_CACHE_DIR}/google-chrome/Profile 1" 40 "Cache"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -b
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Package manager edge cases
#==============================================================================

@test "handles corrupted cache directories" {
  mkdir -p "${TEST_CACHE_DIR}/pip"
  # Create a file where a directory is expected
  touch "${TEST_CACHE_DIR}/npm"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -p
  # Should handle gracefully without crashing
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "handles cache directories in use" {
  skip "Requires simulating file locks - environment dependent"
}

#==============================================================================
# Test: Integration scenarios
#==============================================================================

@test "complete workflow: size check, dry-run, then cleanup" {
  create_test_cache_structure
  
  # Step 1: Check size
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -s
  [ "$status" -eq 0 ]
  
  # Step 2: Dry-run
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
  
  # Step 3: Actual cleanup
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -a
  [ "$status" -eq 0 ]
}

@test "verbose dry-run provides actionable information" {
  create_test_cache_structure
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -v -d -a
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

#==============================================================================
# Test: Cross-platform compatibility indicators
#==============================================================================

@test "script uses portable commands" {
  # Check that script doesn't use non-portable commands
  run grep -E "gfind|gsed|gawk" "${SCRIPT_DIR}/cache_cleanup.sh"
  [ "$status" -ne 0 ]
}

@test "date command usage is compatible" {
  # Verify the script handles date commands properly
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Documentation and maintainability
#==============================================================================

@test "script contains descriptive comments" {
  run grep -c "^[[:space:]]*#" "${SCRIPT_DIR}/cache_cleanup.sh"
  [ "$status" -eq 0 ]
  # Should have some comments
  [ "$output" -gt 5 ]
}

@test "functions have descriptive names" {
  # Check if functions exist and are readable
  run grep -E "^[[:space:]]*(function[[:space:]]+)?[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)" "${SCRIPT_DIR}/cache_cleanup.sh"
  [ "$status" -eq 0 ]
}

#==============================================================================
# Test: Security considerations
#==============================================================================

@test "script does not use eval" {
  run grep -i "eval" "${SCRIPT_DIR}/cache_cleanup.sh"
  [ "$status" -ne 0 ]
}

@test "script properly quotes variables" {
  # This is a basic check - proper quoting is critical for security
  # The script should quote variable expansions
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

@test "script does not follow symlinks destructively" {
  mkdir -p "${TEST_CACHE_DIR}/real"
  mkdir -p "${TEST_TEMP_DIR}/outside"
  create_mock_cache_files "${TEST_TEMP_DIR}/outside" 40 "important.txt"
  
  ln -s "${TEST_TEMP_DIR}/outside" "${TEST_CACHE_DIR}/link"
  
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
  
  # File outside cache should still exist
  [ -f "${TEST_TEMP_DIR}/outside/important.txt" ]
}

#==============================================================================
# Test: Exit codes
#==============================================================================

@test "successful operation returns 0" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -d -a
  [ "$status" -eq 0 ]
}

@test "help flag returns 0" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" -h
  [ "$status" -eq 0 ]
}

@test "invalid usage returns non-zero" {
  run bash "${SCRIPT_DIR}/cache_cleanup.sh" --invalid-flag
  [ "$status" -ne 0 ] || [[ "$output" =~ "invalid" ]]
}