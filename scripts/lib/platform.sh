#!/bin/sh

dotfiles_detect_platform() {
    DOTFILES_KERNEL=${DOTFILES_UNAME_S:-$(uname -s)}
    DOTFILES_PLATFORM=unknown
    DOTFILES_PLATFORM_LABEL=$DOTFILES_KERNEL
    DOTFILES_DISTRO_ID=
    DOTFILES_DISTRO_NAME=
    DOTFILES_ADAPTER=unsupported

    case $DOTFILES_KERNEL in
        Darwin)
            DOTFILES_PLATFORM=macos
            DOTFILES_PLATFORM_LABEL=macOS
            DOTFILES_ADAPTER=macos
            ;;
        Linux)
            DOTFILES_PLATFORM=linux
            DOTFILES_ADAPTER=linux
            dotfiles_os_release=${DOTFILES_OS_RELEASE:-/etc/os-release}
            if [ -r "$dotfiles_os_release" ]; then
                ID=
                NAME=
                PRETTY_NAME=
                # os-release is a system-owned shell-compatible assignment file.
                # shellcheck disable=SC1090
                . "$dotfiles_os_release"
                DOTFILES_DISTRO_ID=${ID:-unknown}
                DOTFILES_DISTRO_NAME=${PRETTY_NAME:-${NAME:-Linux}}
            else
                DOTFILES_DISTRO_ID=unknown
                DOTFILES_DISTRO_NAME=Linux
            fi
            DOTFILES_PLATFORM_LABEL=$DOTFILES_DISTRO_NAME
            if [ "$DOTFILES_DISTRO_ID" = arch ]; then
                DOTFILES_ADAPTER=arch
            fi
            ;;
    esac
    export DOTFILES_KERNEL DOTFILES_PLATFORM DOTFILES_PLATFORM_LABEL
    export DOTFILES_DISTRO_ID DOTFILES_DISTRO_NAME DOTFILES_ADAPTER
}

dotfiles_print_platform() {
    printf 'Platform: %s' "$DOTFILES_PLATFORM_LABEL"
    if [ "$DOTFILES_PLATFORM" = linux ]; then
        printf ' (id=%s, adapter=%s)' "$DOTFILES_DISTRO_ID" "$DOTFILES_ADAPTER"
    else
        printf ' (adapter=%s)' "$DOTFILES_ADAPTER"
    fi
    printf '\n'
}

dotfiles_manifest_layers() {
    printf '%s\n' common
    case $DOTFILES_PLATFORM in
        linux)
            printf '%s\n' linux
            [ "$DOTFILES_ADAPTER" = arch ] && printf '%s\n' arch
            ;;
        macos) printf '%s\n' macos ;;
    esac
    return 0
}
