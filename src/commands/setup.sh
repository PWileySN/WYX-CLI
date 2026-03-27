#!/bin/bash

if [ "$1" = "smart_commit" ]; then
    sys.log.info "Setting up OpenCode smart commit..."
    echo ""
    wyxd.check_keystore "USE_OPENCODE_COMMIT" "true"
    sys.log.info "You're done! OpenCode will now generate commit messages."

elif [ "$1" = "auto_update" ]; then
    sys.log.info "Setting up auto update..."
    echo ""
    wyxd.check_keystore "WYX_GIT_AUTO_UPDATE" "true"
    sys.log.info "You're done!"
    
else
    sys.log.error "Invalid setup command! Try again"
    echo "Type 'wyx' to see the list of available commands (and their arguments), or 'wyx help' to be redirected to more in-depth online documentation"
fi