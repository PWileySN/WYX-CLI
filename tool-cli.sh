#!/bin/bash

# CLI CONSTS
# Detect the script path based on shell type (zsh vs bash)
if [ -n "$ZSH_VERSION" ]; then
	# Running in zsh
	mypath="${(%):-%N}"
elif [ -n "$BASH_VERSION" ]; then
	# Running in bash
	mypath="${BASH_SOURCE[0]}"
else
	# Fallback for other shells
	mypath="$0"
fi
WYX_DIR=$(dirname "$mypath")
WYX_DATA_DIR=$WYX_DIR/.toolbox-data
WYX_SCRIPT_DIR=$WYX_DIR/src/commands/scripts
export WYX_DIR WYX_DATA_DIR WYX_SCRIPT_DIR

source $WYX_DIR/src/classes/sys/sys.h
sys sys
source $WYX_DIR/src/classes/lib/lib.h
lib lib

# ARGPARSE

source "$WYX_DIR/completion.sh"
source "$WYX_DIR/argparse.sh" "${@:1}"