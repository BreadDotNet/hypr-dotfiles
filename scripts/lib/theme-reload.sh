#!/bin/sh
# Live theme reload helpers. Call only for an explicit theme apply/toggle in the
# real HOME; installation and isolated targets must set DOTFILES_RELOAD=0.

theme_reload_status() {
    theme_reload_label=$1
    theme_reload_state=$2
    theme_reload_detail=$3
    printf '  %-18s %-8s %s\n' "$theme_reload_label" "$theme_reload_state" "$theme_reload_detail"
}

theme_hyprland_is_running() {
    [ "${DOTFILES_PLATFORM-}" = linux ] || return 1
    command -v hyprctl >/dev/null 2>&1 || return 1
    [ -n "${HYPRLAND_INSTANCE_SIGNATURE-}" ] || return 1
}

theme_reload_preflight() {
    dotfiles_detect_platform
    theme_hyprland_is_running || return 0
    command -v Hyprland >/dev/null 2>&1 || {
        theme_error 'Hyprland is running, but the Hyprland verifier is unavailable'
        return 1
    }
    theme_hypr_config=${DOTFILES_TARGET:-${HOME:?HOME is not set}}/.config/hypr/hyprland.conf
    [ -r "$theme_hypr_config" ] || {
        theme_error "Hyprland is running, but its config is unavailable: $theme_hypr_config"
        return 1
    }
    if ! Hyprland --verify-config --config "$theme_hypr_config" >/dev/null; then
        theme_error 'Hyprland rejected the configuration with the candidate theme'
        return 1
    fi
}

theme_reload_signal() {
    theme_signal_label=$1
    theme_signal_process=$2
    theme_signal_name=$3
    if ! command -v pgrep >/dev/null 2>&1; then
        theme_reload_status "$theme_signal_label" skipped 'pgrep is unavailable'
        return 0
    fi
    theme_signal_pids=$(pgrep -x "$theme_signal_process" 2>/dev/null || true)
    if [ -z "$theme_signal_pids" ]; then
        theme_reload_status "$theme_signal_label" skipped 'not running'
        return 0
    fi
    theme_signal_failed=0
    for theme_signal_pid in $theme_signal_pids; do
        if ! kill -"$theme_signal_name" "$theme_signal_pid" 2>/dev/null; then
            theme_signal_failed=1
        fi
    done
    if [ "$theme_signal_failed" -eq 0 ]; then
        theme_reload_status "$theme_signal_label" reloaded "signal $theme_signal_name"
        return 0
    fi
    theme_reload_status "$theme_signal_label" failed "could not signal every $theme_signal_process process"
    return 1
}

theme_reload_tmux() {
    if ! command -v tmux >/dev/null 2>&1; then
        theme_reload_status tmux skipped 'not installed'
        return 0
    fi
    if ! tmux list-sessions >/dev/null 2>&1; then
        theme_reload_status tmux skipped 'no server is running'
        return 0
    fi
    theme_tmux_config=${DOTFILES_TARGET:-${HOME:?HOME is not set}}/.tmux.conf
    if [ ! -r "$theme_tmux_config" ]; then
        theme_reload_status tmux failed "config is unavailable: $theme_tmux_config"
        return 1
    fi
    if tmux source-file "$theme_tmux_config" >/dev/null 2>&1; then
        theme_reload_status tmux reloaded 'source-file'
        return 0
    fi
    theme_reload_status tmux failed 'source-file returned an error'
    return 1
}

theme_hypr_snapshot() {
    command -v jq >/dev/null 2>&1 || return 3
    theme_snapshot_monitors=$(hyprctl -j monitors all 2>/dev/null | jq -cS \
        '[.[] | {name,width,height,refreshRate,x,y,scale,transform,disabled,mirrorOf}] | sort_by(.name)') || return 1
    theme_snapshot_layout=$(hyprctl -j getoption input:kb_layout 2>/dev/null | jq -r '.str // ""') || return 1
    theme_snapshot_options=$(hyprctl -j getoption input:kb_options 2>/dev/null | jq -r '.str // ""') || return 1
    theme_snapshot_keyboards=$(hyprctl -j devices 2>/dev/null | jq -cS \
        '[(.keyboards // [])[] | {name,layout,variant,options,active_keymap,main}] | sort_by(.name)') || return 1
    printf '%s\n%s\n%s\n%s\n' \
        "$theme_snapshot_monitors" "$theme_snapshot_layout" \
        "$theme_snapshot_options" "$theme_snapshot_keyboards"
}

theme_reload_hyprland() {
    theme_hyprland_is_running || {
        theme_reload_status Hyprland skipped 'not running'
        return 0
    }

    theme_hypr_before=
    theme_hypr_snapshot_available=1
    if theme_hypr_before=$(theme_hypr_snapshot); then
        :
    else
        theme_hypr_snapshot_rc=$?
        [ "$theme_hypr_snapshot_rc" -ne 3 ] || theme_hypr_snapshot_available=0
        [ "$theme_hypr_snapshot_rc" -eq 3 ] || {
            theme_reload_status Hyprland failed 'could not snapshot monitor/input state'
            return 1
        }
    fi

    if ! hyprctl reload config-only >/dev/null 2>&1; then
        theme_reload_status Hyprland failed 'config-only reload failed'
        return 1
    fi
    theme_hypr_errors=$(hyprctl configerrors 2>/dev/null || true)
    if [ -n "$theme_hypr_errors" ]; then
        theme_reload_status Hyprland failed "config errors: $theme_hypr_errors"
        return 1
    fi
    if [ "$theme_hypr_snapshot_available" -eq 1 ]; then
        if ! theme_hypr_after=$(theme_hypr_snapshot); then
            theme_reload_status Hyprland failed 'could not verify monitor/input state after reload'
            return 1
        fi
        if [ "$theme_hypr_before" != "$theme_hypr_after" ]; then
            theme_reload_status Hyprland failed 'monitor or keyboard state changed unexpectedly'
            return 1
        fi
        theme_reload_status Hyprland reloaded 'config-only; monitor and keyboard state unchanged'
    else
        theme_reload_status Hyprland reloaded 'config-only; configerrors empty (jq state check skipped)'
    fi
}

theme_reload_system() {
    theme_system_mode=$1
    dotfiles_source_platform_adapter
    if platform_theme_sync_appearance "$theme_system_mode"; then
        theme_reload_status 'System appearance' updated "$theme_system_mode"
        return 0
    else
        theme_system_rc=$?
    fi
    if [ "$theme_system_rc" -eq 3 ]; then
        theme_reload_status 'System appearance' skipped 'no supported appearance API is available'
        return 0
    fi
    theme_reload_status 'System appearance' failed "could not select $theme_system_mode"
    return 1
}

theme_reload_all() {
    theme_reload_mode=$1
    dotfiles_detect_platform
    printf '%s\n' 'Live reload summary:'
    theme_reload_failed=0
    theme_reload_system "$theme_reload_mode" || theme_reload_failed=1
    theme_reload_hyprland || theme_reload_failed=1
    theme_reload_signal Kitty kitty USR1 || theme_reload_failed=1
    theme_reload_signal Waybar waybar USR2 || theme_reload_failed=1
    theme_reload_tmux || theme_reload_failed=1
    theme_reload_status Neovim automatic 'updates on focus/idle'
    theme_reload_status Zsh automatic 'caller now; other shells on next prompt'
    theme_reload_status 'fzf/Starship' automatic 'updated environment/next prompt'
    theme_reload_status 'Ghostty/Wofi/Hyprlock' deferred 'next launch'
    [ "$theme_reload_failed" -eq 0 ]
}
