#!/bin/bash

# Only enable bash completion if running in bash
# In zsh, use zsh's completion system instead
if [ -n "$BASH_VERSION" ]; then
    complete -W "sys-info update install-deps cd back vsc xc run push pull ginit nb pr bpr commits lastcommit setup repo branch prs actions issues notifs profile org user myorgs mydirs myscripts todo editd edits newscript fopen find regex rgxmatch ip wifi wpass speedtest hardware-ports genqr upscale genhex genb64 copy lastcmd weather moon explain ask-opencode" tool
fi