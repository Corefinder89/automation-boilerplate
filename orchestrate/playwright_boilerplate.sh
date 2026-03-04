#!/bin/bash

# Function to safely expand path (replaces ~ with $HOME and expands environment variables)
expand_path() {
    local path="$1"
    
    # Expand ~ to $HOME (handle both ~ and ~/path)
    case "$path" in
        ~)
            path="$HOME"
            ;;
        ~/*)
            path="${HOME}${path#~}"
            ;;
        ~*)
            # Handle ~username (though we'll just expand to $HOME for security)
            path="${HOME}${path#~}"
            ;;
    esac
    
    # Expand common environment variables safely
    # Only expand variables that are known to be safe
    path="${path//\$HOME/$HOME}"
    path="${path//\$USER/$USER}"
    path="${path//\$PWD/$(pwd)}"
    
    echo "$path"
}

# Create boilerplate function for playwright
playwright_boilerplate() {
    # Accept destination path as parameter
    local destination_path="$1"
    
    # Get the script directory and project root
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local project_root="$(cd "$script_dir/.." && pwd)"
    
    local config_file="$project_root/models/playwright/config/config.json"
    local content_service_dir="$project_root/content-as-service"
    
    # Validate destination path parameter
    if [ -z "$destination_path" ]; then
        echo "Error: Destination path is required"
        return 1
    fi
    
    # Store original directory
    local original_dir="$(pwd)"
    
    # Expand ~ and variables in the path safely
    destination_path=$(expand_path "$destination_path")
    
    # Resolve absolute path - handle both existing and non-existing directories
    if [ -d "$destination_path" ]; then
        # Directory exists, resolve to absolute path
        destination_path=$(cd "$destination_path" && pwd)
    else
        # Directory doesn't exist, resolve parent and construct full path
        local parent_dir=$(dirname "$destination_path")
        local dir_name=$(basename "$destination_path")
        
        if [ -d "$parent_dir" ]; then
            # Parent exists, resolve it and construct full path
            parent_dir=$(cd "$parent_dir" && pwd)
            destination_path="$parent_dir/$dir_name"
        elif [ "$parent_dir" = "." ] || [ "$parent_dir" = "$destination_path" ]; then
            # Relative path without parent, use current directory
            destination_path="$(pwd)/$dir_name"
        else
            # Parent doesn't exist, try to expand and resolve safely
            parent_dir=$(expand_path "$parent_dir")
            if [ -d "$parent_dir" ]; then
                parent_dir=$(cd "$parent_dir" && pwd)
                destination_path="$parent_dir/$dir_name"
            else
                echo "Error: Parent directory does not exist: $parent_dir"
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
    
    # Change to destination directory
    cd "$destination_path" || {
        echo "Error: Cannot access destination directory: $destination_path"
        return 1
    }
    
    echo "Destination directory: $destination_path"
    echo ""
    
    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        echo "Error: Config file not found at $config_file"
        return 1
    fi
    
    # Store entire JSON as an object
    json_obj=$(jq '.' "$config_file" 2>&1)
    local jq_exit_code=$?
    
    # Check if jq command succeeded
    if [ $jq_exit_code -ne 0 ] || [ -z "$json_obj" ]; then
        echo "Error: Failed to read config file: $config_file"
        echo "jq error: $json_obj"
        return 1
    fi
    
    # Get the root directory name from config.json
    root_dir=$(echo "$json_obj" | jq -r '.root | keys[0]')
    
    # Validate that we got a root directory name from config.json
    if [ -z "$root_dir" ] || [ "$root_dir" = "null" ]; then
        echo "Error: Could not read root directory name from config.json"
        echo "Config file: $config_file"
        echo "JSON content: $json_obj"
        return 1
    fi
    
    echo "Creating Playwright project structure from $config_file..."
    echo ""
    
    # Create the root directory (from config.json) inside the destination
    mkdir -p "$root_dir" || {
        echo "Error: Failed to create root directory: $root_dir"
        return 1
    }
    
    cd "$root_dir" || {
        echo "Error: Failed to change into root directory: $root_dir"
        return 1
    }
    
    # Function to recursively create directory structure
    create_directory_structure() {
        local json_path="$1"
        local current_path="$2"
        
        # Get directories from the current JSON path
        local directories=$(echo "$json_obj" | jq -r "$json_path | keys[]? // empty" 2>/dev/null)
        
        if [ -n "$directories" ]; then
            while IFS= read -r dir; do
                if [ -n "$dir" ]; then
                    local full_path="${current_path:+$current_path/}$dir"
                    mkdir -p "$full_path"
                    echo "  Created directory: $full_path"
                    
                    # Check if this directory has content (files or subdirectories)
                    local dir_content=$(echo "$json_obj" | jq -r "$json_path[\"$dir\"]" 2>/dev/null)
                    
                    # If it's an array, create files from the array
                    if echo "$dir_content" | jq -e '. | type' >/dev/null 2>&1 && [ "$(echo "$dir_content" | jq -r '. | type')" = "array" ]; then
                        # Create files from array
                        local files=$(echo "$dir_content" | jq -r '.[]? // empty')
                        if [ -n "$files" ]; then
                            while IFS= read -r file; do
                                if [ -n "$file" ]; then
                                    touch "$full_path/$file"
                                    echo "    Created file: $full_path/$file"
                                fi
                            done <<< "$files"
                        fi
                    # If it's an object and not empty, recursively create subdirectories
                    elif echo "$dir_content" | jq -e '. | type' >/dev/null 2>&1 && [ "$(echo "$dir_content" | jq -r '. | type')" = "object" ] && [ "$(echo "$dir_content" | jq -r '. | keys | length')" -gt 0 ]; then
                        # Recursively create subdirectories
                        create_directory_structure "$json_path[\"$dir\"]" "$full_path"
                    fi
                fi
            done <<< "$directories"
        fi
    }
    
    # Start creating the directory structure from the root
    echo "Creating directory structure..."
    create_directory_structure ".root[\"$root_dir\"].directories" ""
    
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
                filename="$(basename "$file")"
                ([ "$filename" = "." ] || [ "$filename" = ".." ]) && continue
                
                # Skip .pre-commit-config.yaml for Playwright projects
                [ "$filename" = ".pre-commit-config.yaml" ] && continue
                
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
    
    # Create Playwright specific files
    echo ""
    echo "Creating Playwright specific configuration files..."
    
    # Create playwright.config.js if it doesn't exist
    if [ ! -f "playwright.config.js" ]; then
        cat > playwright.config.js << 'EOF'
// @ts-check
import { defineConfig, devices } from '@playwright/test';

/**
 * @see https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  testDir: './src/tests',
  /* Run tests in files in parallel */
  fullyParallel: true,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,
  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: 'html',
  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Base URL to use in actions like `await page.goto('/')`. */
    // baseURL: 'http://127.0.0.1:3000',
    
    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: 'on-first-retry',
  },

  /* Configure projects for major browsers */
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },

    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    /* Test against mobile viewports. */
    // {
    //   name: 'Mobile Chrome',
    //   use: { ...devices['Pixel 5'] },
    // },
    // {
    //   name: 'Mobile Safari',
    //   use: { ...devices['iPhone 12'] },
    // },

    /* Test against branded browsers. */
    // {
    //   name: 'Microsoft Edge',
    //   use: { ...devices['Desktop Edge'], channel: 'msedge' },
    // },
    // {
    //   name: 'Google Chrome',
    //   use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    // },
  ],

  /* Run your local dev server before starting the tests */
  // webServer: {
  //   command: 'npm run start',
  //   url: 'http://127.0.0.1:3000',
  //   reuseExistingServer: !process.env.CI,
  // },
});
EOF
        echo "  Created: playwright.config.js"
    fi
    
    # Create package.json if it doesn't exist
    if [ ! -f "package.json" ]; then
        cat > package.json << 'EOF'
{
  "name": "playwright-automation-testing",
  "version": "1.0.0",
  "description": "Playwright automation testing boilerplate",
  "main": "index.js",
  "scripts": {
    "test": "playwright test",
    "test:headed": "playwright test --headed",
    "test:ui": "playwright test --ui",
    "test:debug": "playwright test --debug",
    "report": "playwright show-report"
  },
  "keywords": ["playwright", "testing", "automation", "e2e"],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@playwright/test": "^1.40.0"
  }
}
EOF
        echo "  Created: package.json"
    fi
    
    # Get the full path of the created boilerplate
    local boilerplate_full_path="$(pwd)"
    
    # Return to original directory
    cd "$original_dir" || return 1
    
    echo ""
    echo "Playwright project structure created successfully!"
    echo "Boilerplate location: $boilerplate_full_path"
    echo "Root directory: $root_dir"
    echo ""
    echo "Next steps:"
    echo "1. cd $boilerplate_full_path"
    echo "2. npm install"
    echo "3. npx playwright install"
    echo "4. npm test"
}