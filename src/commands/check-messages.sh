#!/bin/bash
########################################################################
# WYX CLI - Check Messages
# Validates messages/properties files for syntax errors
########################################################################

PYTHON_LIB="/Users/pwt9708/SpringerNature/Scripts/toolbox_python/toolbox"

show_help() {
    cat << EOF
Usage: wyx check-messages <file>

Validates a messages/properties file for syntax errors.

Arguments:
  <file>    Path to the messages/properties file to validate

Examples:
  wyx check-messages conf/messages
  wyx check-messages conf/messages.nl
  wyx check-messages /path/to/messages.properties

Checks for:
  - Missing '=' signs
  - Empty keys
  - Empty values
  - UTF-8 encoding issues

EOF
}

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
    echo "❌ Error: File not found: $FILE_PATH"
    exit 1
fi

python3 "$PYTHON_LIB/message_utils.py" validate "$FILE_PATH"
