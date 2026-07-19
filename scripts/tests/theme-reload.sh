#!/bin/sh

set -eu

TEST_DIR=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
TEST_ROOT=$(CDPATH= cd -P "$TEST_DIR/../.." && pwd)
TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-theme-reload.XXXXXX") || exit 1
TEST_BIN=$TEST_TMP/bin
TEST_HOME=$TEST_TMP/home
TEST_LOG=$TEST_TMP/calls.log
TEST_STATE=$TEST_TMP/state

test_cleanup() {
    rm -rf "$TEST_TMP"
}
trap test_cleanup EXIT HUP INT TERM
mkdir -p "$TEST_BIN" "$TEST_HOME/.config/hypr" "$TEST_STATE"
: > "$TEST_LOG"
printf '%s\n' '# isolated Hyprland fixture' > "$TEST_HOME/.config/hypr/hyprland.conf"

make_fixture_command() {
    fixture_name=$1
    fixture_body=$2
    {
        printf '%s\n' '#!/bin/sh' 'set -eu'
        printf '%s\n' "$fixture_body"
    } > "$TEST_BIN/$fixture_name"
    chmod +x "$TEST_BIN/$fixture_name"
}

make_fixture_command gsettings '
if [ "$1" = writable ]; then
    printf "%s\n" true
    exit 0
fi
printf "gsettings:%s\n" "$*" >> "$THEME_TEST_LOG"
[ "${THEME_TEST_FAIL_GSETTINGS:-0}" -eq 0 ]'
make_fixture_command osascript '
printf "osascript:%s\n" "$*" >> "$THEME_TEST_LOG"'
make_fixture_command pgrep 'exit 1'
make_fixture_command tmux 'exit 1'
make_fixture_command Hyprland 'exit 0'
make_fixture_command hyprctl '
case "$*" in
  "-j monitors all")
    if [ -f "$THEME_TEST_STATE/reloaded" ] && [ "${THEME_TEST_CHANGE_HYPR:-0}" -eq 1 ]; then
      printf "%s\n" '\''[{"name":"DP-1","width":1080,"height":1920,"refreshRate":60,"x":1,"y":0,"scale":1,"transform":1,"disabled":false,"mirrorOf":"none"}]'\''
    else
      printf "%s\n" '\''[{"name":"DP-1","width":1080,"height":1920,"refreshRate":60,"x":0,"y":0,"scale":1,"transform":1,"disabled":false,"mirrorOf":"none"}]'\''
    fi
    ;;
  "-j getoption input:kb_layout") printf "%s\n" '\''{"str":"us,ru"}'\'' ;;
  "-j getoption input:kb_options") printf "%s\n" '\''{"str":"grp:win_space_toggle"}'\'' ;;
  "-j devices") printf "%s\n" '\''{"keyboards":[{"name":"fixture","layout":"us,ru","variant":"","options":"grp:win_space_toggle","active_keymap":"English (US)","main":true}]}'\'' ;;
  "reload config-only") : > "$THEME_TEST_STATE/reloaded" ;;
  configerrors) : ;;
  *) exit 1 ;;
esac'

PATH="$TEST_BIN:/usr/bin:/bin"
HOME=$TEST_HOME
DOTFILES_ROOT=$TEST_ROOT
DOTFILES_TARGET=$TEST_HOME
DOTFILES_TEMP_DIR=$TEST_TMP
THEME_TEST_LOG=$TEST_LOG
THEME_TEST_STATE=$TEST_STATE
export PATH HOME DOTFILES_ROOT DOTFILES_TARGET DOTFILES_TEMP_DIR THEME_TEST_LOG THEME_TEST_STATE
unset HYPRLAND_INSTANCE_SIGNATURE

# shellcheck source=../lib/core.sh
. "$TEST_ROOT/scripts/lib/core.sh"
# shellcheck source=../lib/platform.sh
. "$TEST_ROOT/scripts/lib/platform.sh"
# shellcheck source=../lib/packages.sh
. "$TEST_ROOT/scripts/lib/packages.sh"
# shellcheck source=../lib/theme-reload.sh
. "$TEST_ROOT/scripts/lib/theme-reload.sh"

printf '%s\n' 'ID=fixture' 'PRETTY_NAME="Fixture Linux"' > "$TEST_TMP/os-release"
DOTFILES_UNAME_S=Linux
DOTFILES_OS_RELEASE=$TEST_TMP/os-release
export DOTFILES_UNAME_S DOTFILES_OS_RELEASE
theme_reload_all dark >/dev/null
grep -q '^gsettings:set org.gnome.desktop.interface color-scheme prefer-dark$' "$TEST_LOG"

DOTFILES_UNAME_S=Darwin
unset DOTFILES_OS_RELEASE
export DOTFILES_UNAME_S
theme_reload_all light >/dev/null
grep -q '^osascript:' "$TEST_LOG"
grep -q 'dark mode to false' "$TEST_LOG"

DOTFILES_UNAME_S=Linux
DOTFILES_OS_RELEASE=$TEST_TMP/os-release
THEME_TEST_FAIL_GSETTINGS=1
export DOTFILES_UNAME_S DOTFILES_OS_RELEASE THEME_TEST_FAIL_GSETTINGS
if theme_reload_all dark >/dev/null; then
    printf '%s\n' 'failed system appearance update was not reported' >&2
    exit 1
fi

unset THEME_TEST_FAIL_GSETTINGS
HYPRLAND_INSTANCE_SIGNATURE=fixture
export HYPRLAND_INSTANCE_SIGNATURE
rm -f "$TEST_STATE/reloaded"
theme_reload_preflight
theme_reload_all light >/dev/null

if command -v jq >/dev/null 2>&1; then
    THEME_TEST_CHANGE_HYPR=1
    export THEME_TEST_CHANGE_HYPR
    rm -f "$TEST_STATE/reloaded"
    if theme_reload_all light >/dev/null; then
        printf '%s\n' 'changed Hyprland monitor state was not reported' >&2
        exit 1
    fi
fi

printf '%s\n' 'dotfiles theme reload fixture checks passed'
