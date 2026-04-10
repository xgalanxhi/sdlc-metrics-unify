#!/bin/bash

# CloudBees Unify Metrics - Setup Validation Script

echo "🔍 Validating Repository Setup..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

checks_passed=0
checks_failed=0

# Function to check if a file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((checks_passed++))
    else
        echo -e "${RED}✗${NC} $1 - Missing"
        ((checks_failed++))
    fi
}

# Function to check if a directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        ((checks_passed++))
    else
        echo -e "${RED}✗${NC} $1/ - Missing"
        ((checks_failed++))
    fi
}

echo "📁 Checking Repository Structure..."
check_dir "src"
check_dir "tests"
check_dir ".github/workflows"
check_file "package.json"
check_file ".github/workflows/ci-cd.yml"
check_file "README.md"
check_file "QUICKSTART.md"
echo ""

echo "🧪 Running Tests..."
if npm test > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Unit tests passing"
    ((checks_passed++))
else
    echo -e "${RED}✗${NC} Unit tests failing"
    ((checks_failed++))
fi
echo ""

echo "📋 Running Linter..."
if npm run lint > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} No linting errors"
    ((checks_passed++))
else
    echo -e "${YELLOW}⚠${NC} Linting warnings/errors found (non-blocking)"
    ((checks_passed++))
fi
echo ""

echo "📊 Validation Summary"
echo "===================="
echo -e "Passed: ${GREEN}$checks_passed${NC}"
echo -e "Failed: ${RED}$checks_failed${NC}"
echo ""

if [ $checks_failed -eq 0 ]; then
    echo -e "${GREEN}✅ Repository is ready to use!${NC}"
    echo ""
    echo "Next Steps:"
    echo "1. Push to GitHub: git add . && git commit -m 'Initial commit' && git push"
    echo "2. Create develop branch: git checkout -b develop && git push -u origin develop"
    echo "3. Configure CloudBees Unify (see QUICKSTART.md)"
    echo "4. Watch metrics flow in!"
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Please review the errors above.${NC}"
    exit 1
fi
