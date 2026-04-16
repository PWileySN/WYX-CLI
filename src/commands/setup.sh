#!/bin/bash

if [ "$1" = "smart_commit" ]; then
    sys.log.info "Setting up OpenCode smart commit..."
    echo ""
    toolboxd.check_keystore "USE_OPENCODE_COMMIT" "true"
    sys.log.info "You're done! OpenCode will now generate commit messages."
    
else
    sys.log.error "Invalid setup command! Try again"
    echo "Type 'tool' to see the list of available commands (and their arguments), or 'tool help' to be redirected to more in-depth online documentation"
fi