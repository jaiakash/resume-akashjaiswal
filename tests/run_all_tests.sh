#!/bin/bash

# Master test runner - runs all resume validation tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "  LaTeX Resume - Master Test Runner"
echo "=========================================="
echo ""

total_failures=0

# Run main test suite
echo -e "${BLUE}Running main test suite...${NC}"
echo ""
if ./test_resume.sh; then
  echo -e "\n${GREEN}✓ Main test suite passed${NC}\n"
else
  echo -e "\n${RED}✗ Main test suite failed${NC}\n"
  total_failures=$((total_failures + 1))
fi

# Run content validation
echo -e "${BLUE}Running content validation...${NC}"
echo ""
if ./validate_resume_content.sh; then
  echo -e "\n${GREEN}✓ Content validation passed${NC}\n"
else
  echo -e "\n${RED}✗ Content validation failed${NC}\n"
  total_failures=$((total_failures + 1))
fi

# Summary
echo "=========================================="
echo "  Final Summary"
echo "=========================================="
if [ $total_failures -eq 0 ]; then
  echo -e "${GREEN}✓ All test suites passed!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Compile to PDF: xelatex main.tex"
  echo "  2. Review the generated PDF"
  echo "  3. Make any final adjustments"
  exit 0
else
  echo -e "${RED}✗ $total_failures test suite(s) failed${NC}"
  echo ""
  echo "Please review the output above and fix the issues."
  exit 1
fi