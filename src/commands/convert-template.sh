#!/bin/bash
########################################################################
# WYX CLI - Convert Template
# Converts Handlebars templates to Scala HTML
########################################################################

PYTHON_LIB="/Users/pwt9708/SpringerNature/Scripts/toolbox_python/toolbox"

show_help() {
    cat << EOF
Usage: wyx convert-template <input.hbs> [output.scala.html] [params]

Converts Handlebars templates to Scala HTML templates.

Arguments:
  <input.hbs>          Input Handlebars template file
  [output.scala.html]  Output Scala HTML file (optional)
  [params]             Scala template parameters (optional)

Examples:
  wyx convert-template views/login.hbs
  # Creates views/login.scala.html

  wyx convert-template input.hbs output.scala.html
  # Creates output.scala.html

  wyx convert-template user.hbs user.scala.html "user: User, title: String"
  # Creates template with parameters

  wyx convert-template --help-guide
  # Show conversion guide

Conversion Rules:
  {{#if condition}}     →  @if(condition) {
  {{#each items}}       →  @for(items) {
  {{#with user}}        →  @defining(user) {
  {{variable}}          →  @variable

EOF
}

show_guide() {
    python3 "$PYTHON_LIB/template_converter.py" help
}

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ "$1" = "--help-guide" ]; then
    show_guide
    exit 0
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-}"
PARAMS="${3:-}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: File not found: $INPUT_FILE"
    exit 1
fi

# Build command
if [ -n "$OUTPUT_FILE" ] && [ -n "$PARAMS" ]; then
    python3 "$PYTHON_LIB/template_converter.py" convert "$INPUT_FILE" "$OUTPUT_FILE" "$PARAMS"
elif [ -n "$OUTPUT_FILE" ]; then
    python3 "$PYTHON_LIB/template_converter.py" convert "$INPUT_FILE" "$OUTPUT_FILE"
else
    python3 "$PYTHON_LIB/template_converter.py" convert "$INPUT_FILE"
fi
