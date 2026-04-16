#!/bin/bash
########################################################################
# WYX CLI - Compare Messages
# Compares message files to find missing translations
########################################################################

PYTHON_LIB="/Users/pwt9708/SpringerNature/Scripts/toolbox_python/toolbox"

show_help() {
    cat << EOF
Usage: wyx compare-messages <default_file> <file1> [file2] [file3...]

Compares message files to find missing keys/translations.

Arguments:
  <default_file>  Reference messages file (e.g., messages or messages.en)
  <file1...>      Other message files to compare (e.g., messages.nl, messages.de)

Examples:
  wyx compare-messages conf/messages conf/messages.nl
  wyx compare-messages conf/messages conf/messages.* 
  wyx compare-messages messages.en messages.de messages.fr messages.es

Output:
  - Total keys in reference file
  - Missing keys per file
  - Extra keys per file (keys not in reference)
  - Detailed list of all missing keys

EOF
}

if [ $# -lt 2 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

DEFAULT_FILE="$1"
shift
OTHER_FILES="$@"

if [ ! -f "$DEFAULT_FILE" ]; then
    echo "❌ Error: Default file not found: $DEFAULT_FILE"
    exit 1
fi

python3 "$PYTHON_LIB/message_utils.py" compare "$DEFAULT_FILE" $OTHER_FILES
