#!/bin/bash

if toolboxd.arggt "1"; then
    if toolboxd.arggt "2"; then
        toolboxd.check_keystore "$1" "$2"
    else
        toolboxd.check_keystore "$1"
    fi
else
    if sys.shell.zsh; then
        read "key?${GREEN}Enter the key you would like to add to your keystore:${RESET}"
    else
        read -rp "${GREEN}Enter the key you would like to add to your keystore:${RESET} " key
    fi
    toolboxd.check_keystore "$key"
fi
sys.log.info "You're done!"