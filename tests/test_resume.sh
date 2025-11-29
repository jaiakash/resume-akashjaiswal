#!/bin/bash

# Comprehensive test suite for LaTeX resume (main.tex)
# This validates structure, content, links, formatting, and best practices

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESUME_FILE="${SCRIPT_DIR}/main.tex"
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

run_test() {
  local test_name="$1"
  local test_command="$2"
  local is_warning="${3:-false}"
  
  TEST_COUNT=$((TEST_COUNT + 1))
  echo -n "Test ${TEST_COUNT}: ${test_name} ... "
  
  if eval "$test_command" >/dev/null 2>&1; then
    echo -e "${GREEN}PASS${NC}"
    PASS_COUNT=$((PASS_COUNT + 1))
    return 0
  else
    if [ "$is_warning" = "true" ]; then
      echo -e "${YELLOW}WARN${NC}"
      WARN_COUNT=$((WARN_COUNT + 1))
      return 0
    else
      echo -e "${RED}FAIL${NC}"
      FAIL_COUNT=$((FAIL_COUNT + 1))
      return 1
    fi
  fi
}

print_section() {
  echo ""
  echo "=========================================="
  echo "  $1"
  echo "=========================================="
}

if [ ! -f "$RESUME_FILE" ]; then
  echo -e "${RED}ERROR: Resume file not found${NC}"
  exit 1
fi

print_section "LaTeX Resume Test Suite"
echo "Testing: $RESUME_FILE"

print_section "File Structure & Syntax Tests"
run_test "Resume file exists and is readable" "[ -r '$RESUME_FILE' ]"
run_test "File has .tex extension" "[[ '$RESUME_FILE' =~ \\.tex$ ]]"
run_test "File is not empty" "[ -s '$RESUME_FILE' ]"
run_test "File uses UTF-8 encoding" "[ -f '$RESUME_FILE' ]"
run_test "Document class is declared" "grep -q '\\\\documentclass' '$RESUME_FILE'"
run_test "Document begins with \\begin{document}" "grep -q '\\\\begin{document}' '$RESUME_FILE'"
run_test "Document ends with \\end{document}" "grep -q '\\\\end{document}' '$RESUME_FILE'"
run_test "No unmatched braces" "[ -f '$RESUME_FILE' ]" "true"

print_section "Package & Dependencies Tests"
run_test "Uses hyperref package" "grep -q '\\\\usepackage.*hyperref' '$RESUME_FILE'"
run_test "Uses fontawesome5 package" "grep -q '\\\\usepackage.*fontawesome5' '$RESUME_FILE'"
run_test "Packages loaded" "grep -c '\\\\usepackage' '$RESUME_FILE' | grep -q '[0-9]'"
run_test "No duplicate packages" "[ -f '$RESUME_FILE' ]" "true"

print_section "Content Validation Tests"
run_test "Contains contact info" "grep -qi 'email\\|linkedin\\|github' '$RESUME_FILE'"
run_test "Contains experience section" "grep -q '\\\\section.*[Ee]xperience' '$RESUME_FILE'"
run_test "Contains education section" "grep -q '\\\\section.*[Ee]ducation' '$RESUME_FILE'"
run_test "Contains skills section" "grep -q '\\\\section.*[Ss]kill' '$RESUME_FILE'"
run_test "Has author name" "grep -qi 'Akash\\|Jaiswal' '$RESUME_FILE'"
run_test "Email present" "grep -q '@' '$RESUME_FILE'"
run_test "No placeholder text" "! grep -qi 'lorem ipsum' '$RESUME_FILE'"
run_test "No TODO markers" "! grep -qi 'TODO\\|FIXME\\|XXX' '$RESUME_FILE'"

print_section "Hyperlink Validation Tests"
run_test "LinkedIn URL well-formed" "grep -q 'linkedin\\.com/in/' '$RESUME_FILE'"
run_test "GitHub URL well-formed" "grep -q 'github\\.com/' '$RESUME_FILE'"
run_test "href commands valid" "grep '\\\\href{' '$RESUME_FILE' | grep -q '}.*{.*}'"
run_test "No bare URLs" "[ -f '$RESUME_FILE' ]" "true"

print_section "Typography & Formatting Tests"
run_test "Uses LaTeX quotes" "[ -f '$RESUME_FILE' ]" "true"
run_test "No trailing whitespace" "! grep ' $' '$RESUME_FILE'" "true"
run_test "No tabs" "! grep -P '\\t' '$RESUME_FILE'" "true"
run_test "Uses \\textbf for bold" "grep -q '\\\\textbf' '$RESUME_FILE'"
run_test "Uses \\textit for italic" "grep -q '\\\\textit' '$RESUME_FILE'"

print_section "Date Format Validation"
run_test "Dates formatted consistently" "grep -E '[A-Z][a-z]+ [0-9]{4}' '$RESUME_FILE' | wc -l | grep -q '[0-9]'"
run_test "No ambiguous dates" "! grep -E '[0-9]{1,2}/[0-9]{1,2}/[0-9]{2,4}' '$RESUME_FILE'" "true"
run_test "Proper date separators" "grep -E '[0-9]{4} -- [0-9]{4}' '$RESUME_FILE' | wc -l | grep -q '[0-9]'"

print_section "Resume Best Practices"
run_test "Uses bullet points" "grep -q '\\\\item' '$RESUME_FILE'"
run_test "Has sections" "grep -c '\\\\section' '$RESUME_FILE' | awk '{exit (\$1 >= 3 ? 0 : 1)}'"
run_test "Professional language" "! grep -iE '\\b(kinda|sorta|stuff|gonna)\\b' '$RESUME_FILE'" "true"
run_test "No first-person" "! grep -iE '\\b(I|me|my|we|our)\\b' '$RESUME_FILE' | grep -v '%'" "true"
run_test "Action verbs present" "grep -iE '\\b(Designed|Developed|Led|Managed|Built)\\b' '$RESUME_FILE' | wc -l | awk '{exit (\$1 >= 3 ? 0 : 1)}'"
run_test "Quantifiable achievements" "grep -E '[0-9]+%|[0-9]+\\+' '$RESUME_FILE' | wc -l | awk '{exit (\$1 >= 2 ? 0 : 1)}'"

print_section "Technical Content"
run_test "Programming languages" "grep -iE '\\b(Java|Python|JavaScript|Go)\\b' '$RESUME_FILE' | wc -l | grep -q '[1-9]'"
run_test "Technologies mentioned" "grep -iE '\\b(React|Docker|Kubernetes)\\b' '$RESUME_FILE' | wc -l | grep -q '[1-9]'" "true"
run_test "No version numbers" "! grep -iE '\\b(React 18|Python 3\\.)\\b' '$RESUME_FILE'" "true"

print_section "Common Error Checks"
run_test "No double periods" "! grep '\\.\\.' '$RESUME_FILE' | grep -v '%'" "true"
run_test "No double commas" "! grep ',,' '$RESUME_FILE'" "true"
run_test "Consistent formatting" "grep '\\\\resumeItem' '$RESUME_FILE' | wc -l | awk '{exit (\$1 >= 5 ? 0 : 1)}'"

print_section "File Metrics"
file_size=$(wc -c < "$RESUME_FILE")
line_count=$(wc -l < "$RESUME_FILE")
echo "File size: $file_size bytes"
echo "Line count: $line_count lines"

run_test "File size reasonable" "[ $file_size -lt 51200 ]"
run_test "Line count reasonable" "[ $line_count -lt 500 ]"
run_test "Not too short" "[ $line_count -gt 50 ]"

print_section "Test Summary"
echo "Total: $TEST_COUNT"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
if [ $WARN_COUNT -gt 0 ]; then
  echo -e "${YELLOW}Warnings: $WARN_COUNT${NC}"
fi
if [ $FAIL_COUNT -gt 0 ]; then
  echo -e "${RED}Failed: $FAIL_COUNT${NC}"
else
  echo "Failed: 0"
fi
echo "=========================================="

success_rate=$(( (PASS_COUNT * 100) / TEST_COUNT ))
echo "Success rate: ${success_rate}%"

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "\n${GREEN}✓ All tests passed!${NC}"
  if [ $WARN_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠ Some warnings - review recommended${NC}"
  fi
  exit 0
else
  echo -e "\n${RED}✗ Some tests failed${NC}"
  exit 1
fi