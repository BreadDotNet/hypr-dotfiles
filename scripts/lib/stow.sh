#!/bin/sh

dotfiles_check_stow() {
    command -v stow >/dev/null 2>&1 || dotfiles_die "GNU Stow is required but was not found in PATH"
}

dotfiles_validate_packages() {
    dotfiles_validate_packages_file=$1
    dotfiles_validate_failed=0
    while IFS= read -r dotfiles_validate_package; do
        [ -n "$dotfiles_validate_package" ] || continue
        dotfiles_validate_name "$dotfiles_validate_package" package
        if [ ! -d "$DOTFILES_ROOT/packages/$dotfiles_validate_package" ]; then
            dotfiles_warn "selected package does not exist: $dotfiles_validate_package"
            dotfiles_validate_failed=1
        fi
    done < "$dotfiles_validate_packages_file"
    [ "$dotfiles_validate_failed" -eq 0 ] || return 1
}

dotfiles_collect_targets() {
    dotfiles_collect_packages=$1
    dotfiles_collect_output=$2
    : > "$dotfiles_collect_output"
    while IFS= read -r dotfiles_collect_package; do
        [ -n "$dotfiles_collect_package" ] || continue
        dotfiles_collect_dir="$DOTFILES_ROOT/packages/$dotfiles_collect_package"
        find "$dotfiles_collect_dir" \( -type f -o -type l \) -print |
            while IFS= read -r dotfiles_collect_source; do
                dotfiles_collect_relative=${dotfiles_collect_source#"$dotfiles_collect_dir"/}
                printf '%s\t%s\n' "$dotfiles_collect_relative" "$dotfiles_collect_package"
            done >> "$dotfiles_collect_output"
    done < "$dotfiles_collect_packages"
}

dotfiles_check_duplicate_targets() {
    dotfiles_duplicate_packages=$1
    dotfiles_duplicate_targets=$(dotfiles_make_temp_file targets)
    dotfiles_duplicate_report=$(dotfiles_make_temp_file duplicates)
    dotfiles_collect_targets "$dotfiles_duplicate_packages" "$dotfiles_duplicate_targets"
    LC_ALL=C sort -t "$(printf '\t')" -k1,1 "$dotfiles_duplicate_targets" |
        awk -F '\t' '
            $1 == previous { print $1 " (" previous_package ", " $2 ")" }
            { previous=$1; previous_package=$2 }
        ' > "$dotfiles_duplicate_report"
    if [ -s "$dotfiles_duplicate_report" ]; then
        dotfiles_warn "conflicting package targets detected:"
        sed 's/^/  /' "$dotfiles_duplicate_report" >&2
        return 1
    fi
}

dotfiles_find_ordinary_conflicts() {
    dotfiles_conflict_packages=$1
    dotfiles_conflict_target_root=$2
    dotfiles_conflict_output=$3
    dotfiles_conflict_targets=$(dotfiles_make_temp_file conflict-targets)
    : > "$dotfiles_conflict_output"
    dotfiles_collect_targets "$dotfiles_conflict_packages" "$dotfiles_conflict_targets"
    while IFS="$(printf '\t')" read -r dotfiles_conflict_relative dotfiles_conflict_package; do
        [ -n "$dotfiles_conflict_relative" ] || continue
        dotfiles_conflict_target="$dotfiles_conflict_target_root/$dotfiles_conflict_relative"
        if [ -e "$dotfiles_conflict_target" ] && [ ! -L "$dotfiles_conflict_target" ]; then
            printf '%s\n' "$dotfiles_conflict_relative" >> "$dotfiles_conflict_output"
        fi
    done < "$dotfiles_conflict_targets"
}

dotfiles_stow_command() {
    dotfiles_stow_operation=$1
    dotfiles_stow_packages=$2
    dotfiles_stow_target=$3
    dotfiles_stow_simulate=$4

    set -- stow --no-folding --dir "$DOTFILES_ROOT/packages" --target "$dotfiles_stow_target"
    case $dotfiles_stow_operation in
        install) set -- "$@" --stow ;;
        restow) set -- "$@" --restow ;;
        uninstall) set -- "$@" --delete ;;
        *) dotfiles_die "internal error: invalid Stow operation $dotfiles_stow_operation" ;;
    esac
    [ "$dotfiles_stow_simulate" -eq 0 ] || set -- "$@" --simulate --verbose=1
    while IFS= read -r dotfiles_stow_package; do
        [ -n "$dotfiles_stow_package" ] || continue
        set -- "$@" "$dotfiles_stow_package"
    done < "$dotfiles_stow_packages"

    dotfiles_print_command "$@"
    "$@"
}

dotfiles_backup_conflicts() {
    dotfiles_backup_conflicts_file=$1
    dotfiles_backup_target_root=$2
    dotfiles_backup_root=${DOTFILES_BACKUP_ROOT:-$dotfiles_backup_target_root/.local/state/dotfiles/backups}
    dotfiles_backup_stamp=$(date '+%Y%m%d-%H%M%S')-$$
    DOTFILES_LAST_BACKUP="$dotfiles_backup_root/$dotfiles_backup_stamp"

    while IFS= read -r dotfiles_backup_relative; do
        [ -n "$dotfiles_backup_relative" ] || continue
        dotfiles_backup_source="$dotfiles_backup_target_root/$dotfiles_backup_relative"
        dotfiles_backup_destination="$DOTFILES_LAST_BACKUP/$dotfiles_backup_relative"
        mkdir -p "$(dirname "$dotfiles_backup_destination")"
        mv "$dotfiles_backup_source" "$dotfiles_backup_destination"
    done < "$dotfiles_backup_conflicts_file"
    export DOTFILES_LAST_BACKUP
}

dotfiles_print_backup_plan() {
    dotfiles_backup_plan_file=$1
    dotfiles_backup_plan_target=$2
    dotfiles_backup_plan_root=${DOTFILES_BACKUP_ROOT:-$dotfiles_backup_plan_target/.local/state/dotfiles/backups/TIMESTAMP}
    while IFS= read -r dotfiles_backup_plan_relative; do
        [ -n "$dotfiles_backup_plan_relative" ] || continue
        printf '  backup: %s -> %s/%s\n' \
            "$dotfiles_backup_plan_target/$dotfiles_backup_plan_relative" \
            "$dotfiles_backup_plan_root" "$dotfiles_backup_plan_relative"
    done < "$dotfiles_backup_plan_file"
}

dotfiles_manage_stow() {
    dotfiles_manage_operation=$1
    dotfiles_manage_packages=$2
    dotfiles_manage_target=$3

    dotfiles_check_stow
    dotfiles_validate_packages "$dotfiles_manage_packages" || dotfiles_die "invalid package selection"
    dotfiles_check_duplicate_targets "$dotfiles_manage_packages" || dotfiles_die "packages cannot be applied together"

    if [ ! -d "$dotfiles_manage_target" ]; then
        if [ "$dotfiles_manage_operation" = uninstall ]; then
            dotfiles_info "target does not exist; nothing to uninstall: $dotfiles_manage_target"
            return 0
        fi
        if [ "$DOTFILES_DRY_RUN" -eq 1 ]; then
            dotfiles_die "target does not exist for dry-run: $dotfiles_manage_target"
        fi
        mkdir -p "$dotfiles_manage_target"
    fi

    dotfiles_print_platform
    dotfiles_manage_count=$(dotfiles_count_lines "$dotfiles_manage_packages")
    printf 'Packages (%s): %s\n' "$dotfiles_manage_count" "$(tr '\n' ' ' < "$dotfiles_manage_packages" | sed 's/[[:space:]]*$//')"
    printf 'Target: %s\n' "$dotfiles_manage_target"

    if [ "$dotfiles_manage_operation" = uninstall ]; then
        dotfiles_stow_command uninstall "$dotfiles_manage_packages" "$dotfiles_manage_target" 1
        if [ "$DOTFILES_DRY_RUN" -eq 0 ]; then
            dotfiles_stow_command uninstall "$dotfiles_manage_packages" "$dotfiles_manage_target" 0
            dotfiles_info "uninstalled $dotfiles_manage_count package(s)"
        else
            dotfiles_info "dry-run complete; no links were removed"
        fi
        return 0
    fi

    dotfiles_manage_conflicts=$(dotfiles_make_temp_file conflicts)
    dotfiles_find_ordinary_conflicts "$dotfiles_manage_packages" "$dotfiles_manage_target" "$dotfiles_manage_conflicts"
    if [ -s "$dotfiles_manage_conflicts" ]; then
        dotfiles_warn "ordinary files or directories block managed targets:"
        sed 's/^/  /' "$dotfiles_manage_conflicts" >&2
        if [ "$DOTFILES_BACKUP_CONFLICTS" -eq 0 ]; then
            dotfiles_die "no files were changed; rerun with --backup-conflicts to move these paths to a recoverable backup"
        fi
        if [ "$DOTFILES_DRY_RUN" -eq 1 ]; then
            dotfiles_print_backup_plan "$dotfiles_manage_conflicts" "$dotfiles_manage_target"
            dotfiles_stow_command "$dotfiles_manage_operation" "$dotfiles_manage_packages" "$dotfiles_manage_target" 1 || true
            dotfiles_info "dry-run complete; conflicts would be backed up before Stow runs"
            return 0
        fi
        dotfiles_backup_conflicts "$dotfiles_manage_conflicts" "$dotfiles_manage_target"
        dotfiles_info "conflicts backed up to $DOTFILES_LAST_BACKUP"
    fi

    if ! dotfiles_stow_command "$dotfiles_manage_operation" "$dotfiles_manage_packages" "$dotfiles_manage_target" 1; then
        if [ -n "${DOTFILES_LAST_BACKUP:-}" ]; then
            dotfiles_warn "Stow preflight failed after backup; original files remain recoverable at $DOTFILES_LAST_BACKUP"
        fi
        dotfiles_die "Stow preflight failed; no links were changed"
    fi
    if [ "$DOTFILES_DRY_RUN" -eq 1 ]; then
        dotfiles_info "dry-run complete; no links were changed"
        return 0
    fi

    dotfiles_stow_command "$dotfiles_manage_operation" "$dotfiles_manage_packages" "$dotfiles_manage_target" 0
    dotfiles_info "$dotfiles_manage_operation completed for $dotfiles_manage_count package(s)"
    [ -z "${DOTFILES_LAST_BACKUP:-}" ] || dotfiles_info "backup retained at $DOTFILES_LAST_BACKUP"
}

dotfiles_doctor() {
    dotfiles_doctor_packages=$1
    dotfiles_doctor_target=$2
    dotfiles_doctor_fail=0
    dotfiles_print_platform
    printf 'Repository: %s\n' "$DOTFILES_ROOT"
    printf 'Target: %s\n' "$dotfiles_doctor_target"

    if command -v stow >/dev/null 2>&1; then
        printf 'GNU Stow: %s\n' "$(stow --version 2>/dev/null | sed -n '1p')"
    else
        dotfiles_warn "GNU Stow is missing"
        dotfiles_doctor_fail=1
    fi
    dotfiles_doctor_packages_valid=1
    if ! dotfiles_validate_packages "$dotfiles_doctor_packages"; then
        dotfiles_doctor_packages_valid=0
        dotfiles_doctor_fail=1
    fi
    if [ "$dotfiles_doctor_packages_valid" -eq 1 ] && ! dotfiles_check_duplicate_targets "$dotfiles_doctor_packages"; then
        dotfiles_doctor_fail=1
    fi

    dotfiles_doctor_conflicts=$(dotfiles_make_temp_file doctor-conflicts)
    if [ "$dotfiles_doctor_packages_valid" -eq 1 ]; then
        dotfiles_find_ordinary_conflicts "$dotfiles_doctor_packages" "$dotfiles_doctor_target" "$dotfiles_doctor_conflicts"
    fi
    if [ -s "$dotfiles_doctor_conflicts" ]; then
        dotfiles_warn "target conflicts:"
        sed 's/^/  /' "$dotfiles_doctor_conflicts" >&2
        dotfiles_doctor_fail=1
    else
        printf 'Target conflicts: none found\n'
    fi

    for dotfiles_doctor_tool in git zsh nvim tmux shellcheck shfmt; do
        if command -v "$dotfiles_doctor_tool" >/dev/null 2>&1; then
            printf 'Optional tool %-10s available\n' "$dotfiles_doctor_tool"
        else
            printf 'Optional tool %-10s not found\n' "$dotfiles_doctor_tool"
        fi
    done
    if [ "$dotfiles_doctor_fail" -eq 0 ]; then
        dotfiles_info "doctor found no blocking problems"
    else
        dotfiles_die "doctor found blocking problems"
    fi
}
