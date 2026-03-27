#!/bin/bash

# Interactive file/folder deletion with trash support
# Usage: wyx delete [path]

# Colors
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)
BOLD=$(tput bold)

# Check if trash command is available
has_trash_cmd() {
    command -v trash >/dev/null 2>&1
}

# Move item to trash using available method
move_to_trash() {
    local item="$1"
    
    if has_trash_cmd; then
        trash "$item" 2>/dev/null
        return $?
    else
        # Fallback to osascript on macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            osascript -e "tell application \"Finder\" to delete POSIX file \"$(cd "$(dirname "$item")" && pwd)/$(basename "$item")\"" >/dev/null 2>&1
            return $?
        else
            sys.log.error "No trash command available. Install 'trash-cli' or use 'rm' manually."
            return 1
        fi
    fi
}

# Get directory size and file count
get_dir_info() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        local file_count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
        local size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        echo "$file_count files ($size)"
    fi
}

# Interactive file selector with arrow keys
interactive_select() {
    local target_dir="${1:-.}"
    
    # Get list of files/folders (excluding . and ..)
    local -a items=()
    while IFS= read -r line; do
        items+=("$line")
    done < <(ls -A "$target_dir" 2>/dev/null | sort)
    
    if [[ ${#items[@]} -eq 0 ]]; then
        sys.log.warn "No items found in directory"
        return 1
    fi
    
    # Initialize selection array (0 = not selected, 1 = selected)
    local -a selected=()
    for ((i=0; i<${#items[@]}; i++)); do
        selected[$i]=0
    done
    
    local current=0
    local key=""
    
    # Hide cursor
    tput civis
    
    # Function to draw menu
    draw_menu() {
        clear
        sys.log.h1 "Select files to delete (↑↓ to navigate, SPACE to select, ENTER to confirm, q to quit)"
        echo ""
        
        local selected_count=0
        for ((i=0; i<${#items[@]}; i++)); do
            local item="${items[$i]}"
            local full_path="$target_dir/$item"
            local marker="[ ]"
            local color="$RESET"
            
            if [[ ${selected[$i]} -eq 1 ]]; then
                marker="[${GREEN}✓${RESET}]"
                selected_count=$((selected_count + 1))
            fi
            
            # Highlight current line
            if [[ $i -eq $current ]]; then
                color="$BOLD$CYAN"
            fi
            
            # Add directory indicator and info
            if [[ -d "$full_path" ]]; then
                local dir_info=$(get_dir_info "$full_path")
                echo -e "${color}${marker} ${item}/ ${BLUE}(${dir_info})${RESET}"
            elif [[ -L "$full_path" ]]; then
                echo -e "${color}${marker} ${item} ${ORANGE}(symlink)${RESET}"
            else
                echo -e "${color}${marker} ${item}${RESET}"
            fi
        done
        
        echo ""
        sys.log.h2 "→ Selected: ${selected_count} item(s)"
    }
    
    # Main loop
    while true; do
        draw_menu
        
        # Read single character
        read -rsn1 key
        
        # Handle escape sequences for arrow keys
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 key
            case "$key" in
                '[A') # Up arrow
                    ((current--))
                    [[ $current -lt 0 ]] && current=$((${#items[@]} - 1))
                    ;;
                '[B') # Down arrow
                    ((current++))
                    [[ $current -ge ${#items[@]} ]] && current=0
                    ;;
            esac
        elif [[ "$key" == " " ]]; then
            # Toggle selection
            if [[ ${selected[$current]} -eq 0 ]]; then
                selected[$current]=1
            else
                selected[$current]=0
            fi
        elif [[ "$key" == "" ]]; then
            # Enter key - confirm selection
            break
        elif [[ "$key" == "q" ]] || [[ "$key" == "Q" ]]; then
            # Quit
            tput cnorm
            clear
            sys.log.info "Cancelled"
            return 0
        fi
    done
    
    # Show cursor
    tput cnorm
    clear
    
    # Check if anything is selected
    local selected_items=()
    for ((i=0; i<${#items[@]}; i++)); do
        if [[ ${selected[$i]} -eq 1 ]]; then
            selected_items+=("${items[$i]}")
        fi
    done
    
    if [[ ${#selected_items[@]} -eq 0 ]]; then
        sys.log.info "No items selected"
        return 0
    fi
    
    # Show selected items and confirm
    sys.log.h1 "Selected items to delete:"
    echo ""
    for item in "${selected_items[@]}"; do
        local full_path="$target_dir/$item"
        if [[ -d "$full_path" ]]; then
            local dir_info=$(get_dir_info "$full_path")
            echo "  ${RED}✗${RESET} ${item}/ ${BLUE}(${dir_info})${RESET}"
        else
            echo "  ${RED}✗${RESET} ${item}"
        fi
    done
    echo ""
    
    # Warning for directories
    local has_dirs=false
    for item in "${selected_items[@]}"; do
        if [[ -d "$target_dir/$item" ]]; then
            has_dirs=true
            break
        fi
    done
    
    if [[ "$has_dirs" == true ]]; then
        sys.log.warn "Warning: Some selected items are directories with contents"
        echo ""
    fi
    
    # Final confirmation
    echo -n "${ORANGE}Move these ${#selected_items[@]} item(s) to Trash? [y/N]:${RESET} "
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        sys.log.info "Cancelled"
        return 0
    fi
    
    echo ""
    
    # Delete items
    local success_count=0
    local fail_count=0
    
    for item in "${selected_items[@]}"; do
        local full_path="$target_dir/$item"
        if move_to_trash "$full_path"; then
            sys.log.info "✓ Moved to Trash: $item"
            ((success_count++))
        else
            sys.log.error "✗ Failed to delete: $item"
            ((fail_count++))
        fi
    done
    
    echo ""
    if [[ $success_count -gt 0 ]]; then
        sys.log.info "Successfully deleted $success_count item(s)"
    fi
    if [[ $fail_count -gt 0 ]]; then
        sys.log.error "Failed to delete $fail_count item(s)"
    fi
}

# Main execution
if wyxd.arggt "1"; then
    # Use provided path
    target_path="$1"
    if [[ ! -d "$target_path" ]]; then
        sys.log.error "Error: '$target_path' is not a valid directory"
        exit 1
    fi
    interactive_select "$target_path"
else
    # Use current directory
    interactive_select "."
fi
