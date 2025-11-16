#!/bin/bash

# Create boilerplate function for pytest

pytest_boilerplate() {
    # Accept destination path as parameter
    local destination_path="$1"
    
    # Get the script directory and project root
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root="$(cd "$script_dir/.." && pwd)"
    
    local config_file="$project_root/models/pytest/config/config.json"
    local content_service_dir="$project_root/content-as-service"
    
    # Validate destination path parameter
    if [ -z "$destination_path" ]; then
        echo "Error: Destination path is required"
        return 1
    fi
    
    # Ensure destination directory exists (should already be resolved by caller)
    if [ ! -d "$destination_path" ]; then
        echo "Warning: Destination directory does not exist, attempting to create: $destination_path"
        mkdir -p "$destination_path" || {
            echo "Error: Failed to create destination directory: $destination_path"
            return 1
        }
    fi
    
    # Store original directory
    local original_dir="$(pwd)"
    
    # Change to destination directory
    cd "$destination_path" || {
        echo "Error: Cannot access destination directory: $destination_path"
        return 1
    }
    
    echo "Destination directory: $destination_path"
    echo ""
    
    # Store entire JSON as an object
    json_obj=$(jq '.' "$config_file")
    
    # Get the root directory name from config.json
    # Extracts the first key from the "root" object in config.json
    root_dir=$(echo "$json_obj" | jq -r '.root | keys[0]')
    
    # Validate that we got a root directory name from config.json
    if [ -z "$root_dir" ] || [ "$root_dir" = "null" ]; then
        echo "Error: Could not read root directory name from config.json"
        echo "Config file: $config_file"
        return 1
    fi
    
    echo "Creating project structure from $config_file..."
    echo "Root directory name from config.json: $root_dir"
    echo ""
    
    # Create the root directory (from config.json) inside the destination
    mkdir -p "$root_dir"
    cd "$root_dir" || return 1
    
    # Create root-level directories
    echo "Creating root-level directories..."
    root_dirs=$(echo "$json_obj" | jq -r ".root[\"$root_dir\"].directories[]? // empty")
    if [ -n "$root_dirs" ]; then
        while IFS= read -r dir; do
            if [ -n "$dir" ]; then
                mkdir -p "$dir"
                echo "  Created directory: $dir"
            fi
        done <<< "$root_dirs"
    fi
    
    # Create root-level files
    echo "Creating root-level files..."
    root_files=$(echo "$json_obj" | jq -r ".root[\"$root_dir\"].files[]? // empty")
    if [ -n "$root_files" ]; then
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                touch "$file"
                echo "  Created file: $file"
            fi
        done <<< "$root_files"
    fi
    
    # Process modules
    echo "Processing modules..."
    modules=$(echo "$json_obj" | jq -r ".root[\"$root_dir\"].modules | keys[]? // empty")
    if [ -n "$modules" ]; then
        while IFS= read -r module_name; do
            if [ -n "$module_name" ]; then
                module_path="modules/$module_name"
                mkdir -p "$module_path"
                echo "  Created module directory: $module_path"
                
                # Get module configuration
                module_config=$(echo "$json_obj" | jq ".root[\"$root_dir\"].modules[\"$module_name\"]")
                
                # Create module-level directories
                module_dirs=$(echo "$module_config" | jq -r '.directories[]? // empty')
                if [ -n "$module_dirs" ]; then
                    while IFS= read -r dir; do
                        if [ -n "$dir" ]; then
                            mkdir -p "$module_path/$dir"
                            echo "    Created directory: $module_path/$dir"
                        fi
                    done <<< "$module_dirs"
                fi
                
                # Create sub-modules (as directories) and add __init__.py files
                submodules=$(echo "$module_config" | jq -r '.["sub-modules"]?[]? // empty')
                if [ -n "$submodules" ]; then
                    while IFS= read -r submodule; do
                        if [ -n "$submodule" ]; then
                            mkdir -p "$module_path/$submodule"
                            echo "    Created sub-module: $module_path/$submodule"
                            # Create __init__.py file for each sub-module
                            touch "$module_path/$submodule/__init__.py"
                            echo "      Created __init__.py in: $module_path/$submodule"
                        fi
                    done <<< "$submodules"
                fi
                
                # Create module-level files
                module_files=$(echo "$module_config" | jq -r '.files[]? // empty')
                if [ -n "$module_files" ]; then
                    while IFS= read -r file; do
                        if [ -n "$file" ]; then
                            touch "$module_path/$file"
                            echo "    Created file: $module_path/$file"
                        fi
                    done <<< "$module_files"
                fi
            fi
        done <<< "$modules"
    fi
    
    # Copy all files from content-as-service to root directory
    echo ""
    echo "Copying files from content-as-service to root directory..."
    
    # Check if content-as-service directory exists
    if [ ! -d "$content_service_dir" ]; then
        echo "Warning: content-as-service directory not found at $content_service_dir"
    else
        # Copy all files from content-as-service to current root directory
        files_copied=0
        if [ "$(ls -A "$content_service_dir" 2>/dev/null)" ]; then
            for file in "$content_service_dir"/* "$content_service_dir"/.*; do
                # Skip . and .. entries
                [ -e "$file" ] || continue
                filename=$(basename "$file")
                [ "$filename" = "." ] || [ "$filename" = ".." ] && continue
                
                if [ -f "$file" ]; then
                    cp -v "$file" .
                    ((files_copied++))
                fi
            done
            
            if [ $files_copied -gt 0 ]; then
                echo "  Copied $files_copied file(s) from content-as-service"
            else
                echo "  No files found in content-as-service directory"
            fi
        else
            echo "  content-as-service directory is empty"
        fi
    fi
    
    # Get the full path of the created boilerplate
    local boilerplate_full_path="$(pwd)"
    
    # Return to original directory
    cd "$original_dir" || return 1
    
    echo ""
    echo "Project structure created successfully!"
    echo "Boilerplate location: $boilerplate_full_path"
    echo "Root directory: $root_dir"
}