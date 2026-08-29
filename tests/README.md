# LaTeX Resume Test Suite

This directory contains comprehensive tests for validating the LaTeX resume (`main.tex`).

## Overview

The test suite validates:
- LaTeX syntax and structure
- Content quality and completeness
- Typography and formatting
- Hyperlinks and URLs
- Resume best practices
- Common errors and typos

## Test Files

### 1. `test_resume.sh`
Main test suite with 50+ validation checks covering:
- File structure and syntax
- LaTeX packages and dependencies
- Content validation (sections, contact info)
- Hyperlink validation
- Typography and formatting
- Date formats
- Resume best practices
- Technical content
- Common errors
- Spell checking (if aspell available)
- LaTeX syntax validation (if chktex available)
- File metrics

### 2. `validate_resume_content.sh`
Content-specific validation focusing on:
- Common typos
- Consistency checks
- Punctuation
- Email format
- URL validation
- Capitalization of proper nouns

## Running the Tests

### Quick Start
```bash
cd tests
./test_resume.sh
```

### Run All Tests
```bash
# Main test suite
./test_resume.sh

# Content validation
./validate_resume_content.sh
```

### Prerequisites

**Required:**
- Bash shell
- Python 3 (for brace matching validation)
- Standard Unix utilities (grep, sed, awk, wc)

**Optional (recommended):**
- `aspell` - For spell checking
  ```bash
  sudo apt-get install aspell aspell-en  # Ubuntu/Debian
  brew install aspell                     # macOS
  ```

- `chktex` - For LaTeX syntax validation
  ```bash
  sudo apt-get install chktex  # Ubuntu/Debian
  brew install chktex          # macOS
  ```

## Test Categories

### ✅ Critical Tests (Must Pass)
- File exists and is readable
- Valid LaTeX document structure
- Balanced braces
- Required sections present
- No placeholder text

### ⚠️ Warning Tests (Should Pass)
- Spell check
- Typography consistency
- Professional language
- LaTeX linting

## Understanding Test Output

```bash
Test 1: Resume file exists and is readable ... PASS
Test 2: File has .tex extension ... PASS
Test 3: Contains experience section ... PASS
...
Test 25: No first-person pronouns ... WARN
```

- **PASS** (Green): Test passed successfully
- **WARN** (Yellow): Non-critical issue detected
- **FAIL** (Red): Critical issue that should be fixed

## Compilation Testing

While these tests validate structure and content, you should also compile the resume to PDF:

```bash
# Using XeLaTeX (recommended for this resume)
xelatex main.tex

# Or using pdfLaTeX
pdflatex main.tex
```

## Common Issues and Solutions

### Issue: "chktex not found"
**Solution:** Install chktex or the test will skip LaTeX linting
```bash
sudo apt-get install chktex
```

### Issue: "aspell not found"
**Solution:** Install aspell or the test will skip spell checking
```bash
sudo apt-get install aspell aspell-en
```

### Issue: "Unmatched braces"
**Solution:** Check that all `{` have matching `}` and vice versa

### Issue: "No email address found"
**Solution:** Ensure your resume includes a proper email address

### Issue: "Spell check warnings"
**Solution:** Review flagged words - they may be technical terms or proper nouns

## Continuous Integration

### GitHub Actions Example
```yaml
name: Validate Resume

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y aspell aspell-en chktex python3
      
      - name: Run tests
        run: |
          cd tests
          ./test_resume.sh
          ./validate_resume_content.sh
      
      - name: Compile PDF
        run: |
          sudo apt-get install -y texlive-xetex texlive-fonts-extra
          xelatex main.tex
      
      - name: Upload PDF
        uses: actions/upload-artifact@v2
        with:
          name: resume-pdf
          path: main.pdf
```

## Best Practices

1. **Run tests before committing** to catch issues early
2. **Fix all FAIL results** before pushing
3. **Review WARN results** - they indicate potential improvements
4. **Test compilation** in addition to running validation tests
5. **Keep tests updated** as you modify the resume structure

## Test Coverage

| Category | Tests | Description |
|----------|-------|-------------|
| Structure | 8 | LaTeX document structure |
| Packages | 4 | Package dependencies |
| Content | 8 | Required sections and content |
| Hyperlinks | 5+ | URL validation |
| Typography | 8 | Formatting consistency |
| Dates | 3 | Date format validation |
| Best Practices | 6 | Resume quality checks |
| Technical | 3 | Technical content validation |
| Errors | 6 | Common error detection |
| Spelling | 1 | Spell checking |
| Syntax | 1 | LaTeX syntax validation |
| Metrics | 3 | File size and complexity |

**Total: 50+ automated tests**

## Customization

To add custom tests, edit `test_resume.sh`:

```bash
run_test "Your test description" "your_test_command"
```

Example:
```bash
run_test "Contains phone number" "grep -E '\+?[0-9]{10,}' '$RESUME_FILE'"
```

## Troubleshooting

### Tests fail after making changes
1. Review the specific test that failed
2. Check the file for the reported issue
3. Fix the issue
4. Run tests again

### False positives
Some tests may flag valid content (e.g., technical terms in spell check). Review warnings carefully.

### Python not found
The test suite requires Python 3 for brace matching. Install it:
```bash
sudo apt-get install python3  # Ubuntu/Debian
brew install python3          # macOS
```

## Contributing

When adding new content to the resume:
1. Run the test suite
2. Fix any failures
3. Consider adding new tests for new sections
4. Update documentation if needed

## Resources

- [LaTeX Documentation](https://www.latex-project.org/help/documentation/)
- [Resume Best Practices](https://www.indeed.com/career-advice/resumes-cover-letters)
- [chktex Manual](https://www.nongnu.org/chktex/)
- [aspell Documentation](http://aspell.net/)

## License

Tests are provided as-is for validating the resume structure and content.