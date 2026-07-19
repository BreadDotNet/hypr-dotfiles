#!/bin/sh

dotfiles_read_manifest() {
    dotfiles_manifest_path=$1
    dotfiles_manifest_output=$2
    [ -f "$dotfiles_manifest_path" ] || dotfiles_die "manifest not found: $dotfiles_manifest_path"

    while IFS= read -r dotfiles_manifest_line || [ -n "$dotfiles_manifest_line" ]; do
        dotfiles_manifest_line=${dotfiles_manifest_line%%#*}
        dotfiles_manifest_line=$(printf '%s' "$dotfiles_manifest_line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        [ -n "$dotfiles_manifest_line" ] || continue
        dotfiles_validate_name "$dotfiles_manifest_line" "package in $dotfiles_manifest_path"
        printf '%s\n' "$dotfiles_manifest_line" >> "$dotfiles_manifest_output"
    done < "$dotfiles_manifest_path"
}

dotfiles_select_packages() {
    dotfiles_select_output=$1
    dotfiles_select_explicit=$2
    dotfiles_select_host=$3
    : > "$dotfiles_select_output"

    if [ -n "$dotfiles_select_explicit" ]; then
        printf '%s\n' "$dotfiles_select_explicit" >> "$dotfiles_select_output"
    else
        dotfiles_layers_file=$(dotfiles_make_temp_file layers)
        dotfiles_manifest_layers > "$dotfiles_layers_file"
        while IFS= read -r dotfiles_layer; do
            [ -n "$dotfiles_layer" ] || continue
            dotfiles_read_manifest "$DOTFILES_ROOT/manifests/$dotfiles_layer.txt" "$dotfiles_select_output"
        done < "$dotfiles_layers_file"

        if [ -n "$dotfiles_select_host" ]; then
            dotfiles_host_manifest="$DOTFILES_ROOT/hosts/$dotfiles_select_host/manifest.txt"
            dotfiles_read_manifest "$dotfiles_host_manifest" "$dotfiles_select_output"
        fi
    fi

    dotfiles_unique_file=$(dotfiles_make_temp_file packages)
    awk 'NF && !seen[$0]++ { print }' "$dotfiles_select_output" > "$dotfiles_unique_file"
    cp "$dotfiles_unique_file" "$dotfiles_select_output"
    [ -s "$dotfiles_select_output" ] || dotfiles_die "package selection is empty"
}
