#!/bin/bash
########################################################################
# WYX CLI - Reorganize File
# Sorts properties/messages files alphabetically while preserving comments
########################################################################

PYTHON_LIB="/Users/pwt9708/SpringerNature/Scripts/toolbox_python/toolbox"

show_help() {
    cat << EOF
Usage: wyx reorganize-file <file> [output_file]

Reorganizes a file by sorting lines alphabetically while preserving comment blocks.

Arguments:
  <file>         File to reorganize
  [output_file]  Optional output file (if omitted, modifies file in place)

Options:
  -h, --help     Show this help message
  --no-backup    Don't create backup file (only when modifying in place)

Examples:
  wyx reorganize-file conf/messages.nl
  # Reorganizes in place, creates messages.nl.bak

  wyx reorganize-file conf/messages.de conf/messages_sorted.de
  # Creates new sorted file

  wyx reorganize-file --no-backup conf/messages.fr
  # Reorganizes without backup

Features:
  - Sorts property lines alphabetically
  - Preserves comment blocks (lines starting with #)
  - Creates automatic backup (file.bak)
  - Maintains UTF-8 encoding
  - Preserves empty lines

EOF
}

CREATE_BACKUP=true

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --no-backup)
            CREATE_BACKUP=false
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

FILE_PATH="$1"
OUTPUT_PATH="${2:-}"

if [ ! -f "$FILE_PATH" ]; then
    echo "❌ Error: File not found: $FILE_PATH"
    exit 1
fi

# Build Python command
PY_CMD="python3 $PYTHON_LIB/file_reorganizer.py reorganize \"$FILE_PATH\""

if [ -n "$OUTPUT_PATH" ]; then
    PY_CMD="$PY_CMD \"$OUTPUT_PATH\""
fi

# Execute
eval $PY_CMD

# Validation prompt
if [ -z "$OUTPUT_PATH" ] && [ "$CREATE_BACKUP" = true ]; then
    echo ""
    read -p "Validate reorganization against backup? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        python3 "$PYTHON_LIB/file_reorganizer.py" validate "${FILE_PATH}.bak" "$FILE_PATH"
    fi
fi
