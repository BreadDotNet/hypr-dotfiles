#!/bin/sh

dotfiles_info() {
    printf '%s\n' "dotfiles: $*"
}

dotfiles_warn() {
    printf '%s\n' "dotfiles: warning: $*" >&2
}

dotfiles_die() {
    printf '%s\n' "dotfiles: error: $*" >&2
    exit 1
}

dotfiles_validate_name() {
    dotfiles_validate_value=$1
    dotfiles_validate_kind=$2
    case $dotfiles_validate_value in
        ''|[!A-Za-z0-9]*|*[!A-Za-z0-9._-]*)
            dotfiles_die "invalid $dotfiles_validate_kind name: $dotfiles_validate_value"
            ;;
    esac
}

dotfiles_make_temp_file() {
    dotfiles_temp_label=$1
    dotfiles_temp_path=$(mktemp "${DOTFILES_TEMP_DIR:?DOTFILES_TEMP_DIR is not set}/${dotfiles_temp_label}.XXXXXX") ||
        dotfiles_die "could not create a temporary file"
    printf '%s\n' "$dotfiles_temp_path"
}

dotfiles_cleanup_temps() {
    case ${DOTFILES_TEMP_DIR:-} in
        "${TMPDIR:-/tmp}"/dotfiles-cli.*) rm -rf "$DOTFILES_TEMP_DIR" ;;
        '') ;;
        *) dotfiles_warn "refusing to remove unexpected temporary path: $DOTFILES_TEMP_DIR" ;;
    esac
}

dotfiles_print_command() {
    printf '  $'
    for dotfiles_print_arg do
        dotfiles_print_escaped=$(printf '%s' "$dotfiles_print_arg" | sed "s/'/'\\\\''/g")
        printf " '%s'" "$dotfiles_print_escaped"
    done
    printf '\n'
}

dotfiles_count_lines() {
    awk 'NF { count++ } END { print count + 0 }' "$1"
}
