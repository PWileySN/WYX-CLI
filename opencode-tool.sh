#!/bin/zsh

# OpenCode WYX-CLI Integration
# Wrapper to run WYX-CLI commands from OpenCode sessions

# Export WYX_DIR
export WYX_DIR="/Users/pwt9708/SpringerNature/Scripts/WYX-CLI-master"

# Source user's zsh configuration (loads WYX-CLI and all functions)
# Suppress output from initialization
source ~/.zshrc >/dev/null 2>&1

# Execute the command passed as arguments
if [ $# -gt 0 ]; then
    "$@"
else
    echo "Usage: opencode-wyx <command> [args...]"
    echo ""
    echo "Examples:"
    echo "  opencode-wyx delete              # Interactive file deletion"
    echo "  opencode-wyx genpass 20          # Generate 20-char password"
    echo "  opencode-wyx push                # Git add, commit, push"
    echo "  opencode-wyx sys-info            # System information"
    echo ""
    echo "Run 'wyx help' in terminal for full command list"
fi
