#!/bin/bash

# Script to check if toolbox has uncommitted changes

TOOLBOX_DIR="$HOME/SpringerNature/Scripts/toolbox"

cd "$TOOLBOX_DIR" || exit 1

echo "Checking toolbox git status..."
echo ""

# Check if there are any changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "⚠️  Toolbox has uncommitted changes!"
    echo ""
    echo "Modified/Deleted files:"
    git diff --name-status | head -20
    echo ""
    
    # Check for untracked files (excluding ignored ones)
    UNTRACKED=$(git ls-files --others --exclude-standard)
    if [ ! -z "$UNTRACKED" ]; then
        echo "New untracked files:"
        echo "$UNTRACKED" | head -20
        echo ""
    fi
    
    echo "To commit these changes:"
    echo "  cd $TOOLBOX_DIR"
    echo "  git add -A"
    echo "  git commit -m 'Update toolbox scripts'"
    echo "  git push"
    echo ""
    exit 1
else
    # Check if there are untracked files
    UNTRACKED=$(git ls-files --others --exclude-standard)
    if [ ! -z "$UNTRACKED" ]; then
        echo "⚠️  Toolbox has new untracked files:"
        echo "$UNTRACKED" | head -20
        echo ""
        echo "To add these files:"
        echo "  cd $TOOLBOX_DIR"
        echo "  git add <files>"
        echo "  git commit -m 'Add new toolbox features'"
        echo "  git push"
        echo ""
        exit 1
    fi
    
    echo "✓ Toolbox working tree is clean"
    exit 0
fi
