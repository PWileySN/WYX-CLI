# 🔧 Proposed Changes: WYX-CLI Nemo Project Integration

## Overview
Adapt WYX-CLI to work seamlessly with Springer Nature's Nemo project requirements:
1. **Branch name validation** before creating branches
2. **JIRA-ID prefixed commit messages** for all commits
3. **Auto-detection** of Nemo project context

---

## 📋 Current Nemo Project Requirements

### Branch Naming Convention
**Pattern:** `type/JIRA-ID_description`

**Valid Types:**
- `feature/` - New features
- `bug/` - Bug fixes
- `feat/` - Alternative to feature
- `tech/` - Technical improvements
- `update/` - Dependency updates

**Valid JIRA Prefixes:**
- `NEMO2-XXXXX`
- `PROFSD-XXXXX`
- `NEMO3A-XXXXX`
- `NEMOME-XXXXX`
- `NEMONE-XXXXX`
- `NEMOAR-XXXXX`
- `NEMOIT-XXXXX`
- `NEMOSME-XXXXX`

**Examples:**
```bash
✅ feature/NEMO2-12345_add-authentication
✅ bug/NEMOIT-5678_fix-memory-leak
✅ tech/PROFSD-999_upgrade-dependencies
✅ feat/NEMONE-42_new-dashboard
✅ update/NEMO2-123/steward/lib/all
✅ NEMOAR-123-Release-Name
```

### Commit Message Convention
**Pattern:** `JIRA-ID: Commit message`

**Examples:**
```bash
✅ NEMO2-12345: Add user authentication middleware
✅ NEMOIT-5678: Fix memory leak in connection pool
❌ Add user authentication (missing JIRA ID)
```

**Exceptions:**
- Messages containing `hotfix` or `buildfix` keywords bypass the check

---

## 🎯 Proposed Changes

### 1. **File: `src/commands/scripts/services/opencode_service.sh`**

**Location:** Lines 1-20 (add project detection)

**Add new function:**
```bash
# Detect if we're in a Nemo project
is_nemo_project() {
    # Check for nemo-specific indicators
    if [ -f "${LOCAL_PATH}/.git/hooks/commit-msg" ]; then
        if grep -q "NEMO2\|PROFSD\|NEMO3A\|NEMOME\|NEMONE\|NEMOAR\|NEMOIT\|NEMOSME" "${LOCAL_PATH}/.git/hooks/commit-msg" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Check if path contains 'nemo'
    if [[ "$LOCAL_PATH" == *"/nemo/"* ]] || [[ "$LOCAL_PATH" == *"/nemo" ]]; then
        return 0
    fi
    
    return 1
}

# Extract JIRA ID from current git branch
get_jira_id_from_branch() {
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    local jira_id=$(echo "$branch" | grep -o -E "(NEMO2|PROFSD|NEMO3A|NEMOME|NEMONE|NEMOAR|NEMOIT|NEMOSME)-[0-9]+")
    echo "$jira_id"
}

# Validate JIRA ID format
is_valid_jira_id() {
    local jira_id="$1"
    if [[ "$jira_id" =~ ^(NEMO2|PROFSD|NEMO3A|NEMOME|NEMONE|NEMOAR|NEMOIT|NEMOSME)-[0-9]+$ ]]; then
        return 0
    fi
    return 1
}
```

**Update function: `get_smart_commit()` (lines 78-112)**

**Current:**
```bash
get_smart_commit() {
    local prompt=$(cat <<EOF
You are the WYX-CLI Smart Commit assistant. Generate an informative yet succinct commit message based on the git diff output.

$(get_git_diff)
$(get_repo_context)

Instructions:
- Write a 1-line title (≤50 characters) that technically describes the changes
- Write a 2-line detailed description explaining what was modified/created/deleted and why
- Mention specific functions, classes, or variables that were changed
- Ignore cache files and minor formatting changes
- Do NOT mention the branch name

Format your response exactly as:
TITLE: <your title here>
DESCRIPTION: <line 1 of description>
<line 2 of description>
EOF
)

    local response=$(echo "$prompt" | opencode 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        log_error "Failed to generate commit message with OpenCode"
        echo "OpenCode-commit: Quick commit"
        echo "Changes made via WYX-CLI"
        return 1
    fi
    
    echo "$response"
}
```

**Proposed:**
```bash
get_smart_commit() {
    # Check if this is a Nemo project
    local is_nemo=false
    local jira_prefix=""
    
    if is_nemo_project; then
        is_nemo=true
        jira_id=$(get_jira_id_from_branch)
        
        if [ -n "$jira_id" ]; then
            jira_prefix="${jira_id}: "
            log_info "Detected Nemo project with JIRA ID: $jira_id"
        else
            log_warn "Nemo project detected but no JIRA ID found in branch name"
            log_warn "Branch should follow pattern: feature/NEMO2-XXXXX_description"
        fi
    fi
    
    local title_length_limit=50
    # If Nemo project with JIRA ID, reduce title limit to account for prefix
    if [ -n "$jira_prefix" ]; then
        local prefix_length=${#jira_prefix}
        title_length_limit=$((50 - prefix_length))
    fi
    
    local prompt=$(cat <<EOF
You are the WYX-CLI Smart Commit assistant. Generate an informative yet succinct commit message based on the git diff output.

$(get_git_diff)
$(get_repo_context)

Instructions:
- Write a 1-line title (≤${title_length_limit} characters) that technically describes the changes
- Write a 2-line detailed description explaining what was modified/created/deleted and why
- Mention specific functions, classes, or variables that were changed
- Ignore cache files and minor formatting changes
- Do NOT mention the branch name
- Do NOT include JIRA ticket IDs (they will be added automatically)

Format your response exactly as:
TITLE: <your title here>
DESCRIPTION: <line 1 of description>
<line 2 of description>
EOF
)

    local response=$(echo "$prompt" | opencode 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        log_error "Failed to generate commit message with OpenCode"
        if [ -n "$jira_prefix" ]; then
            echo "TITLE: ${jira_prefix}Quick commit"
        else
            echo "TITLE: OpenCode-commit: Quick commit"
        fi
        echo "DESCRIPTION: Changes made via WYX-CLI"
        echo ""
        return 1
    fi
    
    # If Nemo project, prepend JIRA ID to the title
    if [ -n "$jira_prefix" ]; then
        response=$(echo "$response" | sed "s/^TITLE: /TITLE: ${jira_prefix}/")
    fi
    
    echo "$response"
}
```

**Update function: `get_commit_title()` (lines 114-117)**

**Current:**
```bash
get_commit_title() {
    local full_commit=$(get_smart_commit)
    echo "$full_commit" | grep "^TITLE:" | sed 's/^TITLE: /OpenCode-commit: /'
}
```

**Proposed:**
```bash
get_commit_title() {
    local full_commit=$(get_smart_commit)
    # Don't add "OpenCode-commit:" prefix if JIRA ID is already present
    local title=$(echo "$full_commit" | grep "^TITLE:" | sed 's/^TITLE: //')
    
    # Check if title already has JIRA ID
    if [[ "$title" =~ ^(NEMO2|PROFSD|NEMO3A|NEMOME|NEMONE|NEMOAR|NEMOIT|NEMOSME)-[0-9]+: ]]; then
        echo "$title"
    else
        echo "OpenCode-commit: $title"
    fi
}
```

---

### 2. **File: `src/classes/wgit/wgit.class`**

**Add branch name validation function** (before `wgit.commit()`)

```bash
# Validate branch name for Nemo projects
wgit.validate_nemo_branch() {
    local branch_name="$1"
    
    # Check if it's a protected branch
    if [[ "$branch_name" == "master" ]] || [[ "$branch_name" == "main" ]]; then
        return 0
    fi
    
    # Nemo branch patterns
    local feature_pattern="^(feature|feat|bug|tech)/((NEMO2|PROFSD|NEMO3A|NEMOME|NEMONE|NEMOAR|NEMOIT|NEMOSME)-[0-9]+)(_[a-zA-Z0-9_-]+)?$"
    local update_pattern="^update/(NEMO2|PROFSD|NEMO3A|NEMOME|NEMONE|NEMOAR|NEMOIT|NEMOSME)-[0-9]+/"
    local release_pattern="^(NEMOAR|NEMOIT|NEMO2|PROFSD|NEMO3A|NEMOME|NEMONE|NEMOSME)-[0-9]+-"
    
    if [[ "$branch_name" =~ $feature_pattern ]] || \
       [[ "$branch_name" =~ $update_pattern ]] || \
       [[ "$branch_name" =~ $release_pattern ]]; then
        return 0
    else
        sys.log.error "Invalid Nemo branch name: '$branch_name'"
        echo ""
        echo "Valid branch name patterns:"
        echo "  feature/NEMO2-12345_description"
        echo "  bug/NEMOIT-5678_fix-something"
        echo "  tech/PROFSD-999_upgrade"
        echo "  feat/NEMONE-42_new-feature"
        echo "  update/NEMO2-123/steward/lib/all"
        echo "  NEMOAR-123-Release-Name"
        echo ""
        return 1
    fi
}

# Check if current repo is a Nemo project
wgit.is_nemo_project() {
    local cwd=$(pwd)
    
    # Check for nemo-specific git hooks
    if [ -f ".git/hooks/commit-msg" ]; then
        if grep -q "NEMO2\|PROFSD\|NEMO3A\|NEMOME\|NEMONE\|NEMOAR\|NEMOIT\|NEMOSME" ".git/hooks/commit-msg" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Check if path contains 'nemo'
    if [[ "$cwd" == *"/nemo/"* ]] || [[ "$cwd" == *"/nemo" ]]; then
        return 0
    fi
    
    return 1
}
```

**Update `wgit.npush()` function** (around line 130)

**Current:**
```bash
wgit.npush() {
	git checkout -b "$1"
	wgit.commit "$2"
	git push origin "$1"
}
```

**Proposed:**
```bash
wgit.npush() {
	local branch_name="$1"
	
	# Validate branch name for Nemo projects
	if wgit.is_nemo_project; then
		if ! wgit.validate_nemo_branch "$branch_name"; then
			sys.log.error "Branch creation cancelled due to invalid branch name"
			return 1
		fi
	fi
	
	git checkout -b "$branch_name"
	wgit.commit "$2"
	git push origin "$branch_name"
}
```

**Update `wgit.bpr()` function** (around line 160)

**Current:**
```bash
wgit.bpr() {
	wgit.npush "$1"
	wgit.pr "$1"
}
```

**Proposed:**
```bash
wgit.bpr() {
	local branch_name="$1"
	
	# Validate branch name for Nemo projects
	if wgit.is_nemo_project; then
		if ! wgit.validate_nemo_branch "$branch_name"; then
			sys.log.error "Branch creation cancelled due to invalid branch name"
			return 1
		fi
	fi
	
	wgit.npush "$branch_name"
	wgit.pr "$branch_name"
}
```

---

### 3. **New File: `src/commands/scripts/services/nemo_validator.sh`**

**Purpose:** Standalone validator for Nemo branch names and commit messages

```bash
#!/bin/bash

# Nemo Project Validator
# Validates branch names and commit messages for Springer Nature Nemo projects

# Valid JIRA prefixes
VALID_JIRA_PREFIXES="NEMO2|PROFSD|NEMO3A|NEMOME|NEMONE|NEMOAR|NEMOIT|NEMOSME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Validate branch name
validate_branch_name() {
    local branch_name="$1"
    
    # Skip protected branches
    if [[ "$branch_name" == "master" ]] || [[ "$branch_name" == "main" ]]; then
        echo -e "${GREEN}✓ Protected branch${RESET}"
        return 0
    fi
    
    # Branch patterns
    local feature_pattern="^(feature|feat|bug|tech)/(($VALID_JIRA_PREFIXES)-[0-9]+)(_[a-zA-Z0-9_-]+)?$"
    local update_pattern="^update/($VALID_JIRA_PREFIXES)-[0-9]+/"
    local release_pattern="^($VALID_JIRA_PREFIXES)-[0-9]+-"
    
    if [[ "$branch_name" =~ $feature_pattern ]]; then
        echo -e "${GREEN}✓ Valid feature/bug/tech branch${RESET}"
        return 0
    elif [[ "$branch_name" =~ $update_pattern ]]; then
        echo -e "${GREEN}✓ Valid update branch${RESET}"
        return 0
    elif [[ "$branch_name" =~ $release_pattern ]]; then
        echo -e "${GREEN}✓ Valid release branch${RESET}"
        return 0
    else
        echo -e "${RED}✗ Invalid branch name${RESET}"
        echo ""
        echo "Branch name: '$branch_name'"
        echo ""
        echo "Valid patterns:"
        echo "  feature/NEMO2-12345_description"
        echo "  bug/NEMOIT-5678_fix-something"
        echo "  tech/PROFSD-999_upgrade"
        echo "  feat/NEMONE-42_new-feature"
        echo "  update/NEMO2-123/steward/lib/all"
        echo "  NEMOAR-123-Release-Name"
        return 1
    fi
}

# Validate commit message
validate_commit_message() {
    local commit_msg="$1"
    
    # Check for emergency keywords
    if [[ "$commit_msg" =~ hotfix|buildfix ]]; then
        echo -e "${YELLOW}⚠ Emergency commit (hotfix/buildfix)${RESET}"
        return 0
    fi
    
    # Check for JIRA ID prefix
    if [[ "$commit_msg" =~ ^($VALID_JIRA_PREFIXES)-[0-9]+: ]]; then
        echo -e "${GREEN}✓ Valid commit message${RESET}"
        return 0
    else
        echo -e "${RED}✗ Invalid commit message${RESET}"
        echo ""
        echo "Message: '$commit_msg'"
        echo ""
        echo "Required format: JIRA-ID: Your message"
        echo ""
        echo "Examples:"
        echo "  NEMO2-12345: Add user authentication"
        echo "  NEMOIT-5678: Fix memory leak"
        echo "  PROFSD-999: Update dependencies"
        echo ""
        echo "Or use keywords: hotfix, buildfix"
        return 1
    fi
}

# Extract JIRA ID from branch
extract_jira_from_branch() {
    local branch_name="$1"
    echo "$branch_name" | grep -o -E "($VALID_JIRA_PREFIXES)-[0-9]+"
}

# Main execution
case "${1:-}" in
    "branch")
        validate_branch_name "$2"
        ;;
    "commit")
        validate_commit_message "$2"
        ;;
    "extract-jira")
        extract_jira_from_branch "$2"
        ;;
    *)
        echo "Usage: $0 {branch|commit|extract-jira} <value>"
        echo ""
        echo "Examples:"
        echo "  $0 branch feature/NEMO2-12345_my-feature"
        echo "  $0 commit 'NEMO2-12345: Add feature'"
        echo "  $0 extract-jira feature/NEMO2-12345_my-feature"
        exit 1
        ;;
esac
```

---

### 4. **New Documentation File: `NEMO_INTEGRATION.md`**

```markdown
# Nemo Project Integration Guide

## Overview
WYX-CLI automatically detects when you're working in a Springer Nature Nemo project and adapts its behavior to comply with Nemo's git workflow requirements.

## Auto-Detection
WYX-CLI detects Nemo projects by checking:
1. Presence of Nemo-specific git hooks in `.git/hooks/commit-msg`
2. Path contains `/nemo/` or ends with `/nemo`

## Features

### 1. Branch Name Validation
When creating branches with `wyx nb` or `wyx bpr`, WYX-CLI validates the branch name.

**Valid patterns:**
- `feature/NEMO2-12345_description`
- `bug/NEMOIT-5678_fix-something`
- `tech/PROFSD-999_upgrade`
- `feat/NEMONE-42_new-feature`

**Example:**
\`\`\`bash
# Valid
wyx nb feature/NEMO2-12345_add-auth

# Invalid - will be rejected
wyx nb my-feature-branch
\`\`\`

### 2. JIRA-Prefixed Commits
OpenCode-generated commit messages automatically include the JIRA ID from your branch name.

**Example workflow:**
\`\`\`bash
# 1. Create branch with JIRA ID
git checkout -b feature/NEMO2-12345_add-authentication

# 2. Make changes
vim src/auth.scala

# 3. Use wyx push - JIRA ID auto-added
wyx push

# OpenCode generates:
# NEMO2-12345: Add JWT authentication middleware
# Implemented token validation with expiry checking
# Added secure password hashing with bcrypt
\`\`\`

### 3. Manual Override
If no JIRA ID detected in branch, you'll see a warning but can still commit:
\`\`\`bash
wyx push
# Warning: Nemo project detected but no JIRA ID found in branch name
# Suggest creating branch: feature/NEMO2-XXXXX_description
\`\`\`

## Validator Tool
Test branch names before creating them:
\`\`\`bash
bash src/commands/scripts/services/nemo_validator.sh branch "feature/NEMO2-12345_test"
✓ Valid feature/bug/tech branch

bash src/commands/scripts/services/nemo_validator.sh commit "NEMO2-12345: Test commit"
✓ Valid commit message
\`\`\`

## Emergency Commits
Use `hotfix` or `buildfix` keywords to bypass JIRA ID requirement:
\`\`\`bash
git commit -m "hotfix: Critical production issue"
\`\`\`
```

---

## 📊 Summary of Changes

| File | Changes | Lines Added | Complexity |
|------|---------|-------------|------------|
| `opencode_service.sh` | Add Nemo detection & JIRA prefix logic | ~80 | Medium |
| `wgit.class` | Add branch validation functions | ~70 | Medium |
| `nemo_validator.sh` | New standalone validator | ~120 | Low |
| `NEMO_INTEGRATION.md` | New documentation | ~100 | Low |

**Total:** ~370 lines of code

---

## ✅ Benefits

1. **Seamless Integration** - Auto-detects Nemo projects, no manual configuration
2. **Prevents Errors** - Branch validation before creation saves time
3. **Compliant Commits** - Auto-prefixes JIRA IDs from branch names
4. **Standalone Tools** - Validator can be used independently
5. **Backward Compatible** - Non-Nemo projects work exactly as before

---

## 🧪 Testing Plan

1. **Test in Nemo project:**
   ```bash
   cd /Users/pwt9708/SpringerNature/Projects/nemo
   wyx nb feature/NEMO2-12345_test-wyx
   wyx push
   ```

2. **Test in non-Nemo project:**
   ```bash
   cd /Users/pwt9708/wyx-cli-test-repo
   wyx nb my-feature
   wyx push
   ```

3. **Test validator:**
   ```bash
   bash src/commands/scripts/services/nemo_validator.sh branch "feature/NEMO2-123_test"
   bash src/commands/scripts/services/nemo_validator.sh commit "NEMO2-123: Test"
   ```

---

## ❓ Questions Before Implementation

1. **Should the branch validation be strict?** 
   - Option A: Block invalid branches entirely ✅ (Recommended)
   - Option B: Show warning but allow creation

2. **What if JIRA ID extraction fails?**
   - Option A: Show warning, let user type manually ✅ (Recommended)
   - Option B: Block commit entirely

3. **Should we create a config file?**
   - Option A: Auto-detect only (simpler) ✅ (Recommended)
   - Option B: Add `.wyxrc` config for manual override

4. **Character limit adjustment:**
   - Currently reduces title limit when JIRA prefix is present
   - JIRA prefix is ~12 chars (e.g., "NEMO2-12345: ")
   - New limit: 38 chars for title (50 - 12)
   - Is this acceptable? ✅

---

## 🚀 Ready to Implement?

Please review and let me know:
1. Do you approve these changes?
2. Any modifications needed?
3. Should I proceed with implementation?

Once approved, I'll implement all changes and create test scenarios.
