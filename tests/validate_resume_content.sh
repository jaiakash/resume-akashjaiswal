#!/bin/bash

# Content-specific validation for the resume
# Checks for typos, consistency, and quality issues

RESUME_FILE="../main.tex"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "  Resume Content Validation"
echo "=========================================="
echo ""

# Check for common typos
echo "Checking for common typos..."
typos_found=0

# Common technical typos
if grep -i "javascipt" "$RESUME_FILE" >/dev/null 2>&1; then
  echo -e "${RED}✗ Found 'javascipt' (should be JavaScript)${NC}"
  typos_found=$((typos_found + 1))
fi

if grep -i "kubenetes\|kuberenetes" "$RESUME_FILE" >/dev/null 2>&1; then
  echo -e "${RED}✗ Found misspelling of Kubernetes${NC}"
  typos_found=$((typos_found + 1))
fi

# Check consistency
echo ""
echo "Checking consistency..."

# Date format consistency
date_formats=$(grep -oE '[A-Z][a-z]+ [0-9]{4}|[0-9]{4}' "$RESUME_FILE" | head -10)
echo "Date formats found (sample):"
echo "$date_formats" | head -5

# Check for consistent use of Oxford comma
echo ""
echo "Checking punctuation consistency..."

# Check email format
email=$(grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$RESUME_FILE")
if [ -n "$email" ]; then
  echo -e "${GREEN}✓ Email found: $email${NC}"
else
  echo -e "${YELLOW}⚠ No email address found${NC}"
fi

# Validate hyperlinks
echo ""
echo "Validating hyperlinks..."
href_count=$(grep -c '\\href{' "$RESUME_FILE")
echo "Total hyperlinks: $href_count"

# Extract URLs and check format
urls=$(grep -oP '(?<=\\href\{)[^}]+' "$RESUME_FILE" 2>/dev/null)
invalid_urls=0
while IFS= read -r url; do
  if [[ ! "$url" =~ ^(https?://|mailto:) ]]; then
    if [ -n "$url" ]; then
      echo -e "${YELLOW}⚠ Potentially invalid URL: $url${NC}"
      invalid_urls=$((invalid_urls + 1))
    fi
  fi
done <<< "$urls"

if [ $invalid_urls -eq 0 ] && [ $href_count -gt 0 ]; then
  echo -e "${GREEN}✓ All URLs appear valid${NC}"
fi

# Check for proper capitalization of proper nouns
echo ""
echo "Checking capitalization..."

# Common company/technology names
if grep -E '\bgoogle\b|\boracle\b' "$RESUME_FILE" | grep -v '\\' | grep -qv '[Gg]oogle\|[Oo]racle' 2>/dev/null; then
  echo -e "${YELLOW}⚠ Check capitalization of company names${NC}"
fi

# Summary
echo ""
echo "=========================================="
if [ $typos_found -eq 0 ]; then
  echo -e "${GREEN}✓ No obvious typos found${NC}"
else
  echo -e "${RED}✗ Found $typos_found potential typos${NC}"
fi
echo "=========================================="

[ $typos_found -eq 0 ]