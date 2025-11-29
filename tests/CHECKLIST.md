# Resume Testing Checklist

Use this checklist before committing changes to your resume.

## Pre-Commit Checklist

### 1. Run Automated Tests
- [ ] `./tests/run_all_tests.sh` - All tests pass
- [ ] `./tests/test_resume.sh` - Main suite passes  
- [ ] `./tests/validate_resume_content.sh` - Content validation passes

### 2. Manual Review
- [ ] All dates are current and accurate
- [ ] Contact information is up-to-date
- [ ] No typos or grammatical errors
- [ ] All hyperlinks work (click each one)
- [ ] Skills section reflects current abilities
- [ ] Job descriptions are clear and quantified

### 3. Compilation
- [ ] `xelatex main.tex` compiles without errors
- [ ] Generated PDF looks professional
- [ ] All sections fit on intended pages
- [ ] Fonts render correctly
- [ ] Links are clickable in PDF

### 4. Content Quality
- [ ] Action verbs used (Designed, Developed, Led, etc.)
- [ ] Quantifiable achievements included (percentages, numbers)
- [ ] No first-person pronouns (I, me, my)
- [ ] Professional tone throughout
- [ ] Consistent formatting

### 5. Technical Accuracy
- [ ] Technology names spelled correctly
- [ ] Company names capitalized properly
- [ ] Technical terms used correctly
- [ ] No outdated information

### 6. ATS Compatibility
- [ ] Standard section headings used
- [ ] No complex tables or graphics
- [ ] Keywords from job descriptions included
- [ ] Contact info in standard format

## Post-Changes Checklist

After making changes:
- [ ] Run `git diff` to review changes
- [ ] Re-run test suite
- [ ] Recompile PDF
- [ ] Compare before/after PDFs
- [ ] Test print preview

## Before Applying to Jobs

- [ ] Tailor resume to job description
- [ ] Update dates if needed
- [ ] Review company-specific requirements
- [ ] Export PDF with appropriate filename
- [ ] Test PDF opens correctly

## Quality Metrics

Your resume should:
- ✅ Pass all automated tests (50+)
- ✅ Compile without warnings
- ✅ Fit on 1-2 pages
- ✅ Have 5-7 bullet points per position
- ✅ Include 3-5 quantifiable achievements
- ✅ List 8-12 technical skills
- ✅ Have 3-5 major sections

## Red Flags to Avoid

- ❌ Typos or grammatical errors
- ❌ Broken hyperlinks
- ❌ Inconsistent date formats
- ❌ Generic descriptions
- ❌ Outdated information
- ❌ Missing contact information
- ❌ Compilation errors

## Review Frequency

- **Before every job application**: Quick review + tests
- **Monthly**: Comprehensive review and updates
- **After major projects**: Add new achievements
- **Every 6 months**: Major revision

## Testing Commands Quick Reference

```bash
# Run all tests
cd tests && ./run_all_tests.sh

# Main test suite only
./test_resume.sh

# Content validation only
./validate_resume_content.sh

# Compile PDF
xelatex main.tex

# View PDF (Linux)
xdg-open main.pdf

# View PDF (macOS)
open main.pdf
```

---

**Remember:** Quality over speed. Take time to ensure your resume is perfect!