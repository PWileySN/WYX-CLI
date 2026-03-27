#!/bin/bash

# OpenCode Service - WYX-CLI Integration
# Provides AI-powered commit messages and interactive chat using OpenCode

# Cross-platform script directory detection (macOS and Linux compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Use greadlink if available, otherwise use Python fallback
    if command -v greadlink &> /dev/null; then
        SCRIPT_DIR=$(dirname "$(greadlink -f "$0")")
    else
        # Python fallback for macOS (works on macOS 10.15+)
        SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd -P)
    fi
else
    # Linux: Use standard readlink
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
fi

REPO_PATH="${SCRIPT_DIR/\/src\/commands\/scripts\/services/}"
LOCAL_PATH=$(pwd)
SEPARATOR="----------------------------------------------------------------------------------------------------------------------------------------------"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${RESET} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

# Get git diff for commit analysis
get_git_diff() {
    git reset 2>/dev/null
    local diff=$(git diff 2>/dev/null)
    local clean_diff=$(echo "$diff" | grep -E "^(\+|\-)" | grep -v "^(\+\+\+|\-\-\-)")
    
    echo "Analyze the following git diff output to understand the code changes made."
    echo "Lines starting with '+' are additions, lines starting with '-' are deletions."
    echo ""
    echo "Git diff output:"
    echo "$clean_diff"
    echo ""
    echo "Generate a concise, technical commit message that describes what was changed and why."
    echo "Format: First line should be a title (≤50 chars), followed by a 2-line detailed description."
}

# Get repository context
get_repo_context() {
    local readme_path=""
    if [ -f "$LOCAL_PATH/.github/README.md" ]; then
        readme_path="$LOCAL_PATH/.github/README.md"
    elif [ -f "$LOCAL_PATH/README.md" ]; then
        readme_path="$LOCAL_PATH/README.md"
    fi
    
    if [ -n "$readme_path" ]; then
        echo ""
        echo "Repository README (for context):"
        head -n 50 "$readme_path"
        echo ""
    fi
}

# Generate smart commit message using OpenCode
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

    # Call OpenCode to generate the commit message
    # Using echo to simulate OpenCode response - replace this with actual OpenCode CLI call
    local response=$(echo "$prompt" | opencode 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        log_error "Failed to generate commit message with OpenCode"
        echo "OpenCode-commit: Quick commit"
        echo "Changes made via WYX-CLI"
        return 1
    fi
    
    # Parse the response
    echo "$response"
}

# Get commit title only
get_commit_title() {
    local full_commit=$(get_smart_commit)
    echo "$full_commit" | grep "^TITLE:" | sed 's/^TITLE: /OpenCode-commit: /'
}

# Get commit description only
get_commit_description() {
    local full_commit=$(get_smart_commit)
    echo "$full_commit" | grep "^DESCRIPTION:" -A 2 | tail -n 2
}

# Interactive conversation with OpenCode
conversate() {
    echo -e "${BLUE}\n${SEPARATOR}"
    echo -e "Starting a conversation with OpenCode. Type 'quit', 'exit', or 'q' to exit, or 'save' to save the conversation."
    echo -e "${SEPARATOR}${RESET}\n"
    
    local conversation_history=""
    
    while true; do
        echo -e -n "${GREEN}You: ${RESET}"
        read -r user_input
        
        if [[ "$user_input" == "quit" ]] || [[ "$user_input" == "exit" ]] || [[ "$user_input" == "q" ]]; then
            echo -e "${YELLOW}\nQuitting conversation...\n${RESET}"
            break
        fi
        
        if [[ "$user_input" == "save" ]]; then
            echo -e -n "${YELLOW}\nEnter filename to save conversation to: ${RESET}"
            read -r filename
            echo "$conversation_history" > "${LOCAL_PATH}/${filename}.txt"
            echo -e "${GREEN}Conversation saved to ${filename}.txt\n${RESET}"
            continue
        fi
        
        # Call OpenCode for response
        local response=$(echo "$user_input" | opencode 2>/dev/null)
        
        if [ $? -ne 0 ] || [ -z "$response" ]; then
            log_error "Failed to get response from OpenCode"
            response="I'm having trouble connecting to OpenCode. Please check if OpenCode is installed and accessible."
        fi
        
        echo -e "${BLUE}\n🤖: ${RESET}$response"
        echo -e "${BLUE}\n${SEPARATOR}${RESET}\n"
        
        # Store conversation history
        conversation_history="${conversation_history}You: ${user_input}\n\nOpenCode: ${response}\n\n"
    done
}

# General purpose query
get_response() {
    local query="$1"
    echo "$query" | opencode 2>/dev/null
    
    if [ $? -ne 0 ]; then
        log_error "Failed to get response from OpenCode"
        return 1
    fi
}

# Main execution
case "${1:-}" in
    "title")
        get_commit_title
        ;;
    "description")
        get_commit_description
        ;;
    "smart")
        get_smart_commit
        ;;
    "conversate")
        conversate
        ;;
    "")
        log_error "No command provided. Usage: opencode_service.sh {title|description|smart|conversate|<query>}"
        exit 1
        ;;
    *)
        get_response "$1"
        ;;
esac
