#!/bin/zsh

# OpenCode WYX-CLI Integration (Optimized)
# Lightweight wrapper for non-interactive commands

export WYX_DIR="/Users/pwt9708/SpringerNature/Scripts/WYX-CLI-master"

# Only source what's needed
source "$WYX_DIR/wyx-functions.sh" 2>/dev/null

# Execute command
if [ $# -gt 0 ]; then
    "$@"
else
    echo "Usage: opencode-wyx-lite <command> [args...]"
fi
