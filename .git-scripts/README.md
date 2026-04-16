# Git Scripts for Toolbox

This directory contains scripts for managing the toolbox git repository.

## Scripts

### check-status.sh

Checks if the toolbox has uncommitted changes or untracked files.

```bash
.git-scripts/check-status.sh
```

**Output:**
- ✓ Clean working tree
- ⚠️ Uncommitted changes or untracked files

## Git Hooks

### post-commit

Automatically runs `check-status.sh` after each commit to verify the working tree is clean.

## Automation

The toolbox is also checked daily via `~/.config/zsh/scripts/daily-git-check.sh` which runs once per day when you open a new shell.

## Usage

When you make changes to toolbox scripts:

1. Test your changes
2. Commit them:
   ```bash
   cd ~/SpringerNature/Scripts/toolbox
   git add -A
   git commit -m "Description of changes"
   git push
   ```

The post-commit hook will automatically verify the commit was successful.
