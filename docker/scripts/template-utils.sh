#!/bin/bash

# Function to substitute variables in template files
substitute_template_variables() {
    local template_file="$1"
    local output_file="$2"
    
    if [ ! -f "$template_file" ]; then
        echo "[TemplateSubstitution ERROR] Template file not found: $template_file"
        return 1
    fi
    
    echo "[TemplateSubstitution] Processing template: $template_file -> $output_file"
    
    # Create output directory if it doesn't exist
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"
    
    # Copy template and substitute variables
    cp "$template_file" "$output_file"
    
    # Substitute all variables
    sed -i "s|{{CUSTOM_THEME_SLUG}}|${CUSTOM_THEME_SLUG}|g" "$output_file"
    sed -i "s|{{STARTER_THEME_SLUG}}|${STARTER_THEME_SLUG}|g" "$output_file"
    sed -i "s|{{WORDPRESS_HOST_PORT}}|${WORDPRESS_HOST_PORT}|g" "$output_file"
    
    echo "[TemplateSubstitution] Template processed successfully: $output_file"
}

# Function to copy entire template directory structure with variable substitution
copy_template_directory() {
    local template_dir="$1"
    local output_dir="$2"
    
    if [ ! -d "$template_dir" ]; then
        echo "[TemplateSubstitution ERROR] Template directory not found: $template_dir"
        return 1
    fi
    
    echo "[TemplateSubstitution] Copying template directory: $template_dir -> $output_dir"
    
    # Find all files (not just .template) and process them
    find "$template_dir" -type f | while read -r template_file; do
        # Calculate relative path from template_dir
        local relative_path="${template_file#$template_dir/}"
        local output_file="$output_dir/$relative_path"
        
        substitute_template_variables "$template_file" "$output_file"
    done
    
    echo "[TemplateSubstitution] Template directory copied successfully"
}
