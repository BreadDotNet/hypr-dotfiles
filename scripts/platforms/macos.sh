#!/bin/sh

platform_packages_list() {
    printf 'Homebrew bundle: %s\n' "$DOTFILES_ROOT/packages-list/Brewfile"
    [ -f "$DOTFILES_ROOT/packages-list/Brewfile" ] && sed 's/^/  /' "$DOTFILES_ROOT/packages-list/Brewfile"
}

platform_packages_install() {
    dotfiles_brewfile="$DOTFILES_ROOT/packages-list/Brewfile"
    [ -f "$dotfiles_brewfile" ] || dotfiles_die "missing Brewfile: $dotfiles_brewfile"
    if ! command -v brew >/dev/null 2>&1; then
        if [ "$DOTFILES_DRY_RUN" -eq 0 ]; then
            dotfiles_die "Homebrew is not installed; install it separately and explicitly"
        fi
        dotfiles_warn "Homebrew is not installed; showing the command without running it"
    fi
    set -- brew bundle --file "$dotfiles_brewfile"
    dotfiles_print_command "$@"
    if [ "$DOTFILES_DRY_RUN" -eq 0 ]; then
        "$@"
    else
        dotfiles_info "dry-run complete; Homebrew was not invoked"
    fi
}

platform_theme_sync_appearance() {
    platform_theme_mode=$1
    command -v osascript >/dev/null 2>&1 || return 3
    case $platform_theme_mode in
        dark) platform_theme_boolean=true ;;
        light) platform_theme_boolean=false ;;
        *) return 1 ;;
    esac
    osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to $platform_theme_boolean" >/dev/null
}
