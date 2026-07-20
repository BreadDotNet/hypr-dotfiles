#!/bin/sh
# Theme generation library. Public API: theme_list, theme_current,
# theme_apply THEME, theme_toggle.

theme_error() {
    printf 'dotfiles theme: %s\n' "$*" >&2
}

theme_color_names='ANSI_0 ANSI_1 ANSI_2 ANSI_3 ANSI_4 ANSI_5 ANSI_6 ANSI_7 ANSI_8 ANSI_9 ANSI_10 ANSI_11 ANSI_12 ANSI_13 ANSI_14 ANSI_15 BACKGROUND FOREGROUND CURSOR SELECTION COLOR_ERROR COLOR_SUCCESS COLOR_WARNING COLOR_INFO COLOR_ACCENT COLOR_MUTED COLOR_DIRECTORY COLOR_LINK COLOR_STRING COLOR_COMMENT COLOR_ADDED COLOR_MODIFIED COLOR_DELETED COLOR_PRIMARY COLOR_EMPHASIZED COLOR_SURFACE COLOR_OVERLAY COLOR_CURSOR_TEXT COLOR_ACTIVE_BG COLOR_ACTIVE_FG COLOR_ON_ACCENT'

theme_validate_color_file() {
    theme_validate_file=$1
    awk -v allowed="$theme_color_names" '
        BEGIN {
            count = split(allowed, names, " ")
            for (i = 1; i <= count; i++) ok[names[i]] = 1
        }
        /^[[:space:]]*$/ || /^[[:space:]]*#/ { next }
        {
            name = $0
            sub(/=.*/, "", name)
            if (!ok[name]) {
                print FILENAME ":" FNR ": variable is not allowed: " name > "/dev/stderr"
                bad = 1
                next
            }
        }
        /^[A-Z][A-Z0-9_]*='"'"'#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]'"'"'$/ { next }
        /^[A-Z][A-Z0-9_]*="\$\{[A-Z][A-Z0-9_]*\}"$/ { next }
        { print FILENAME ":" FNR ": unsafe or invalid color assignment" > "/dev/stderr"; bad = 1 }
        END { exit bad }
    ' "$theme_validate_file"
}

theme_validate_variant_file() {
    theme_validate_file=$1
    awk -v allowed="$theme_color_names THEME_BASE THEME_APPEARANCE THEME_ALTERNATE" '
        BEGIN {
            count = split(allowed, names, " ")
            for (i = 1; i <= count; i++) ok[names[i]] = 1
        }
        /^[[:space:]]*$/ || /^[[:space:]]*#/ { next }
        {
            name = $0
            sub(/=.*/, "", name)
            if (!ok[name]) {
                print FILENAME ":" FNR ": variable is not allowed: " name > "/dev/stderr"
                bad = 1
                next
            }
        }
        /^THEME_BASE='"'"'[A-Za-z0-9][A-Za-z0-9._-]*'"'"'$/ { next }
        /^THEME_APPEARANCE='"'"'(light|dark)'"'"'$/ { next }
        /^THEME_ALTERNATE='"'"'[A-Za-z0-9][A-Za-z0-9._-]*'"'"'$/ { next }
        /^[A-Z][A-Z0-9_]*='"'"'#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]'"'"'$/ { next }
        /^[A-Z][A-Z0-9_]*="\$\{[A-Z][A-Z0-9_]*\}"$/ { next }
        { print FILENAME ":" FNR ": unsafe or invalid theme assignment" > "/dev/stderr"; bad = 1 }
        END { exit bad }
    ' "$theme_validate_file"
}

theme_read_literal() {
    theme_read_file=$1
    theme_read_name=$2
    awk -F "'" -v wanted="$theme_read_name" '$1 == wanted "=" { print $2; exit }' "$theme_read_file"
}

theme_validate_name_value() {
    case $1 in
        ''|[!A-Za-z0-9]*|*[!A-Za-z0-9._-]*) return 1 ;;
        *) return 0 ;;
    esac
}

theme_canonical_name() {
    case $1 in
        terminal-pro) printf '%s\n' 'terminal-basic-dark' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

theme_load_palette() {
    theme_load_name=$1
    theme_load_overrides=${2:-1}
    THEME_HAS_OVERRIDES=0
    theme_source=$DOTFILES_ROOT/themes/$theme_load_name.env
    [ -f "$theme_source" ] || { theme_error "theme not found: $theme_load_name"; return 1; }
    theme_validate_variant_file "$theme_source"

    THEME_BASE=$(theme_read_literal "$theme_source" THEME_BASE)
    THEME_APPEARANCE=$(theme_read_literal "$theme_source" THEME_APPEARANCE)
    THEME_ALTERNATE=$(theme_read_literal "$theme_source" THEME_ALTERNATE)
    theme_validate_name_value "$THEME_BASE" || { theme_error 'invalid or missing THEME_BASE'; return 1; }
    theme_validate_name_value "$THEME_ALTERNATE" || { theme_error 'invalid or missing THEME_ALTERNATE'; return 1; }
    case $THEME_APPEARANCE in light|dark) ;; *) theme_error 'THEME_APPEARANCE must be light or dark'; return 1 ;; esac

    theme_base_source=$DOTFILES_ROOT/themes/palettes/$THEME_BASE.env
    [ -f "$theme_base_source" ] || { theme_error "base palette not found: $THEME_BASE"; return 1; }
    theme_validate_color_file "$theme_base_source"
    # shellcheck disable=SC1090
    . "$theme_base_source"
    # shellcheck disable=SC1090
    . "$theme_source"

    if [ "$theme_load_overrides" -eq 1 ] && [ -n "${DOTFILES_HOST-}" ]; then
        theme_host_override=$DOTFILES_ROOT/hosts/$DOTFILES_HOST/theme.env
        if [ -f "$theme_host_override" ]; then
            THEME_HAS_OVERRIDES=1
            theme_validate_color_file "$theme_host_override"
            # shellcheck disable=SC1090
            . "$theme_host_override"
        fi
    fi
    theme_local_override=$DOTFILES_ROOT/themes/local.env
    if [ "$theme_load_overrides" -eq 1 ] && [ -f "$theme_local_override" ]; then
        THEME_HAS_OVERRIDES=1
        theme_validate_color_file "$theme_local_override"
        # shellcheck disable=SC1090
        . "$theme_local_override"
    fi
    theme_validate_palette
}

theme_is_hex() {
    case $1 in
        \#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]) return 0 ;;
        *) return 1 ;;
    esac
}

theme_validate_palette() {
    for theme_palette_var in \
        ANSI_0 ANSI_1 ANSI_2 ANSI_3 ANSI_4 ANSI_5 ANSI_6 ANSI_7 \
        ANSI_8 ANSI_9 ANSI_10 ANSI_11 ANSI_12 ANSI_13 ANSI_14 ANSI_15 \
        BACKGROUND FOREGROUND CURSOR SELECTION \
        COLOR_ERROR COLOR_SUCCESS COLOR_WARNING COLOR_INFO COLOR_ACCENT \
        COLOR_MUTED COLOR_DIRECTORY COLOR_LINK COLOR_STRING COLOR_COMMENT \
        COLOR_ADDED COLOR_MODIFIED COLOR_DELETED COLOR_PRIMARY COLOR_EMPHASIZED \
        COLOR_SURFACE COLOR_OVERLAY COLOR_CURSOR_TEXT COLOR_ACTIVE_BG \
        COLOR_ACTIVE_FG COLOR_ON_ACCENT
    do
        eval "theme_palette_value=\${$theme_palette_var-}"
        if ! theme_is_hex "$theme_palette_value"; then
            theme_error "$theme_palette_var must be a quoted #RRGGBB value or resolve to one"
            return 1
        fi
    done
}

theme_without_hash() {
    printf '%s' "${1#\#}"
}

theme_generate_kitty() {
    theme_out=$1
    cat >"$theme_out/kitty.conf" <<EOF
# Generated from themes/$theme_name.env. Do not edit.
foreground              $FOREGROUND
background              $BACKGROUND
selection_foreground    $FOREGROUND
selection_background    $SELECTION
cursor                  $CURSOR
cursor_text_color       $COLOR_CURSOR_TEXT
url_color               $COLOR_LINK
active_border_color     $COLOR_ACCENT
inactive_border_color   $COLOR_MUTED
bell_border_color       $COLOR_WARNING
wayland_titlebar_color system
macos_titlebar_color system
active_tab_foreground   $COLOR_ACTIVE_FG
active_tab_background   $COLOR_ACTIVE_BG
inactive_tab_foreground $COLOR_MUTED
inactive_tab_background $COLOR_SURFACE
tab_bar_background      $BACKGROUND
color0  $ANSI_0
color1  $ANSI_1
color2  $ANSI_2
color3  $ANSI_3
color4  $ANSI_4
color5  $ANSI_5
color6  $ANSI_6
color7  $ANSI_7
color8  $ANSI_8
color9  $ANSI_9
color10 $ANSI_10
color11 $ANSI_11
color12 $ANSI_12
color13 $ANSI_13
color14 $ANSI_14
color15 $ANSI_15
EOF
}

theme_generate_ghostty() {
    theme_out=$1
    cat >"$theme_out/ghostty.conf" <<EOF
# Generated from themes/$theme_name.env. Do not edit.
background = $BACKGROUND
foreground = $FOREGROUND
selection-foreground = $FOREGROUND
selection-background = $SELECTION
cursor-color = $CURSOR
cursor-text = $COLOR_CURSOR_TEXT
palette = 0=$ANSI_0
palette = 1=$ANSI_1
palette = 2=$ANSI_2
palette = 3=$ANSI_3
palette = 4=$ANSI_4
palette = 5=$ANSI_5
palette = 6=$ANSI_6
palette = 7=$ANSI_7
palette = 8=$ANSI_8
palette = 9=$ANSI_9
palette = 10=$ANSI_10
palette = 11=$ANSI_11
palette = 12=$ANSI_12
palette = 13=$ANSI_13
palette = 14=$ANSI_14
palette = 15=$ANSI_15
EOF
}

theme_generate_shell() {
    theme_out=$1
    cat >"$theme_out/zsh-theme.zsh" <<EOF
# Generated from themes/$theme_name.env. Do not edit.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=$COLOR_COMMENT'
ZSH_HIGHLIGHT_STYLES[alias]='fg=$COLOR_EMPHASIZED'
ZSH_HIGHLIGHT_STYLES[function]='fg=$COLOR_EMPHASIZED'
ZSH_HIGHLIGHT_STYLES[command]='fg=$COLOR_PRIMARY'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=$COLOR_PRIMARY'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=$COLOR_PRIMARY'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=$COLOR_ACCENT'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=$COLOR_MUTED'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=$COLOR_MUTED'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=$COLOR_INFO'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=$COLOR_STRING'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=$COLOR_STRING'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=$COLOR_ERROR'
ZSH_HIGHLIGHT_STYLES[path]='fg=$COLOR_DIRECTORY,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=$COLOR_DIRECTORY,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=$COLOR_ACCENT'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=$COLOR_WARNING'
ZSH_HIGHLIGHT_STYLES[default]='fg=$COLOR_PRIMARY'
ZSH_HIGHLIGHT_STYLES[cursor]='fg=$CURSOR'
EOF
    cat >"$theme_out/fzf.zsh" <<EOF
# Generated from themes/$theme_name.env. Do not edit.
if (( ! \${+DOTFILES_FZF_BASE_OPTS} )); then
  typeset -g DOTFILES_FZF_BASE_OPTS="\${FZF_DEFAULT_OPTS-}"
fi
export FZF_DEFAULT_OPTS="\${DOTFILES_FZF_BASE_OPTS:+\$DOTFILES_FZF_BASE_OPTS }--color=fg:$FOREGROUND,bg:$BACKGROUND,hl:$COLOR_ACCENT,fg+:$COLOR_PRIMARY,bg+:$SELECTION,hl+:$COLOR_LINK,info:$COLOR_INFO,prompt:$COLOR_ACCENT,pointer:$COLOR_ERROR,marker:$COLOR_SUCCESS,spinner:$COLOR_WARNING,header:$COLOR_MUTED,border:$COLOR_MUTED"
EOF
}

theme_generate_tmux() {
    theme_out=$1
    cat >"$theme_out/tmux.conf" <<EOF
# Generated from themes/$theme_name.env. Do not edit.
set -g pane-border-style fg=$COLOR_MUTED
set -g pane-active-border-style fg=$COLOR_ACCENT
set -g status-style bg=default,fg=$COLOR_PRIMARY
set -g status-left ""
set -g status-right "#[fg=$COLOR_MUTED]#S"
set -g window-status-format "#[fg=$COLOR_MUTED] #I #W "
set -g window-status-current-format "#[fg=$COLOR_ACCENT,bold] #I #W "
set -g window-status-separator ""
set -g message-style bg=$BACKGROUND,fg=$COLOR_EMPHASIZED
set -g message-command-style bg=$BACKGROUND,fg=$COLOR_EMPHASIZED
set -g mode-style bg=$SELECTION,fg=$FOREGROUND
EOF
}

theme_generate_hyprland() {
    theme_out=$1
    theme_bg=$(theme_without_hash "$BACKGROUND")
    theme_fg=$(theme_without_hash "$FOREGROUND")
    theme_surface=$(theme_without_hash "$COLOR_SURFACE")
    theme_overlay=$(theme_without_hash "$COLOR_OVERLAY")
    theme_muted=$(theme_without_hash "$COLOR_MUTED")
    theme_accent=$(theme_without_hash "$COLOR_ACCENT")
    theme_error_color=$(theme_without_hash "$COLOR_ERROR")
    theme_success=$(theme_without_hash "$COLOR_SUCCESS")
    theme_warning=$(theme_without_hash "$COLOR_WARNING")
    cat >"$theme_out/hyprland.conf" <<EOF
# Generated from themes/$theme_name.env. Do not edit.
\$bg = rgb($theme_bg)
\$bgAlpha = $theme_bg
\$surface = rgb($theme_surface)
\$surfaceAlpha = $theme_surface
\$overlay = rgb($theme_overlay)
\$overlayAlpha = $theme_overlay
\$fg = rgb($theme_fg)
\$fgAlpha = $theme_fg
\$muted = rgb($theme_muted)
\$mutedAlpha = $theme_muted
\$accent = rgb($theme_accent)
\$accentAlpha = $theme_accent
\$error = rgb($theme_error_color)
\$errorAlpha = $theme_error_color
\$ok = rgb($theme_success)
\$okAlpha = $theme_success
\$warning = rgb($theme_warning)
\$warningAlpha = $theme_warning
EOF
}

theme_generate_css() {
    theme_out=$1
    cat >"$theme_out/waybar.css" <<EOF
/* Generated from themes/$theme_name.env. Do not edit. */
@define-color bg $BACKGROUND;
@define-color surface $COLOR_SURFACE;
@define-color overlay $COLOR_OVERLAY;
@define-color fg $COLOR_PRIMARY;
@define-color secondary $COLOR_MUTED;
@define-color strong $COLOR_EMPHASIZED;
@define-color intense $FOREGROUND;
@define-color error $COLOR_ERROR;
@define-color red $COLOR_ERROR;
@define-color yellow $COLOR_WARNING;
@define-color ok $COLOR_SUCCESS;
@define-color info $COLOR_INFO;
@define-color search $COLOR_STRING;
EOF
    cp "$theme_out/waybar.css" "$theme_out/wofi.css"
}

theme_generate_nvim() {
    theme_out=$1
    cat >"$theme_out/nvim.lua" <<EOF
-- Generated from themes/$theme_name.env. Do not edit.
return {
  name = '$theme_name',
  appearance = '$THEME_APPEARANCE',
  mono = {
    bg = '$BACKGROUND', surface = '$COLOR_SURFACE', overlay = '$COLOR_OVERLAY',
    faint = '$COLOR_OVERLAY', dim = '$COLOR_MUTED', muted = '$COLOR_MUTED',
    subtle = '$COLOR_MUTED', border = '$COLOR_OVERLAY', secondary = '$COLOR_MUTED',
    tertiary = '$COLOR_MUTED', fg = '$COLOR_PRIMARY', emphasis = '$COLOR_EMPHASIZED',
    strong = '$COLOR_EMPHASIZED', bright = '$FOREGROUND', intense = '$FOREGROUND',
  },
  accent = {
    error = '$COLOR_ERROR', warning = '$COLOR_WARNING', ok = '$COLOR_SUCCESS',
    info = '$COLOR_INFO', hint = '$COLOR_ACCENT', search = '$COLOR_STRING',
    add = '$COLOR_ADDED', change = '$COLOR_MODIFIED', remove = '$COLOR_DELETED',
    diff_add = '$SELECTION', diff_change = '$SELECTION', diff_remove = '$SELECTION',
  },
  raw = {
    red = '$ANSI_1', yellow = '$ANSI_3', green = '$ANSI_2', blue = '$ANSI_4',
    aqua = '$ANSI_6', purple = '$ANSI_5', orange = '$COLOR_WARNING',
    cactus = '$COLOR_SUCCESS', grass = '$COLOR_SUCCESS', fruit = '$COLOR_STRING',
    brick = '$COLOR_DELETED', brown = '$COLOR_WARNING', cyan = '$COLOR_INFO',
    bg_red = '$SELECTION', bg_green = '$SELECTION', bg_blue = '$SELECTION',
  },
  terminal = {
    '$ANSI_0', '$ANSI_1', '$ANSI_2', '$ANSI_3', '$ANSI_4', '$ANSI_5', '$ANSI_6', '$ANSI_7',
    '$ANSI_8', '$ANSI_9', '$ANSI_10', '$ANSI_11', '$ANSI_12', '$ANSI_13', '$ANSI_14', '$ANSI_15',
  },
}
EOF
}

theme_generate_starship() {
    theme_out=$1
    cat >"$theme_out/starship.toml" <<EOF
# Generated from themes/$theme_name.env. Do not edit.
"\$schema" = 'https://starship.rs/config-schema.json'
format = """
[](surface)\
\$os\
\$username\
[](bg:dim fg:surface)\
\$directory\
[](fg:dim bg:border)\
\$git_branch\
\$git_status\
[](fg:border bg:fg)\
\$c\$rust\$golang\$nodejs\$php\$java\$kotlin\$haskell\$python\
[](fg:fg bg:strong)\
\$docker_context\
[](fg:strong bg:intense)\
\$time\
[ ](fg:intense)\
\$line_break\$character"""
palette = 'terminal_basic'
add_newline = false

[palettes.terminal_basic]
surface = "$COLOR_SURFACE"
dim = "$COLOR_MUTED"
border = "$COLOR_OVERLAY"
fg = "$COLOR_PRIMARY"
strong = "$COLOR_EMPHASIZED"
intense = "$FOREGROUND"
bg = "$BACKGROUND"
error = "$COLOR_ERROR"
warning = "$COLOR_WARNING"
ok = "$COLOR_SUCCESS"
hint = "$COLOR_ACCENT"
search = "$COLOR_STRING"
purple = "$COLOR_STRING"
EOF
    cat "$DOTFILES_ROOT/themes/templates/starship-sections.toml" >>"$theme_out/starship.toml"
}

theme_emit_firefox_variant() (
    set -eu
    theme_name=$1
    theme_key=$2
    theme_trailing=$3
    theme_load_palette "$theme_name" 0
    cat <<EOF
  $theme_key: { colors: {
    frame: "$BACKGROUND", frame_inactive: "$BACKGROUND",
    tab_background_text: "$COLOR_MUTED", tab_text: "$FOREGROUND",
    tab_selected: "$COLOR_SURFACE", tab_line: "$COLOR_ACCENT", tab_loading: "$COLOR_INFO",
    toolbar: "$COLOR_SURFACE", toolbar_text: "$COLOR_PRIMARY", bookmark_text: "$COLOR_PRIMARY",
    icons: "$COLOR_ACCENT", icons_attention: "$COLOR_ERROR",
    toolbar_field: "$BACKGROUND", toolbar_field_text: "$FOREGROUND",
    toolbar_field_border: "$COLOR_ACCENT", toolbar_field_focus: "$COLOR_SURFACE",
    toolbar_field_highlight: "$SELECTION", toolbar_field_highlight_text: "$FOREGROUND",
    toolbar_top_separator: "transparent", toolbar_bottom_separator: "$COLOR_ACCENT",
    button_background_hover: "$SELECTION", button_background_active: "$COLOR_ACCENT",
    popup: "$COLOR_SURFACE", popup_text: "$COLOR_PRIMARY", popup_highlight: "$COLOR_ACCENT",
    popup_highlight_text: "$COLOR_ON_ACCENT", popup_border: "$COLOR_ACCENT",
    sidebar: "$BACKGROUND", sidebar_text: "$COLOR_PRIMARY", sidebar_border: "$COLOR_ACCENT",
    sidebar_highlight: "$SELECTION", sidebar_highlight_text: "$FOREGROUND",
    ntp_background: "$BACKGROUND", ntp_text: "$COLOR_PRIMARY", ntp_card_background: "$COLOR_SURFACE"
  }}$theme_trailing
EOF
)

theme_generate_firefox_bundle() {
    theme_firefox_out=$1
    mkdir -p "$theme_firefox_out"
    {
        printf '%s\n' '// Generated from terminal-basic.env and terminal-basic-dark.env. Do not edit.'
        printf '%s\n' 'const THEMES = {'
        theme_emit_firefox_variant terminal-basic light ,
        theme_emit_firefox_variant terminal-basic-dark dark ''
        printf '%s\n' '};'
    } >"$theme_firefox_out/themes.js"

    if command -v node >/dev/null 2>&1; then
        node --check "$theme_firefox_out/themes.js" >/dev/null
        node --check "$DOTFILES_ROOT/themes/templates/firefox-extension/background.js" >/dev/null
    fi
    if command -v jq >/dev/null 2>&1; then
        jq -e . "$DOTFILES_ROOT/themes/templates/firefox-extension/manifest.json" >/dev/null
    elif command -v node >/dev/null 2>&1; then
        node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' \
            "$DOTFILES_ROOT/themes/templates/firefox-extension/manifest.json"
    fi
}

theme_generate_metadata() {
    theme_out=$1
    cat >"$theme_out/metadata.env" <<EOF
THEME_NAME='$theme_name'
THEME_APPEARANCE='$THEME_APPEARANCE'
THEME_ALTERNATE='$THEME_ALTERNATE'
EOF
}

theme_validate_output() {
    theme_output=$1
    theme_expected='metadata.env kitty.conf ghostty.conf zsh-theme.zsh fzf.zsh tmux.conf hyprland.conf waybar.css wofi.css nvim.lua starship.toml'
    for theme_relative in $theme_expected; do
        if [ ! -s "$theme_output/$theme_relative" ]; then
            theme_error "generated output is missing $theme_relative"
            return 1
        fi
        if grep '@@' "$theme_output/$theme_relative" >/dev/null 2>&1; then
            theme_error "unresolved placeholder in $theme_relative"
            return 1
        fi
    done
    if command -v zsh >/dev/null 2>&1; then
        zsh -n "$theme_output/zsh-theme.zsh"
        zsh -n "$theme_output/fzf.zsh"
    fi
    if command -v nvim >/dev/null 2>&1; then
        DOTFILES_THEME_NVIM_CHECK="$theme_output/nvim.lua" \
            nvim --clean --headless -u NONE \
            '+lua assert(loadfile(os.getenv("DOTFILES_THEME_NVIM_CHECK")))' +qa >/dev/null
    fi
    if command -v starship >/dev/null 2>&1; then
        STARSHIP_CONFIG="$theme_output/starship.toml" starship prompt >/dev/null
    fi
    if command -v tmux >/dev/null 2>&1; then
        theme_tmux_tmp=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-theme-tmux.XXXXXX") || {
            theme_error 'could not create an isolated tmux validation directory'
            return 1
        }
        theme_tmux_error=$theme_tmux_tmp/error.log
        if TMUX_TMPDIR="$theme_tmux_tmp" tmux -L "dotfiles-theme-$$" \
            -f "$theme_output/tmux.conf" new-session -d 2>"$theme_tmux_error"; then
            TMUX_TMPDIR="$theme_tmux_tmp" tmux -L "dotfiles-theme-$$" kill-server 2>/dev/null || true
            rm -rf "$theme_tmux_tmp"
        elif grep -Eiq 'operation not permitted|permission denied|could not create|failed to connect|no server running' \
            "$theme_tmux_error"; then
            theme_error 'warning: tmux runtime validation is unavailable in this environment'
            rm -rf "$theme_tmux_tmp"
        else
            cat "$theme_tmux_error" >&2
            rm -rf "$theme_tmux_tmp"
            theme_error 'generated tmux configuration failed validation'
            return 1
        fi
    fi
}

theme_print_integrations() {
    printf '%s\n' 'kitty' 'ghostty (optional)' 'zsh syntax highlighting' 'fzf' \
        'Neovim' 'tmux' 'Starship' 'Hyprland/Hyprlock' 'Waybar' 'Wofi'
}

theme_default_name() {
    theme_default_file=$DOTFILES_ROOT/themes/default
    [ -f "$theme_default_file" ] || { theme_error 'themes/default is missing'; return 1; }
    theme_default_value=$(sed -n '1p' "$theme_default_file")
    theme_validate_name_value "$theme_default_value" || { theme_error 'themes/default contains an invalid name'; return 1; }
    printf '%s\n' "$theme_default_value"
}

theme_runtime_path() {
    printf '%s/.config/dotfiles/theme\n' "${DOTFILES_TARGET:-${HOME:?HOME is not set}}"
}

theme_metadata_value() {
    theme_metadata_file=$1
    theme_metadata_name=$2
    awk -F "'" -v wanted="$theme_metadata_name" '$1 == wanted "=" { print $2; exit }' "$theme_metadata_file"
}

theme_current_name() {
    theme_current_runtime=$(theme_runtime_path)
    [ -L "$theme_current_runtime" ] || return 1
    theme_current_metadata=$theme_current_runtime/metadata.env
    [ -r "$theme_current_metadata" ] || return 1
    theme_current_value=$(theme_metadata_value "$theme_current_metadata" THEME_NAME)
    theme_validate_name_value "$theme_current_value" || return 1
    printf '%s\n' "$theme_current_value"
}

theme_current() {
    if theme_current_value=$(theme_current_name); then
        printf '%s\n' "$theme_current_value"
    else
        theme_error "no valid active theme at $(theme_runtime_path)"
        return 1
    fi
}

theme_list() {
    theme_list_root=${DOTFILES_ROOT:?DOTFILES_ROOT is required}
    theme_list_current=
    theme_list_current=$(theme_current_name 2>/dev/null || true)
    for theme_list_file in "$theme_list_root"/themes/*.env; do
        [ -f "$theme_list_file" ] || continue
        theme_list_name=${theme_list_file##*/}
        theme_list_name=${theme_list_name%.env}
        [ "$theme_list_name" != local ] || continue
        theme_list_appearance=$(theme_read_literal "$theme_list_file" THEME_APPEARANCE)
        theme_list_marker=' '
        [ "$theme_list_name" != "$theme_list_current" ] || theme_list_marker='*'
        printf '%s %-20s %s\n' "$theme_list_marker" "$theme_list_name" "$theme_list_appearance"
    done
    theme_list_marker=' '
    [ "$theme_list_current" != terminal-pro ] || theme_list_marker='*'
    printf '%s %-20s %s\n' "$theme_list_marker" terminal-pro 'alias -> terminal-basic-dark'
}

theme_runtime_is_managed() {
    theme_managed_runtime=$1
    [ -L "$theme_managed_runtime" ] || return 1
    theme_managed_target=$(readlink "$theme_managed_runtime")
    case $theme_managed_target in
        "$DOTFILES_ROOT"/themes/generated/*) return 0 ;;
        "$DOTFILES_ROOT"/themes/.generated-local/*) return 0 ;;
        "$DOTFILES_ROOT"/packages/theme-runtime/.config/dotfiles/theme) return 0 ;;
    esac
    if [ -d "$theme_managed_runtime" ]; then
        theme_managed_resolved=$(CDPATH= cd -P "$theme_managed_runtime" 2>/dev/null && pwd || true)
        case $theme_managed_resolved in
            "$DOTFILES_ROOT"/themes/generated/*|"$DOTFILES_ROOT"/themes/.generated-local/*) return 0 ;;
        esac
    fi
    return 1
}

theme_switch_runtime() {
    theme_switch_target=$1
    theme_switch_runtime=$(theme_runtime_path)
    theme_switch_parent=${theme_switch_runtime%/*}

    if [ -e "$theme_switch_runtime" ] && [ ! -L "$theme_switch_runtime" ]; then
        theme_error "runtime path exists and is not a managed symlink: $theme_switch_runtime"
        return 1
    fi
    if [ -L "$theme_switch_runtime" ] && ! theme_runtime_is_managed "$theme_switch_runtime"; then
        theme_error "refusing to replace an unmanaged symlink: $theme_switch_runtime"
        return 1
    fi
    mkdir -p "$theme_switch_parent"
    theme_switch_tmp=$theme_switch_parent/.theme.$$
    [ ! -e "$theme_switch_tmp" ] && [ ! -L "$theme_switch_tmp" ] || {
        theme_error "temporary runtime path already exists: $theme_switch_tmp"
        return 1
    }
    ln -s "$theme_switch_target" "$theme_switch_tmp"
    if ! theme_replace_current "$theme_switch_tmp" "$theme_switch_runtime"; then
        theme_error 'could not atomically switch the runtime theme; previous selection is intact'
        return 1
    fi
}

theme_runtime_preflight() {
    theme_preflight_runtime=$(theme_runtime_path)
    if [ -e "$theme_preflight_runtime" ] && [ ! -L "$theme_preflight_runtime" ]; then
        theme_error "runtime path exists and will not be replaced: $theme_preflight_runtime"
        return 1
    fi
    if [ -L "$theme_preflight_runtime" ] && ! theme_runtime_is_managed "$theme_preflight_runtime"; then
        theme_error "runtime symlink is not managed by this repository: $theme_preflight_runtime"
        return 1
    fi
}

theme_ensure_default() {
    if theme_current_name >/dev/null 2>&1; then
        return 0
    fi
    theme_ensure_name=$(theme_default_name)
    theme_apply "$theme_ensure_name"
}

theme_remove_runtime() {
    theme_remove_path=$(theme_runtime_path)
    if [ ! -e "$theme_remove_path" ] && [ ! -L "$theme_remove_path" ]; then
        printf '%s\n' 'Theme runtime: nothing to remove.'
        return 0
    fi
    if ! theme_runtime_is_managed "$theme_remove_path"; then
        theme_error "leaving unmanaged runtime path untouched: $theme_remove_path"
        return 1
    fi
    if [ "${DOTFILES_DRY_RUN-0}" -eq 1 ]; then
        printf 'Would remove managed theme runtime link: %s\n' "$theme_remove_path"
        return 0
    fi
    rm -f "$theme_remove_path"
    printf 'Removed managed theme runtime link: %s\n' "$theme_remove_path"
}

theme_output_digest() {
    theme_digest_output=$1
    theme_digest_manifest=$2
    (
        CDPATH= cd -P "$theme_digest_output"
        find . -type f -print | LC_ALL=C sort | while IFS= read -r theme_digest_file; do
            printf '%s ' "$theme_digest_file"
            git hash-object "$theme_digest_file"
        done
    ) >"$theme_digest_manifest"
    git hash-object "$theme_digest_manifest"
}

theme_replace_current() {
    theme_replace_source=$1
    theme_replace_target=$2

    if [ ! -e "$theme_replace_target" ] && [ ! -L "$theme_replace_target" ]; then
        mv "$theme_replace_source" "$theme_replace_target"
        return
    fi

    # GNU mv needs -T for a symlink-to-directory; BSD mv provides -h.
    if mv -Tf "$theme_replace_source" "$theme_replace_target" 2>/dev/null; then
        return
    fi
    if mv -hf "$theme_replace_source" "$theme_replace_target" 2>/dev/null; then
        return
    fi

    # Conservative fallback for other POSIX environments, with rollback.
    theme_replace_backup=${theme_replace_target}.rollback.$$
    [ ! -e "$theme_replace_backup" ] && [ ! -L "$theme_replace_backup" ] || return 1
    mv "$theme_replace_target" "$theme_replace_backup" || return 1
    if mv "$theme_replace_source" "$theme_replace_target"; then
        rm -f "$theme_replace_backup"
        return
    fi
    mv "$theme_replace_backup" "$theme_replace_target"
    return 1
}

theme_apply() (
    set -eu
    theme_requested_name=${1-}
    theme_validate_name_value "$theme_requested_name" || { theme_error 'invalid or missing theme name'; exit 2; }
    theme_name=$(theme_canonical_name "$theme_requested_name")
    DOTFILES_ROOT=${DOTFILES_ROOT:?DOTFILES_ROOT is required}
    DOTFILES_TARGET=${DOTFILES_TARGET:-${HOME:?HOME is not set}}
    theme_load_palette "$theme_name" 1

    theme_stage=$(mktemp -d "$DOTFILES_ROOT/themes/.theme-stage.XXXXXX")
    trap 'rm -rf "$theme_stage"' EXIT HUP INT TERM
    mkdir -p "$theme_stage/output" "$theme_stage/firefox"
    theme_generate_metadata "$theme_stage/output"
    theme_generate_kitty "$theme_stage/output"
    theme_generate_ghostty "$theme_stage/output"
    theme_generate_shell "$theme_stage/output"
    theme_generate_tmux "$theme_stage/output"
    theme_generate_hyprland "$theme_stage/output"
    theme_generate_css "$theme_stage/output"
    theme_generate_nvim "$theme_stage/output"
    theme_generate_starship "$theme_stage/output"
    theme_validate_output "$theme_stage/output"
    theme_generate_firefox_bundle "$theme_stage/firefox"

    command -v git >/dev/null 2>&1 || {
        theme_error 'git is required to identify deterministic generated output'
        exit 1
    }
    theme_digest=$(theme_output_digest "$theme_stage/output" "$theme_stage/digest-manifest")
    theme_generated_root=$DOTFILES_ROOT/themes/generated
    [ "$THEME_HAS_OVERRIDES" -eq 0 ] || theme_generated_root=$DOTFILES_ROOT/themes/.generated-local
    theme_target=$theme_generated_root/$theme_name-$theme_digest
    theme_runtime=$(theme_runtime_path)
    theme_runtime_preflight
    theme_selection_changed=1
    if [ -L "$theme_runtime" ] && [ "$(readlink "$theme_runtime")" = "$theme_target" ]; then
        theme_selection_changed=0
    fi
    theme_firefox_target=$DOTFILES_ROOT/themes/generated/firefox-terminal-macos/themes.js
    theme_firefox_changed=1
    if [ -f "$theme_firefox_target" ] && cmp -s "$theme_stage/firefox/themes.js" "$theme_firefox_target"; then
        theme_firefox_changed=0
    fi

    if [ "${DOTFILES_DRY_RUN-0}" = 1 ]; then
        if [ -d "$theme_target" ] && [ "$theme_selection_changed" -eq 0 ] && [ "$theme_firefox_changed" -eq 0 ]; then
            printf 'Theme %s is already reproducible; no files would change.\n' "$theme_name"
        else
            printf 'Would apply theme %s to %s for:\n' "$theme_name" "$theme_runtime"
            theme_print_integrations
            [ "$theme_firefox_changed" -eq 0 ] || printf '%s\n' 'Firefox system-appearance bundle'
        fi
        if [ "${DOTFILES_RELOAD-1}" -eq 1 ]; then
            printf 'Would synchronize system appearance to %s and reload supported running applications.\n' "$THEME_APPEARANCE"
        else
            printf '%s\n' 'Would not reload applications or change system appearance.'
        fi
        exit 0
    fi

    mkdir -p "$theme_generated_root" "${theme_firefox_target%/*}"
    theme_changed=0
    if [ ! -d "$theme_target" ]; then
        theme_changed=1
        mv "$theme_stage/output" "$theme_target"
    fi
    if [ "$theme_firefox_changed" -eq 1 ]; then
        theme_firefox_tmp=${theme_firefox_target%/*}/.themes.$$
        mv "$theme_stage/firefox/themes.js" "$theme_firefox_tmp"
        theme_replace_current "$theme_firefox_tmp" "$theme_firefox_target" || {
            theme_error 'could not atomically update the Firefox theme bundle'
            exit 1
        }
    fi

    theme_previous_present=0
    theme_previous_target=
    if [ -L "$theme_runtime" ]; then
        theme_previous_present=1
        theme_previous_target=$(readlink "$theme_runtime")
    fi
    theme_switch_runtime "$theme_target"

    if [ "${DOTFILES_RELOAD-1}" -eq 1 ]; then
        if ! theme_reload_preflight; then
            if [ "$theme_previous_present" -eq 1 ]; then
                theme_switch_runtime "$theme_previous_target" || theme_error 'warning: failed to restore the previous runtime link'
            else
                rm -f "$theme_runtime"
            fi
            theme_error 'live reload preflight failed; the previous theme selection was restored'
            exit 1
        fi
    fi

    if [ "$theme_changed" -eq 1 ] || [ "$theme_selection_changed" -eq 1 ]; then
        printf 'Applied theme %s (%s) to:\n' "$theme_name" "$THEME_APPEARANCE"
        theme_print_integrations
    else
        printf 'Theme %s is already current; generated output is unchanged.\n' "$theme_name"
    fi

    if [ "${DOTFILES_RELOAD-1}" -eq 1 ]; then
        if ! theme_reload_all "$THEME_APPEARANCE"; then
            theme_error 'theme remains selected, but one or more live integrations failed'
            exit 1
        fi
    else
        printf '%s\n' 'Live reload: disabled; system appearance was not changed.'
    fi
)

theme_toggle() {
    if theme_toggle_current=$(theme_current_name); then
        theme_toggle_metadata=$(theme_runtime_path)/metadata.env
        theme_toggle_next=$(theme_metadata_value "$theme_toggle_metadata" THEME_ALTERNATE)
        theme_validate_name_value "$theme_toggle_next" || {
            theme_error "active theme $theme_toggle_current has no valid alternate"
            return 1
        }
    else
        theme_toggle_next=$(theme_default_name)
    fi
    theme_apply "$theme_toggle_next"
}

theme_direct_main() {
    DOTFILES_DRY_RUN=${DOTFILES_DRY_RUN:-0}
    DOTFILES_RELOAD=${DOTFILES_RELOAD:-1}
    DOTFILES_TARGET=${DOTFILES_TARGET:-${HOME:?HOME is not set}}
    export DOTFILES_DRY_RUN DOTFILES_RELOAD DOTFILES_TARGET
    case ${1-} in
        list) shift; theme_list "$@" ;;
        current) shift; theme_current "$@" ;;
        apply) shift; theme_apply "$@" ;;
        toggle) shift; theme_toggle "$@" ;;
        *) theme_error 'usage: theme.sh list | current | apply THEME | toggle'; return 2 ;;
    esac
}

if [ "${0##*/}" = theme.sh ]; then
    if [ -z "${DOTFILES_ROOT-}" ]; then
        theme_script_dir=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
        DOTFILES_ROOT=$(CDPATH= cd -P "$theme_script_dir/../.." && pwd)
        export DOTFILES_ROOT
    fi
    # shellcheck source=core.sh
    . "$DOTFILES_ROOT/scripts/lib/core.sh"
    # shellcheck source=platform.sh
    . "$DOTFILES_ROOT/scripts/lib/platform.sh"
    # shellcheck source=packages.sh
    . "$DOTFILES_ROOT/scripts/lib/packages.sh"
    # shellcheck source=theme-reload.sh
    . "$DOTFILES_ROOT/scripts/lib/theme-reload.sh"
    theme_direct_main "$@"
fi
