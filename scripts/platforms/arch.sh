#!/bin/sh

platform_packages_list() {
    dotfiles_print_list_file "Arch official packages" "$DOTFILES_ROOT/packages-list/arch.txt"
    dotfiles_print_list_file "AUR candidates (manual only)" "$DOTFILES_ROOT/packages-list/arch-aur.txt"
}

platform_packages_install() {
    dotfiles_arch_list="$DOTFILES_ROOT/packages-list/arch.txt"
    [ -f "$dotfiles_arch_list" ] || dotfiles_die "missing Arch package list: $dotfiles_arch_list"
    command -v pacman >/dev/null 2>&1 || dotfiles_die "pacman was not found; refusing to guess a package manager"

    set -- sudo pacman -S --needed
    while IFS= read -r dotfiles_arch_package || [ -n "$dotfiles_arch_package" ]; do
        dotfiles_arch_package=${dotfiles_arch_package%%#*}
        dotfiles_arch_package=$(printf '%s' "$dotfiles_arch_package" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        [ -n "$dotfiles_arch_package" ] || continue
        dotfiles_validate_name "$dotfiles_arch_package" package
        set -- "$@" "$dotfiles_arch_package"
    done < "$dotfiles_arch_list"

    dotfiles_print_command "$@"
    if [ "$DOTFILES_DRY_RUN" -eq 0 ]; then
        "$@"
    else
        dotfiles_info "dry-run complete; pacman was not invoked"
    fi
    printf '\nAUR packages are never installed automatically. Review manually:\n'
    dotfiles_print_list_file "AUR candidates" "$DOTFILES_ROOT/packages-list/arch-aur.txt"
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
