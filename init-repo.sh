#!/bin/bash

# CloudBees Unify Metrics Demo - Repository Initialization Script

set -e

echo "🚀 Initializing CloudBees Unify Metrics Demo Repository"
echo "========================================================"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
    echo "✅ Git initialized"
else
    echo "✅ Git repository already initialized"
fi
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
npm install
echo "✅ Dependencies installed"
echo ""

# Run validation
echo "🧪 Running validation..."
npm test
echo "✅ Tests passed"
echo ""

# Check for GitHub remote
if git remote | grep -q "origin"; then
    echo "✅ GitHub remote already configured"
    REMOTE_URL=$(git remote get-url origin)
    echo "   Remote: $REMOTE_URL"
else
    echo "⚠️  GitHub remote not configured"
    echo ""
    read -p "Enter your GitHub repository URL (or press Enter to skip): " REPO_URL
    if [ ! -z "$REPO_URL" ]; then
        git remote add origin "$REPO_URL"
        echo "✅ Remote added: $REPO_URL"
    else
        echo "⏭️  Skipping remote configuration"
    fi
fi
echo ""

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "none")
if [ "$CURRENT_BRANCH" = "none" ]; then
    echo "📝 Creating initial commit..."
    git add .
    git commit -m "Initial commit: CloudBees Unify metrics demo

This repository demonstrates CloudBees Unify's metrics capabilities
with GitHub Actions integration.

Features:
- DORA metrics tracking
- Test results publishing
- Security scanning with CodeQL
- Artifact registration and deployment tracking
- Multi-environment deployment pipeline

See README.md for setup instructions."

    # Rename to main if needed
    DEFAULT_BRANCH=$(git config --get init.defaultBranch || echo "main")
    git branch -M "$DEFAULT_BRANCH"
    echo "✅ Initial commit created on branch: $DEFAULT_BRANCH"
    CURRENT_BRANCH="$DEFAULT_BRANCH"
fi
echo ""

# Create develop branch if it doesn't exist
if git show-ref --verify --quiet refs/heads/develop; then
    echo "✅ develop branch already exists"
else
    echo "🌿 Creating develop branch..."
    git checkout -b develop
    echo "✅ develop branch created"
    git checkout "$CURRENT_BRANCH"
fi
echo ""

echo "✨ Repository initialization complete!"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. Push to GitHub:"
echo "   git push -u origin $CURRENT_BRANCH"
echo "   git push -u origin develop"
echo ""
echo "2. Configure CloudBees Unify (see QUICKSTART.md for details):"
echo "   - Create environments (development, staging, production)"
echo "   - Set up OIDC authentication"
echo "   - Configure GitHub Actions secrets (if needed)"
echo ""
echo "3. Configure GitHub:"
echo "   - Create environments in repository settings"
echo "   - Add protection rules for production"
echo "   - Enable GitHub Actions"
echo ""
echo "4. Test the workflow:"
echo "   git checkout develop"
echo "   echo '# test' >> test.txt && git add test.txt"
echo "   git commit -m 'Test: Trigger workflow'"
echo "   git push"
echo ""
echo "5. View metrics in CloudBees Unify:"
echo "   - Analytics > Test Results"
echo "   - Analytics > DORA Metrics"
echo "   - Environment Inventory"
echo ""
echo "📚 Documentation:"
echo "   - README.md        - Complete documentation"
echo "   - QUICKSTART.md    - 10-minute setup guide"
echo "   - NOTES.md         - Implementation notes"
echo ""
echo "💡 Quick commands:"
echo "   make help          - Show available make commands"
echo "   ./validate-setup.sh - Validate repository setup"
echo "   npm test           - Run tests"
echo "   npm run lint       - Run linter"
echo ""
