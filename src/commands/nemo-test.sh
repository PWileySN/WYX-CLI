#!/usr/bin/env zsh

# nemo-test: Open one WezTerm tab per selected Nemo project and run sbt test in each.
#
# Usage:
#   nemo-test                                      # interactive menu
#   nemo-test nemo-mpedia nemo-cms-proxy           # specific projects
#   nemo-test --help                               # show usage

# ---------------------------------------------------------------------------
# Known projects: add new entries here as needed
# Format: "display-name:/absolute/path/to/project"
# ---------------------------------------------------------------------------
AVAILABLE_PROJECTS=(
  "nemo-mpedia:/Users/pwt9708/SpringerNature/Projects/nemo/apps/nemo-mpedia"
  "nemo-mpedia-importer:/Users/pwt9708/SpringerNature/Projects/nemo/apps/nemo-mpedia-importer"
  "nemo-cms-proxy:/Users/pwt9708/SpringerNature/Projects/nemo/apps/nemo-cms-proxy"
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
print_usage() {
  echo ""
  echo "Usage: nemo-test [project1 project2 ...]"
  echo ""
  echo "Available projects:"
  for entry in "${AVAILABLE_PROJECTS[@]}"; do
    local project_name="${entry%%:*}"
    echo "  - $project_name"
  done
  echo ""
  echo "If no project is specified, an interactive menu is shown."
  echo ""
}

get_project_path() {
  local target_name="$1"
  for entry in "${AVAILABLE_PROJECTS[@]}"; do
    local project_name="${entry%%:*}"
    local project_path="${entry##*:}"
    if [[ "$project_name" == "$target_name" ]]; then
      echo "$project_path"
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Interactive project selection (when no arguments are given)
# ---------------------------------------------------------------------------
select_projects_interactively() {
  echo ""
  echo "Select projects to test (space-separated numbers, or 'a' for all):"
  echo ""

  local index=1
  for entry in "${AVAILABLE_PROJECTS[@]}"; do
    local project_name="${entry%%:*}"
    echo "  $index) $project_name"
    ((index++))
  done
  echo ""

  read -r "input?Your choice: "

  SELECTED_PROJECTS=()

  if [[ "$input" == "a" ]]; then
    for entry in "${AVAILABLE_PROJECTS[@]}"; do
      SELECTED_PROJECTS+=("${entry%%:*}")
    done
    return 0
  fi

  for choice in ${=input}; do
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#AVAILABLE_PROJECTS[@]}" ]; then
      SELECTED_PROJECTS+=("${AVAILABLE_PROJECTS[$choice]%%:*}")
    else
      echo "Ignoring invalid selection: $choice"
    fi
  done

  if [ ${#SELECTED_PROJECTS[@]} -eq 0 ]; then
    echo "No valid projects selected. Exiting."
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  SELECTED_PROJECTS=()

  # Parse arguments
  if [ $# -eq 0 ]; then
    select_projects_interactively || return 1
  else
    for arg in "$@"; do
      if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]; then
        print_usage
        return 0
      fi
      if get_project_path "$arg" > /dev/null; then
        SELECTED_PROJECTS+=("$arg")
      else
        echo "Unknown project: $arg"
        print_usage
        return 1
      fi
    done
  fi

  # Open one WezTerm tab per selected project
  for project_name in "${SELECTED_PROJECTS[@]}"; do
    local project_path
    project_path=$(get_project_path "$project_name")

    # Spawn a new tab, set the title from inside the shell so WezTerm respects it,
    # run sbt test, keep the shell open after so you can read the output
    local pane_id
    pane_id=$(wezterm cli spawn --cwd "$project_path" -- zsh -l -c "printf '\033]0;${project_name}\007'; sbt -Dsbt.server.forcestart=false test; echo ''; echo 'Press any key to close...'; read -k1")

    # Also set the tab title via the CLI
    wezterm cli set-tab-title --pane-id "$pane_id" "$project_name"
  done

  echo ""
  echo "Opened ${#SELECTED_PROJECTS[@]} tab(s). Tests are running in WezTerm."
  echo ""
}

main "$@"
