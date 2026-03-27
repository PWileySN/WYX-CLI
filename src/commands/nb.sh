#!/bin/bash

# Enhanced new branch command with safe branch creation and validation
# Integrates: create_branch.sh + check-branch-name.sh logic

validate_branch_name() {
    local BRANCH_NAME="$1"
    local MAX_LENGTH=100
    local VALID=true
    local WARNINGS=()
    local ERRORS=()
    
    # Define valid prefixes and ticket patterns
    local VALID_PREFIXES=("feature" "bug" "feat" "tech" "update" "copilot" "revert" "hotfix" "spike")
    local TICKET_PATTERN="(NEMO2|NEMOAR|NEMONE|NEMOIT|NEMOME|PROFSD|NEMO)-[0-9]+"
    
    # 1. Check length
    local BRANCH_LENGTH=${#BRANCH_NAME}
    if [ $BRANCH_LENGTH -gt $MAX_LENGTH ]; then
        ERRORS+=("Branch name too long: $BRANCH_LENGTH chars (max: $MAX_LENGTH)")
        VALID=false
    fi
    
    # 2. Git technical validation
    if ! git check-ref-format --branch "$BRANCH_NAME" >/dev/null 2>&1; then
        ERRORS+=("Violates Git naming rules (no spaces, .., trailing /, etc.)")
        VALID=false
    fi
    
    # 3. Nemo-Core convention validation
    local PATTERN_MATCHED=false
    
    # Pattern 1: prefix/TICKET_description
    if [[ $BRANCH_NAME =~ ^([a-z]+)/([A-Z0-9]+-[0-9]+)(_.*)?$ ]]; then
        local PREFIX="${match[1]}"
        local TICKET="${match[2]}"
        local DESCRIPTION="${match[3]}"
        
        if [[ " ${VALID_PREFIXES[@]} " =~ " ${PREFIX} " ]]; then
            PATTERN_MATCHED=true
            
            # Validate ticket format
            if [[ ! $TICKET =~ ^(NEMO2|NEMOAR|NEMONE|NEMOIT|NEMOME|PROFSD|NEMO)-[0-9]+$ ]]; then
                WARNINGS+=("Ticket '$TICKET' doesn't match standard format (e.g., NEMO2-12345)")
            fi
            
            # Check description
            if [ -z "$DESCRIPTION" ]; then
                WARNINGS+=("Consider adding description: ${PREFIX}/${TICKET}_description")
            elif [[ ! $DESCRIPTION =~ ^_ ]]; then
                ERRORS+=("Description must start with underscore: ${PREFIX}/${TICKET}_description")
                VALID=false
            fi
        else
            ERRORS+=("Invalid prefix '$PREFIX'. Valid: ${VALID_PREFIXES[*]}")
            VALID=false
            
            # Common mistakes
            if [[ "$PREFIX" == "bugfix" ]]; then
                ERRORS+=("Did you mean 'bug/' instead of 'bugfix/'?")
            elif [[ "$PREFIX" == "features" ]]; then
                ERRORS+=("Did you mean 'feature/' instead of 'features/'?")
            elif [[ "$PREFIX" == "fix" ]]; then
                ERRORS+=("Did you mean 'bug/' instead of 'fix/'?")
            fi
        fi
    
    # Pattern 2: prefix/TICKET/path (for updates)
    elif [[ $BRANCH_NAME =~ ^([a-z]+)/([A-Z0-9]+-[0-9]+)/(.+)$ ]]; then
        local PREFIX="${match[1]}"
        local TICKET="${match[2]}"
        
        if [[ "$PREFIX" == "update" ]]; then
            PATTERN_MATCHED=true
            if [[ ! $TICKET =~ ^(NEMO2|NEMOAR|NEMONE|NEMOIT|NEMOME|PROFSD|NEMO)-[0-9]+$ ]]; then
                WARNINGS+=("Ticket '$TICKET' doesn't match standard format")
            fi
        else
            ERRORS+=("Path format only valid for 'update/' prefix")
            VALID=false
        fi
    
    # Pattern 3: TICKET-Description (release/special)
    elif [[ $BRANCH_NAME =~ ^([A-Z0-9]+-[0-9]+)-(.+)$ ]]; then
        local TICKET="${match[1]}"
        if [[ $TICKET =~ ^(NEMO2|NEMOAR|NEMONE|NEMOIT|NEMOME|PROFSD|NEMO)-[0-9]+$ ]]; then
            PATTERN_MATCHED=true
            WARNINGS+=("Using ticket-only format. Consider: feature/$TICKET-description")
        else
            ERRORS+=("Ticket '$TICKET' doesn't match standard format")
            VALID=false
        fi
    
    # Pattern 4: Uppercase prefix (common mistake)
    elif [[ $BRANCH_NAME =~ ^([A-Z][a-z]+)/ ]]; then
        local PREFIX="${match[1]}"
        local LOWERCASE_PREFIX=$(echo "$PREFIX" | tr '[:upper:]' '[:lower:]')
        ERRORS+=("Prefix must be lowercase: use '${LOWERCASE_PREFIX}/' not '$PREFIX/'")
        VALID=false
    
    # Pattern 5: Missing ticket number
    elif [[ $BRANCH_NAME =~ ^([a-z]+)/([^/]+)$ ]]; then
        local PREFIX="${match[1]}"
        local REST="${match[2]}"
        
        if [[ " ${VALID_PREFIXES[@]} " =~ " ${PREFIX} " ]]; then
            if [[ ! $REST =~ ^[A-Z]+-[0-9]+ ]]; then
                ERRORS+=("Missing ticket number. Format: ${PREFIX}/TICKET-NUMBER_description")
                ERRORS+=("Example: ${PREFIX}/NEMO2-12345_${REST}")
                VALID=false
            fi
        else
            ERRORS+=("Invalid prefix '$PREFIX'. Valid: ${VALID_PREFIXES[*]}")
            VALID=false
        fi
    
    # Pattern 6: No recognizable pattern
    else
        ERRORS+=("Doesn't follow nemo-core naming conventions")
        ERRORS+=("Valid examples:")
        ERRORS+=("  feature/NEMO2-12345_description")
        ERRORS+=("  bug/NEMOAR-123_fix-something")
        ERRORS+=("  tech/NEMONE-42_upgrade")
        VALID=false
    fi
    
    # Display validation results
    if [ "$VALID" = false ]; then
        echo ""
        sys.log.error "Branch name validation FAILED!"
        echo ""
        for error in "${ERRORS[@]}"; do
            echo "  ${RED}✗ $error${RESET}"
        done
        echo ""
        return 1
    fi
    
    # Display warnings but allow
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo ""
        sys.log.warn "Branch name has warnings:"
        for warning in "${WARNINGS[@]}"; do
            echo "  ${YELLOW}⚠ $warning${RESET}"
        done
        echo ""
    fi
    
    # Success
    sys.log.success "✓ Branch name is valid"
    return 0
}

create_and_push_branch() {
    local BRANCH_NAME="$1"
    
    if [ -z "$BRANCH_NAME" ]; then
        sys.log.error "No branch name provided"
        return 1
    fi
    
    echo ""
    sys.log.h1 "Creating Git Branch"
    sys.log.info "Branch: ${BRANCH_NAME}"
    echo ""
    
    # Check if branch exists locally
    if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
        sys.log.warn "Branch exists locally. Checking out..."
        git checkout "$BRANCH_NAME"
        sys.log.info "Would you like to push it? [y/N]"
        read -r push_existing
        if [ "$push_existing" = "y" ] || [ "$push_existing" = "Y" ]; then
            wgit.commit ""
            git push origin "$BRANCH_NAME"
        fi
        return 0
    fi
    
    # Check if branch exists on remote
    if git ls-remote --heads origin "$BRANCH_NAME" 2>/dev/null | grep -q "$BRANCH_NAME"; then
        sys.log.warn "Branch exists on remote. Tracking..."
        git checkout -b "$BRANCH_NAME" --track "origin/$BRANCH_NAME"
        return 0
    fi
    
    # VALIDATE branch name before creating
    if ! validate_branch_name "$BRANCH_NAME"; then
        echo ""
        sys.log.error "Cannot create branch with invalid name"
        echo ""
        echo "Examples of valid names:"
        echo "  feature/NEMO2-12345_add-new-feature"
        echo "  bug/NEMOAR-123_fix-login-issue"
        echo "  tech/NEMONE-42_upgrade-dependencies"
        echo ""
        return 1
    fi
    
    # Create new branch
    echo ""
    sys.log.info "Creating new branch '${BRANCH_NAME}'..."
    git checkout -b "$BRANCH_NAME"
    
    sys.log.success "✓ Branch created successfully"
    echo ""
    sys.log.info "Would you like to commit and push now? [y/N]"
    read -r do_push
    
    if [ "$do_push" = "y" ] || [ "$do_push" = "Y" ]; then
        wgit.commit ""
        git push origin "$BRANCH_NAME"
    else
        sys.log.info "Branch created locally. Use 'wyx push' when ready to commit and push."
    fi
}

if wyxd.arggt "1" ; then
    create_and_push_branch "$1"
else
    sys.log.info "Provide a branch name:"
    read -r name
    if [ "$name" != "" ]; then
        create_and_push_branch "$name"
    else
        sys.log.error "Invalid branch name"
    fi
fi