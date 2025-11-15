#!/bin/bash

# Function to display menu and get user selection
select_framework() {
    echo "Please select a framework:"
    echo "1) python"
    echo "2) playwright"
    echo ""
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
        1)
            selected="python"
            ;;
        2)
            selected="playwright"
            ;;
        *)
            echo "Invalid choice. Please select 1 or 2."
            exit 1
            ;;
    esac
    
    echo "You selected: $selected"
    return 0
}

# Alternative using select command (more interactive)
select_framework_interactive() {
    PS3="Please select a framework (enter number): "
    options=("python" "playwright")
    
    select option in "${options[@]}"; do
        if [ -n "$option" ]; then
            selected="$option"
            echo "You selected: $selected"
            break
        else
            echo "Invalid option. Please select 1 or 2."
        fi
    done
}

# Main script
main() {
    # Check if running in interactive terminal
    if [ -t 0 ]; then
        # Interactive mode - use select command
        select_framework_interactive
    else
        # Non-interactive mode - use simple read
        select_framework
    fi
    
    # Use the selected framework
    echo "Processing with framework: $selected"
    
    # Add your logic here based on the selected framework
    case $selected in
        python)
           # Call the function to create the boiler plate for pytest
            ;;
        playwright)
           # Call the functio to create the boiler plate for playwright
           create_playwright_boilerplate
            ;;
    esac
}

# Run main function
main "$@"
