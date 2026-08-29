# Quick Reference - LaTeX Resume Testing

## One-Command Test Execution

```bash
cd tests && ./run_all_tests.sh
```

## Individual Test Commands

| Command | Purpose | Tests |
|---------|---------|-------|
| `./test_resume.sh` | Main validation suite | 50+ |
| `./validate_resume_content.sh` | Content-specific checks | 10+ |
| `./verify_tests.sh` | Verify test installation | 5 |

## What Each Test Checks

### test_resume.sh (Main Suite)

#### ✅ Critical Validations
- LaTeX document structure valid
- All braces balanced
- Required sections present
- No placeholder text
- Valid email and contact info

#### ⚠️ Quality Checks
- Professional language
- Action verbs used
- Quantifiable achievements
- Consistent formatting
- Proper typography

#### 🔗 Link Validation
- All URLs well-formed
- LinkedIn profile linked
- GitHub profile linked
- Email href correct

### validate_resume_content.sh

#### 📝 Content Quality
- No common typos
- Consistent terminology
- Proper capitalization
- Email format valid
- URL format valid

## Test Output Guide

### Success Output