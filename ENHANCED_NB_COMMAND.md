# Enhanced `wyx nb` Command - Integration Summary

## 📝 Overview

The `wyx nb` (new branch) command has been enhanced with safe branch creation logic from your `create_branch.sh` script. It now intelligently handles existing branches (both local and remote) and provides interactive prompts for pushing changes.

---

## 🔄 What Changed

### Files Modified:
1. **src/commands/nb.sh** - Complete rewrite with safety checks
2. **src/data/arg_scripts.csv** - Updated command description
3. **src/data/.cache/cmdinfo.git.wyx** - Updated cache
4. **src/data/.cache/cmdinfo.term.wyx** - Updated cache

---

## ✨ New Features

### 1. **Branch Name Validation**

The command now automatically validates branch names against nemo-core naming conventions **before** creating branches. This prevents creating branches with invalid names that would fail CI checks later.

#### Valid Branch Name Patterns:

**Pattern 1: Standard feature/bug/tech branches**
```bash
feature/NEMO2-12345_description
bug/NEMOAR-123_fix-something
tech/NEMONE-42_upgrade-deps
```

**Pattern 2: Update branches with paths**
```bash
update/PROFSD-789/path/to/file
```

**Pattern 3: Release branches (ticket-only format)**
```bash
NEMO2-12345-Release-Name
```

#### Validation Checks:

✅ **Length**: Max 100 characters  
✅ **Git technical rules**: No spaces, `..`, trailing `/`, etc.  
✅ **Prefix validation**: Must use valid prefixes (feature, bug, tech, update, etc.)  
✅ **Ticket format**: Validates ticket numbers (NEMO2, NEMOAR, NEMONE, NEMOIT, NEMOME, PROFSD, NEMO)  
✅ **Description format**: Must start with underscore `_` after ticket number  

#### Example Validation Errors:

```bash
# Invalid: No ticket number
wyx nb feature/my-new-feature
# ✗ Missing ticket number. Format: feature/TICKET-NUMBER_description

# Invalid: Wrong prefix
wyx nb bugfix/NEMO2-123_fix
# ✗ Invalid prefix 'bugfix'. Valid: feature bug feat tech update copilot revert hotfix spike
# ✗ Did you mean 'bug/' instead of 'bugfix/'?

# Invalid: Too long
wyx nb "feature/NEMO2-12345_this-is-a-really-really-really-long-name-that-exceeds-maximum-length"
# ✗ Branch name too long: 124 chars (max: 100)

# Invalid: Missing underscore before description
wyx nb feature/NEMO2-123-description
# ✗ Description must start with underscore: feature/NEMO2-123_description

# Valid examples that pass validation
wyx nb feature/NEMO2-12345_add-new-feature      # ✓ Standard feature
wyx nb bug/NEMOAR-789_fix-login-bug             # ✓ Bug fix
wyx nb tech/NEMONE-42_upgrade-dependencies      # ✓ Technical task
wyx nb update/PROFSD-100/src/components         # ✓ Update with path
```

#### Validation Flow:

When you run `wyx nb <branch-name>`, the validation happens **first**:

```
wyx nb feature/my-branch
    ↓
[1] Validate branch name
    ├─ Check length (≤100 chars)
    ├─ Check Git technical rules
    ├─ Check nemo-core conventions
    └─ Check ticket format & prefix
    ↓
[2] If validation PASSES → Proceed with branch creation
    ↓
[3] If validation FAILS → Show errors and exit
```

This prevents you from creating branches that would fail CI validation later, saving time and avoiding rework.

---

### 2. **Smart Branch Detection**

The command now checks three scenarios before creating a branch:

#### Scenario A: Branch Exists Locally
```bash
wyx nb feature/my-branch
```
**Output:**
```
Branch exists locally. Checking out...
✓ Switched to branch 'feature/my-branch'
Would you like to push it? [y/N]
```

- Checks out the existing branch
- Optionally commits and pushes if you choose

#### Scenario B: Branch Exists on Remote
```bash
wyx nb feature/remote-branch
```
**Output:**
```
Branch exists on remote. Tracking...
✓ Switched to a new branch 'feature/remote-branch'
Branch 'feature/remote-branch' set up to track 'origin/feature/remote-branch'
```

- Creates local branch tracking the remote
- No commit/push needed (already on remote)

#### Scenario C: New Branch (Doesn't Exist Anywhere)
```bash
wyx nb feature/brand-new-feature
```
**Output:**
```
Creating new branch 'feature/brand-new-feature'...
✓ Branch created successfully

Would you like to commit and push now? [y/N]
```

- Creates the branch locally
- Asks if you want to commit and push immediately
- If you say 'N', you can push later with `wyx push`

### 3. **Interactive Prompts**

Instead of automatically committing and pushing (old behavior), the new command asks for confirmation:

- **For existing local branches:** "Would you like to push it?"
- **For new branches:** "Would you like to commit and push now?"

This prevents accidental pushes and gives you more control.

### 4. **Safe Error Handling**

- Validates branch name before attempting creation
- Checks for conflicts with existing branches
- Provides clear, colored output for each scenario

---

## 🆚 Comparison: Old vs New

### Old `wyx nb` Behavior:
```bash
wyx nb my-branch
# ❌ Always creates new branch (even if exists)
# ❌ Always commits immediately
# ❌ Always pushes to remote
# ❌ No checks for existing branches
```

### New `wyx nb` Behavior:
```bash
wyx nb my-branch
# ✅ Checks if branch exists locally
# ✅ Checks if branch exists on remote
# ✅ Asks before committing
# ✅ Asks before pushing
# ✅ Provides clear feedback
```

---

## 🎯 Usage Examples

### Example 1: Creating a Feature Branch
```bash
cd ~/SpringerNature/Projects/nemo

# Create new feature branch
wyx nb feature/NEMOAR-200-new-feature

# Output:
# Creating new branch 'feature/NEMOAR-200-new-feature'...
# ✓ Branch created successfully
# 
# Would you like to commit and push now? [y/N]
# > n

# Work on your code...
vim src/app.js

# Later, when ready to push:
wyx push
```

### Example 2: Switching to Existing Local Branch
```bash
# Try to create a branch that already exists locally
wyx nb feature/existing-branch

# Output:
# Branch exists locally. Checking out...
# ✓ Switched to branch 'feature/existing-branch'
# Would you like to push it? [y/N]
# > y

# If 'y', commits and pushes any changes
```

### Example 3: Tracking Remote Branch
```bash
# Try to create a branch that exists on GitHub
wyx nb feature/NEMOAR-150-from-teammate

# Output:
# Branch exists on remote. Tracking...
# ✓ Switched to a new branch 'feature/NEMOAR-150-from-teammate'
# Branch set up to track 'origin/feature/NEMOAR-150-from-teammate'
```

### Example 4: Interactive Branch Name
```bash
# Call without arguments for prompt
wyx nb

# Output:
# Provide a branch name:
# > feature/NEMOAR-201-fix-bug

# Then proceeds with branch creation
```

---

## 🔧 Technical Details

### Command Flow:

```
wyx nb <branch-name>
    │
    ├─> Branch exists locally?
    │   ├─ YES → Checkout + Ask to push
    │   └─ NO  → Continue
    │
    ├─> Branch exists on remote?
    │   ├─ YES → Create local tracking branch
    │   └─ NO  → Continue
    │
    └─> Create new branch
        └─> Ask to commit and push
```

### Integration with WYX-CLI:

The enhanced command uses WYX-CLI's built-in functions:
- `sys.log.info` - Info messages (blue)
- `sys.log.warn` - Warning messages (yellow)
- `sys.log.error` - Error messages (red)
- `sys.log.success` - Success messages (green)
- `sys.log.h1` - Headers
- `wgit.commit` - Smart commit (uses OpenCode if enabled)
- `wyxd.arggt` - Argument validation

---

## 📚 Related Commands

The enhanced `wyx nb` works well with other WYX commands:

```bash
# Create branch (new behavior - interactive)
wyx nb feature/my-feature

# Push later when ready
wyx push

# Create branch AND pull request (still auto-pushes)
wyx bpr feature/quick-pr

# View branch on GitHub
wyx branch

# Open pull request
wyx pr
```

---

## 🚀 Quick Reference

| Scenario | Command | What Happens |
|----------|---------|--------------|
| New branch | `wyx nb feature/new` | Creates locally, asks to push |
| Local exists | `wyx nb feature/existing` | Checks out, asks to push |
| Remote exists | `wyx nb feature/remote` | Tracks remote branch |
| No name | `wyx nb` | Prompts for branch name |

---

## 💡 Tips

1. **Use feature/ prefix**: The command works with any branch name, but using prefixes like `feature/`, `bugfix/`, `hotfix/` helps organize branches

2. **Say 'N' when experimenting**: When creating a new branch to test something, say 'N' to the push prompt. You can always push later with `wyx push`

3. **Smart commits**: If you have `USE_OPENCODE_COMMIT=true`, the commit step will use OpenCode to generate a smart commit message

4. **Combine with other commands**:
   ```bash
   wyx nb feature/my-feature  # Create branch
   # ... do work ...
   wyx push                    # Push when ready
   wyx pr                      # Open pull request
   ```

---

## 🔄 Backward Compatibility

### Breaking Changes:
- ⚠️ `wyx nb` no longer automatically commits and pushes
- ⚠️ Now requires user confirmation for push operations

### Migration:
If you have scripts or workflows that rely on the old automatic behavior of `wyx nb`, you can:

**Option 1:** Use the interactive prompts and type 'y'
```bash
wyx nb feature/branch
# Press 'y' when asked
```

**Option 2:** Use the full workflow manually
```bash
git checkout -b feature/branch
wyx push
```

**Option 3:** Use `wyx bpr` for automatic branch creation + PR
```bash
wyx bpr feature/branch  # Creates, commits, pushes, opens PR
```

---

## ✅ Testing

To test the enhanced command:

```bash
cd ~/SpringerNature/Projects/nemo

# Test 1: Create new branch with valid name
wyx nb feature/NEMO2-99999_test-new-branch
# Should pass validation and create branch
# Say 'n' to push prompt
# Verify: git branch | grep feature/NEMO2-99999_test-new-branch

# Test 2: Try invalid name (no ticket)
wyx nb feature/my-branch
# Should FAIL validation with error about missing ticket

# Test 3: Try invalid name (wrong prefix)
wyx nb bugfix/NEMO2-123_fix
# Should FAIL validation suggesting 'bug/' instead

# Test 4: Try invalid name (too long)
wyx nb "feature/NEMO2-12345_this-is-a-really-really-really-long-name-that-exceeds-maximum-character-limit"
# Should FAIL validation with length error

# Test 5: Try to create same branch again (should detect existing)
wyx nb feature/NEMO2-99999_test-new-branch
# Should say "Branch exists locally"

# Test 6: Create and push with valid name
wyx nb feature/NEMO2-99998_test-push-branch
# Should pass validation
# Say 'y' to push prompt
# Verify on GitHub

# Clean up
git checkout main
git branch -D feature/NEMO2-99999_test-new-branch feature/NEMO2-99998_test-push-branch
```

---

## 📝 Summary

The `wyx nb` command is now safer and more intelligent:

✅ **Validates branch names** against nemo-core conventions before creation  
✅ Checks for existing branches (local and remote)  
✅ Prevents accidental overwrites  
✅ Interactive confirmation for push operations  
✅ Clear, colored feedback with helpful error messages  
✅ Integrates with WYX-CLI logging system  
✅ Maintains compatibility with OpenCode smart commits  
✅ Prevents CI failures by catching invalid branch names early  

**Ready to use!** The changes are integrated into your WYX-CLI installation.
