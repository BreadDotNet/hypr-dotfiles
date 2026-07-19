#!/bin/sh

platform_packages_list() {
    printf '%s\n' "Package management is unsupported on platform '$DOTFILES_KERNEL'."
}

platform_packages_install() {
    dotfiles_die "package installation is unsupported on platform '$DOTFILES_KERNEL'"
}

platform_theme_sync_appearance() {
    return 3
}
