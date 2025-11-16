#!/bin/bash

# Source the pytest boilerplate script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/pytest_boilerplate.sh"

# Function to get destination directory from user
get_destination_directory() {
    read -r destination_path
    
    # If no input, use current directory
    if [ -z "$destination_path" ]; then
        destination_path="$(pwd)"
    fi
    
    # Expand ~ and variables
    destination_path=$(eval echo "$destination_path")
    
    # Resolve to absolute path if the directory exists, otherwise resolve parent
    if [ -d "$destination_path" ]; then
        destination_path=$(cd "$destination_path" && pwd)
    else
        # Get the absolute path of the parent and append the basename
        local parent_dir=$(dirname "$destination_path")
        local dir_name=$(basename "$destination_path")
        
        if [ -d "$parent_dir" ]; then
            parent_dir=$(cd "$parent_dir" && pwd)
            destination_path="$parent_dir/$dir_name"
        elif [ "$parent_dir" = "." ]; then
            # If parent is ".", use current directory
            destination_path="$(pwd)/$dir_name"
        else
            # Expand parent directory path
            parent_dir=$(eval echo "$parent_dir")
            if [ -d "$parent_dir" ]; then
                parent_dir=$(cd "$parent_dir" && pwd)
                destination_path="$parent_dir/$dir_name"
            else
                echo "Error: Cannot resolve destination path: $destination_path"
                return 1
            fi
        fi
    fi
    
    # Create destination directory if it doesn't exist
    if [ ! -d "$destination_path" ]; then
        echo "Creating destination directory: $destination_path"
        mkdir -p "$destination_path" || {
            echo "Error: Failed to create destination directory: $destination_path"
            return 1
        }
    fi
    
    echo "$destination_path"
}

# Function to display menu and get user selection (non-interactive)
select_framework() {
    echo "Please select a framework:" >&2
    echo "1) python" >&2
    echo "2) playwright" >&2
    echo "" >&2
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
        1)
            echo "python"
            ;;
        2)
            echo "playwright"
            ;;
        *)
            echo "Invalid choice. Please select 1 or 2." >&2
            return 1
            ;;
    esac
}

# Function using select command (interactive)
select_framework_interactive() {
    echo "Please select a framework:" >&2
    PS3="Enter your choice (1 or 2): "
    options=("python" "playwright")
    
    select option in "${options[@]}"; do
        if [ -n "$option" ]; then
            echo "$option"
            break
        else
            echo "Invalid option. Please select 1 or 2." >&2
        fi
    done
}

# Main script
main() {
    local selected
    local destination_path
    
    # Get destination directory from user first
    destination_path=$(get_destination_directory)
    if [ $? -ne 0 ] || [ -z "$destination_path" ]; then
        echo "Error: Failed to get destination directory"
        return 1
    fi
    
    echo ""
    echo "Destination directory: $destination_path"
    echo ""
    
    # Check if running in interactive terminal
    if [ -t 0 ]; then
        # Interactive mode - use select command
        selected=$(select_framework_interactive)
    else
        # Non-interactive mode - use simple read
        selected=$(select_framework)
    fi
    
    # Check if framework selection was successful
    if [ -z "$selected" ] || [ "$selected" = "null" ]; then
        echo "Error: Failed to select framework"
        return 1
    fi
    
    # Use the selected framework
    echo ""
    echo "Processing with framework: $selected"
    echo ""
    
    # Execute boilerplate code in the destination path based on selected framework
    case $selected in
        python)
           # Call the function to create the boilerplate for pytest
           if type pytest_boilerplate &>/dev/null; then
               pytest_boilerplate "$destination_path"
           else
               echo "Error: pytest_boilerplate function not found"
               return 1
           fi
            ;;
        playwright)
           # Call the function to create the boilerplate for playwright
           if type create_playwright_boilerplate &>/dev/null; then
               create_playwright_boilerplate "$destination_path"
           else
               echo "Error: create_playwright_boilerplate function not found"
               return 1
           fi
            ;;
        *)
            echo "Error: Unknown framework: $selected"
            return 1
            ;;
    esac
}

# Run main function
 echo ""
 echo "Where should the boilerplate code be created?"
 echo "Enter the full path to the destination directory (or press Enter to use current directory):"
main "$@"
