# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository for an Arch Linux / Hyprland (Wayland) desktop environment. Configs are organized in a GNU Stow-compatible directory structure (`app/.config/app/...`) but are managed via **manual symlinks** — there are no install scripts, Makefile, or stow commands.

The remote is `git@github.com:BreadDotNet/hypr-dotfiles.git`.

## Directory Layout

Each top-level directory mirrors the target path from `$HOME`:

- `hyprland/.config/hypr/` — Hyprland window manager (main WM), including `e-ink.conf` variant
- `waybar/.config/waybar/` — status bar (JSONC config + CSS theming)
- `nvim/.config/nvim/` — Neovim using **NvChad v2.5** framework with lazy.nvim
- `zshrc/.zshrc` — shell config (loads starship prompt + asdf version manager)
- `starship/.config/starship.toml` — prompt theme
- `tmux/.tmux.conf` — tmux with TPM plugin manager (prefix: Ctrl+A, vi keys)
- `yazi/.config/yazi/` — file manager
- `ghostty/`, `kitty/`, `alacritty/` — terminal emulator configs
- `i3/`, `polybar/`, `picom/`, `rofi/`, `xresources/` — legacy X11 configs (no longer primary)

## Theming

Primary theme is **e-ink** (greyscale + everforest accents), with dark and light variants. Some configs (alacritty, kitty, rofi, wofi, tmux, yazi) still use Catppuccin Mocha.

### Unified theme system (`theme/`)

- `theme/palette.sh` — single source of truth for all e-ink colors (46 values)
- `theme/generate.sh <dark|light>` — generates color files for hyprland, waybar, starship
- `theme/switch.sh [dark|light|toggle]` — switches theme, regenerates configs, reloads apps

**Do not edit these files by hand** — they are auto-generated:
- `hyprland/.config/hypr/e-ink.conf`
- `waybar/.config/waybar/e-ink.css`

To change colors, edit `theme/palette.sh` and re-run `theme/generate.sh`. Shell alias: `theme toggle`.

## Neovim

NvChad-based setup. Custom config lives in `nvim/.config/nvim/lua/`:
- `plugins/init.lua` — lazy.nvim plugin specs (conform, lspconfig, flutter-tools, nvim-dap, treesitter)
- `configs/` — per-plugin configuration (includes Go/Delve remote debug setup)
- Plugin lock file: `lazy-lock.json`

## Key Patterns

- No build/test/lint commands — this is a config-only repo
- Commits are short, descriptive messages in lowercase
- Some configs have e-ink display variants (hyprland, waybar)
