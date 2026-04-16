#!/bin/bash

if wgit.is_git_repo ; then
    if toolboxd.arggt "1" ; then
        wgit.bpr "$@"
    else
        sys.log.info "Provide a branch name:"
        read -r name
        if [ "$name" != "" ]; then
            wgit.bpr "$name"
        fi
    fi
fi