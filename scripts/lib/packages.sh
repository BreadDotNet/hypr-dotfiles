#!/bin/sh

dotfiles_source_platform_adapter() {
    dotfiles_adapter_path="$DOTFILES_ROOT/scripts/platforms/$DOTFILES_ADAPTER.sh"
    [ -f "$dotfiles_adapter_path" ] || dotfiles_die "platform adapter is missing: $dotfiles_adapter_path"
    # shellcheck disable=SC1090
    . "$dotfiles_adapter_path"
}

dotfiles_packages_list() {
    dotfiles_print_platform
    dotfiles_source_platform_adapter
    platform_packages_list
}

dotfiles_packages_install() {
    dotfiles_print_platform
    dotfiles_source_platform_adapter
    platform_packages_install
}

dotfiles_print_list_file() {
    dotfiles_list_title=$1
    dotfiles_list_file=$2
    printf '%s:\n' "$dotfiles_list_title"
    if [ -f "$dotfiles_list_file" ]; then
        sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' -e 's/^/  /' "$dotfiles_list_file"
    else
        printf '  (missing: %s)\n' "$dotfiles_list_file"
    fi
}
