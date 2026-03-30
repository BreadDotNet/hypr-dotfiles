#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_FILE="$HOME/.cache/e-ink-theme"

# Determine target mode
if [[ "${1:-}" == "dark" || "${1:-}" == "light" ]]; then
    MODE="$1"
elif [[ "${1:-}" == "toggle" || -z "${1:-}" ]]; then
    CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "dark")
    [[ "$CURRENT" == "dark" ]] && MODE="light" || MODE="dark"
else
    echo "Usage: switch.sh [dark|light|toggle]"
    exit 1
fi

# Generate configs
"$SCRIPT_DIR/generate.sh" "$MODE"

# Persist current mode
mkdir -p "$(dirname "$STATE_FILE")"
echo "$MODE" > "$STATE_FILE"

# Set GTK/system color-scheme (triggers prefers-color-scheme for Firefox etc.)
if [[ "$MODE" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
fi

# Reload running apps (best-effort)
hyprctl reload 2>/dev/null || true
pkill -SIGUSR2 waybar 2>/dev/null || true
pkill -SIGUSR1 nvim 2>/dev/null || true
tmux source-file ~/.tmux.conf 2>/dev/null || true
# Starship picks up toml changes on next prompt render
# Firefox extension picks up color-scheme change automatically

echo "Switched to $MODE mode."
