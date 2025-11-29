# Testing Guide for cache_cleanup.sh

This document provides comprehensive information about testing the cache cleanup script.

## Test Files

### 1. `cache_cleanup.bats`
- **Type**: BATS unit tests
- **Test Count**: 100+ test cases
- **Requirements**: BATS testing framework
- **Purpose**: Comprehensive unit testing of all script functionality

### 2. `run_tests_simple.sh`
- **Type**: Shell script test runner
- **Test Count**: 20 basic tests
- **Requirements**: bash, standard Unix utilities
- **Purpose**: Quick smoke tests without external dependencies

### 3. `integration_test.sh`
- **Type**: Integration test
- **Test Count**: 1 comprehensive workflow
- **Requirements**: bash, standard Unix utilities
- **Purpose**: End-to-end testing of the complete workflow

## Quick Start

### Option 1: Run Simple Tests (No Dependencies)
```bash
cd tests
./run_tests_simple.sh
```

### Option 2: Run BATS Tests (Recommended)
```bash
# Install BATS first
sudo apt-get install bats  # Ubuntu/Debian
# or
brew install bats-core     # macOS

# Run tests
bats tests/cache_cleanup.bats
```

### Option 3: Run Integration Test
```bash
cd tests
./integration_test.sh
```

## Running All Tests

```bash
# Run simple tests
./tests/run_tests_simple.sh

# Run BATS tests (if BATS is installed)
if command -v bats >/dev/null 2>&1; then
  bats tests/cache_cleanup.bats
fi

# Run integration test
./tests/integration_test.sh
```

## Test Categories

### 1. Basic Functionality (20 tests)
- Script existence and permissions
- Help system
- Command-line argument parsing
- Basic flag operations

### 2. Cache Type Tests (15 tests)
- Browser cache cleaning (Firefox, Chrome, Chromium)
- Package manager cache (pip, npm, yarn)
- Thumbnail cache
- All cache types

### 3. Mode Tests (10 tests)
- Dry-run mode
- Verbose mode
- Size reporting mode
- Combinations

### 4. Edge Cases (25 tests)
- Empty directories
- Non-existent paths
- Special characters in filenames
- Symlinks
- Very long paths
- Multiple profiles
- Mixed age files

### 5. Error Handling (15 tests)
- Invalid arguments
- Missing directories
- Permission issues
- Corrupted structures

### 6. Safety & Security (10 tests)
- Dry-run safety
- Variable quoting
- Symlink handling
- No destructive operations outside cache

### 7. Integration Tests (5 tests)
- Complete workflows
- Before/after verification
- Size calculations
- Reporting accuracy

## Test Output Examples

### Successful Test Run