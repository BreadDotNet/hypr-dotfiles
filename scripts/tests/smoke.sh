#!/bin/sh

set -eu

SMOKE_DIR=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
SMOKE_ROOT=$(CDPATH= cd -P "$SMOKE_DIR/../.." && pwd)
SMOKE_TMP=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-smoke.XXXXXX") || exit 1
SMOKE_HOME="$SMOKE_TMP/home with spaces"
SMOKE_CONFLICT_HOME="$SMOKE_TMP/conflict home"

smoke_cleanup() {
    rm -rf "$SMOKE_TMP"
}

trap smoke_cleanup EXIT HUP INT TERM
mkdir -p "$SMOKE_HOME" "$SMOKE_CONFLICT_HOME/.config/dotfiles"

sh -n "$SMOKE_ROOT/bin/dotfiles"
find "$SMOKE_ROOT/scripts" -type f -name '*.sh' -exec sh -n {} \;

"$SMOKE_ROOT/bin/dotfiles" install --dry-run --target "$SMOKE_HOME"
"$SMOKE_ROOT/bin/dotfiles" install --target "$SMOKE_HOME"
"$SMOKE_ROOT/bin/dotfiles" install --target "$SMOKE_HOME"
"$SMOKE_ROOT/bin/dotfiles" restow --target "$SMOKE_HOME"
[ "$("$SMOKE_ROOT/bin/dotfiles" theme current --target "$SMOKE_HOME")" = terminal-basic ]
"$SMOKE_ROOT/bin/dotfiles" theme list --target "$SMOKE_HOME" |
    grep -q 'terminal-pro.*alias -> terminal-basic-dark'
if command -v zsh >/dev/null 2>&1; then
    HOME="$SMOKE_HOME" zsh -f -c '
        source "$HOME/.zshrc"
        [[ "$DOTFILES_REPO_ROOT" = '"'"$SMOKE_ROOT"'"' ]]
        [[ "$(theme current)" = terminal-basic ]]
    '
fi

SMOKE_BROKEN=$(find "$SMOKE_HOME" -type l ! -exec test -e {} \; -print)
[ -z "$SMOKE_BROKEN" ] || {
    printf '%s\n' "broken links in isolated HOME:" "$SMOKE_BROKEN" >&2
    exit 1
}

SMOKE_ARCHIVE=$(find "$SMOKE_HOME" -type l -lname '*archive/legacy*' -print)
[ -z "$SMOKE_ARCHIVE" ] || {
    printf '%s\n' "archive content was linked into isolated HOME:" "$SMOKE_ARCHIVE" >&2
    exit 1
}

if command -v nvim >/dev/null 2>&1; then
    env \
        HOME="$SMOKE_HOME" \
        XDG_CONFIG_HOME="$SMOKE_HOME/.config" \
        XDG_DATA_HOME="$SMOKE_HOME/.local/share" \
        XDG_STATE_HOME="$SMOKE_HOME/.local/state" \
        XDG_CACHE_HOME="$SMOKE_HOME/.cache" \
        DOTFILES_OFFLINE=1 \
        nvim --headless '+qa'
fi

git -C "$SMOKE_ROOT" status --porcelain=v1 > "$SMOKE_TMP/git-before"
"$SMOKE_ROOT/bin/dotfiles" theme apply terminal-basic --target "$SMOKE_HOME" --no-reload
find -L "$SMOKE_HOME/.config/dotfiles/theme" -type f -exec cksum {} \; |
    LC_ALL=C sort > "$SMOKE_TMP/theme-first.cksum"
"$SMOKE_ROOT/bin/dotfiles" theme apply terminal-basic --target "$SMOKE_HOME" --no-reload
find -L "$SMOKE_HOME/.config/dotfiles/theme" -type f -exec cksum {} \; |
    LC_ALL=C sort > "$SMOKE_TMP/theme-second.cksum"
diff -u "$SMOKE_TMP/theme-first.cksum" "$SMOKE_TMP/theme-second.cksum"

"$SMOKE_ROOT/bin/dotfiles" theme toggle --target "$SMOKE_HOME" --no-reload
[ "$("$SMOKE_ROOT/bin/dotfiles" theme current --target "$SMOKE_HOME")" = terminal-basic-dark ]
SMOKE_THEME_RUNTIME="$SMOKE_HOME/.config/dotfiles/theme"
grep -q "background[[:space:]]*#1E1E1E" "$SMOKE_THEME_RUNTIME/kitty.conf"
grep -qF 'color1  #D6492E' "$SMOKE_THEME_RUNTIME/kitty.conf"
grep -qF 'cursor_text_color       #FFFFFF' "$SMOKE_THEME_RUNTIME/kitty.conf"
grep -qF 'background = #1E1E1E' "$SMOKE_THEME_RUNTIME/ghostty.conf"
grep -qF 'cursor-text = #FFFFFF' "$SMOKE_THEME_RUNTIME/ghostty.conf"
grep -qF 'bg:#1E1E1E' "$SMOKE_THEME_RUNTIME/fzf.zsh"
grep -qF "name = 'terminal-basic-dark'" "$SMOKE_THEME_RUNTIME/nvim.lua"
grep -qF "bg = '#1E1E1E'" "$SMOKE_THEME_RUNTIME/nvim.lua"
grep -qF 'pane-active-border-style fg=#6A42F6' "$SMOKE_THEME_RUNTIME/tmux.conf"
grep -qF 'bg = "#1E1E1E"' "$SMOKE_THEME_RUNTIME/starship.toml"
grep -qF '@define-color bg #1E1E1E;' "$SMOKE_THEME_RUNTIME/waybar.css"
grep -qF '@define-color bg #1E1E1E;' "$SMOKE_THEME_RUNTIME/wofi.css"
grep -qF '$bg = rgb(1E1E1E)' "$SMOKE_THEME_RUNTIME/hyprland.conf"
grep -qF 'frame: "#1E1E1E"' \
    "$SMOKE_ROOT/themes/generated/firefox-terminal-macos/themes.js"
SMOKE_DARK_TARGET=$(readlink "$SMOKE_HOME/.config/dotfiles/theme")
"$SMOKE_ROOT/bin/dotfiles" theme apply terminal-pro --target "$SMOKE_HOME" --no-reload
[ "$("$SMOKE_ROOT/bin/dotfiles" theme current --target "$SMOKE_HOME")" = terminal-basic-dark ]
[ "$(readlink "$SMOKE_HOME/.config/dotfiles/theme")" = "$SMOKE_DARK_TARGET" ]
SMOKE_LIGHT_TARGET=$(find "$SMOKE_ROOT/themes/generated" -maxdepth 1 -type d \
    -name 'terminal-basic-*' ! -name 'terminal-basic-dark-*' -print | sed -n '1p')
if command -v nvim >/dev/null 2>&1; then
    env \
        HOME="$SMOKE_HOME" \
        DOTFILES_THEME_DARK="$SMOKE_DARK_TARGET" \
        DOTFILES_THEME_LIGHT="$SMOKE_LIGHT_TARGET" \
        nvim --clean --headless -u NONE \
        --cmd "set runtimepath+=$SMOKE_ROOT/packages/nvim/.config/nvim" \
        '+lua local t=require("dotfiles-theme"); t.load(); assert(vim.o.background=="dark"); local u=vim.uv or vim.loop; local r=vim.fn.expand("~/.config/dotfiles/theme"); assert(u.fs_unlink(r)); assert(u.fs_symlink(os.getenv("DOTFILES_THEME_LIGHT"),r)); t.reload_if_changed(); assert(vim.o.background=="light"); assert(u.fs_unlink(r)); assert(u.fs_symlink(os.getenv("DOTFILES_THEME_DARK"),r)); t.reload_if_changed(); assert(vim.o.background=="dark")' \
        +qa
fi
"$SMOKE_ROOT/bin/dotfiles" theme toggle --target "$SMOKE_HOME" --no-reload
[ "$("$SMOKE_ROOT/bin/dotfiles" theme current --target "$SMOKE_HOME")" = terminal-basic ]
git -C "$SMOKE_ROOT" status --porcelain=v1 > "$SMOKE_TMP/git-after"
if ! cmp -s "$SMOKE_TMP/git-before" "$SMOKE_TMP/git-after"; then
    printf '%s\n' 'theme switching changed repository status' >&2
    diff -u "$SMOKE_TMP/git-before" "$SMOKE_TMP/git-after" >&2 || true
    exit 1
fi

printf '%s\n' 'preserve me' > "$SMOKE_CONFLICT_HOME/.config/dotfiles/theme"
if "$SMOKE_ROOT/bin/dotfiles" theme apply terminal-basic \
    --target "$SMOKE_CONFLICT_HOME" --no-reload >/dev/null 2>&1; then
    printf '%s\n' 'ordinary runtime conflict was replaced unexpectedly' >&2
    exit 1
fi
[ "$(cat "$SMOKE_CONFLICT_HOME/.config/dotfiles/theme")" = 'preserve me' ]

# Invalid palette input must not replace the previously selected runtime link.
SMOKE_FIXTURE_ROOT="$SMOKE_TMP/repo fixture"
SMOKE_FIXTURE_HOME="$SMOKE_TMP/rollback home"
mkdir -p "$SMOKE_FIXTURE_ROOT" "$SMOKE_FIXTURE_HOME"
cp -R "$SMOKE_ROOT/bin" "$SMOKE_ROOT/scripts" "$SMOKE_ROOT/themes" "$SMOKE_FIXTURE_ROOT/"
"$SMOKE_FIXTURE_ROOT/bin/dotfiles" theme apply terminal-basic \
    --target "$SMOKE_FIXTURE_HOME" --no-reload >/dev/null
SMOKE_RUNTIME_BEFORE=$(readlink "$SMOKE_FIXTURE_HOME/.config/dotfiles/theme")
printf '%s\n' \
    "THEME_BASE='terminal-macos'" \
    "THEME_APPEARANCE='dark'" \
    "THEME_ALTERNATE='terminal-basic'" \
    "BACKGROUND='invalid'" \
    > "$SMOKE_FIXTURE_ROOT/themes/smoke-invalid.env"
if "$SMOKE_FIXTURE_ROOT/bin/dotfiles" theme apply smoke-invalid \
    --target "$SMOKE_FIXTURE_HOME" --no-reload >/dev/null 2>&1; then
    printf '%s\n' 'invalid theme unexpectedly passed validation' >&2
    exit 1
fi
SMOKE_RUNTIME_AFTER=$(readlink "$SMOKE_FIXTURE_HOME/.config/dotfiles/theme")
[ "$SMOKE_RUNTIME_BEFORE" = "$SMOKE_RUNTIME_AFTER" ] || {
    printf '%s\n' 'invalid theme changed the runtime selection' >&2
    exit 1
}

printf '%s\n' 'ID=fixture' 'PRETTY_NAME="Fixture Linux"' > "$SMOKE_TMP/os-release"
DOTFILES_UNAME_S=Darwin "$SMOKE_ROOT/bin/dotfiles" list >/dev/null
DOTFILES_UNAME_S=Darwin "$SMOKE_ROOT/bin/dotfiles" packages install --dry-run >/dev/null
DOTFILES_UNAME_S=Linux DOTFILES_OS_RELEASE="$SMOKE_TMP/os-release" \
    "$SMOKE_ROOT/bin/dotfiles" list >/dev/null
if DOTFILES_UNAME_S=Linux DOTFILES_OS_RELEASE="$SMOKE_TMP/os-release" \
    "$SMOKE_ROOT/bin/dotfiles" packages install --dry-run >/dev/null 2>&1; then
    printf '%s\n' 'unknown Linux unexpectedly selected a package manager' >&2
    exit 1
fi

"$SMOKE_ROOT/bin/dotfiles" uninstall --target "$SMOKE_HOME"

SMOKE_LEFT=$(find "$SMOKE_HOME" -type l -print)
[ -z "$SMOKE_LEFT" ] || {
    printf '%s\n' "managed links remain after uninstall:" "$SMOKE_LEFT" >&2
    exit 1
}

printf '%s\n' 'dotfiles smoke checks passed'
