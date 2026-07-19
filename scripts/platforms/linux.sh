#!/bin/sh

platform_packages_list() {
    printf '%s\n' "No package list is selected for Linux distribution '$DOTFILES_DISTRO_ID'."
    printf '%s\n' "Common and Linux dotfiles remain installable. Add a dedicated adapter to manage packages."
}

platform_packages_install() {
    dotfiles_die "package installation is unsupported for Linux distribution '$DOTFILES_DISTRO_ID'; no package manager was guessed"
}

platform_theme_sync_appearance() {
    platform_theme_mode=$1
    command -v gsettings >/dev/null 2>&1 || return 3
    gsettings writable org.gnome.desktop.interface color-scheme 2>/dev/null | grep -qx true || return 3
    case $platform_theme_mode in
        dark) platform_theme_value=prefer-dark ;;
        light) platform_theme_value=prefer-light ;;
        *) return 1 ;;
    esac
    gsettings set org.gnome.desktop.interface color-scheme "$platform_theme_value"
}
