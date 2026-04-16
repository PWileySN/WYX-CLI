#!/bin/bash

if toolboxd.arggt "1"; then
    if toolboxd.orgexists "$1"; then
        wgit.giturl "https://github.com/$(toolboxd.org $1)"
    else
        sys.log.error "That organisation does not exist..."
        sys.log.info "Execute 'wyx myorgs' to see your saved organisations"
    fi
else
    wgit.giturl "https://github.com/$(toolboxd.org default)"
fi