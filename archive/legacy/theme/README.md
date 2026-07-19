# E-ink Theme System

## Overview

A two-variant cactusbuddy-based theme with dark and tuned light palettes, built around
one source of truth: `theme/palette.sh`.

Run `theme/generate.sh <dark|light>` to regenerate active desktop configs:

```
palette.sh
    -> generate.sh <dark|light>
        -> hyprland/.config/hypr/e-ink.conf
        -> waybar/.config/waybar/e-ink.css
        -> waybar/.config/waybar/config.jsonc
        -> starship/.config/starship.toml
        -> tmux/e-ink.tmux.conf
        -> kitty/.config/kitty/e-ink-theme.conf
        -> firefox/extensions/e-ink-theme/themes.js
        -> zshrc/.zsh-syntax-highlighting-theme.zsh
        -> wofi/.config/wofi/e-ink.css
        -> ghostty/.config/ghostty/e-ink-theme.conf
```

Neovim reads `palette.sh` directly via `nvim/.config/nvim/lua/e-ink/palette.lua`.
`theme/switch.sh` persists the mode in `~/.cache/e-ink-theme`, regenerates configs,
and reloads running apps best-effort.

## Palette Contract

Variable names follow `{VARIANT}_{NAME}`, where `VARIANT` is `DARK` or `LIGHT`.
Hex values are stored without `#`.

Mono aliases keep the same contrast model in both variants:

| Alias | Use |
| --- | --- |
| `BG` | primary background |
| `SURFACE` | raised surfaces, popup backgrounds |
| `OVERLAY` | hover/selection surfaces |
| `FAINT`, `DIM`, `MUTED`, `SUBTLE` | low-emphasis UI/text |
| `BORDER` | separators and pane borders |
| `SECONDARY`, `TERTIARY` | secondary text and metadata |
| `FG` | primary body text |
| `EMPHASIS`, `STRONG`, `BRIGHT`, `INTENSE` | stronger foregrounds |

Accent aliases keep behavior stable across apps:

| Alias | Use |
| --- | --- |
| `ERROR` | failures, critical state |
| `WARNING` | warnings and degraded state |
| `OK` | success, active/healthy state |
| `INFO` | informational highlight |
| `HINT` | links and hint-like highlights |
| `SEARCH` | search/find highlights |
| `VCS_ADD`, `VCS_CHANGE`, `VCS_REMOVE` | git/diff foregrounds |
| `DIFF_ADD`, `DIFF_CHANGE`, `DIFF_REMOVE` | diff background tints |

Raw cactusbuddy aliases are also exposed for targets that need them:
`CACTUS`, `GRASS`, `FRUIT`, `BRICK`, `BROWN`, `CYAN`.

## Generated Files

Do not edit generated files by hand:

- `hyprland/.config/hypr/e-ink.conf`
- `waybar/.config/waybar/e-ink.css`
- `waybar/.config/waybar/config.jsonc`
- `starship/.config/starship.toml` between `# BEGIN E-INK GENERATED PALETTES`
  and `# END E-INK GENERATED PALETTES`
- `tmux/e-ink.tmux.conf`
- `kitty/.config/kitty/e-ink-theme.conf`
- `firefox/extensions/e-ink-theme/themes.js`
- `zshrc/.zsh-syntax-highlighting-theme.zsh`
- `wofi/.config/wofi/e-ink.css`
- `ghostty/.config/ghostty/e-ink-theme.conf`

Manual theme consumers:

- `wofi/.config/wofi/style.css` imports generated `e-ink.css`.
- `ghostty/.config/ghostty/config` includes generated `e-ink-theme.conf`.
- `hyprlock/.config/hypr/hyprlock.conf` sources generated Hyprland colors and uses
  `$nameAlpha` variables for Pango markup.
- `starship/.config/starship.toml` keeps prompt layout manually; only palette blocks
  are generated.
- Firefox reads `firefox/extensions/e-ink-theme/themes.js` only after the extension
  is reloaded. Rebuild with `web-ext build --overwrite-dest` from
  `firefox/extensions/e-ink-theme/`, then reload the temporary extension or install
  the new archive from `web-ext-artifacts/`.

## Switching Themes

```
theme/switch.sh [dark|light|toggle]
```

Reload mechanism: `hyprctl reload`, Waybar `SIGUSR2`, Neovim `SIGUSR1`, tmux
`source-file`, Kitty `SIGUSR1`, and zsh `SIGUSR2`. Ghostty, Wofi, and Hyprlock pick
up generated files on next launch.
