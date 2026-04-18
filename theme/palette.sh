#!/usr/bin/env bash
# E-ink color palette — single source of truth
# Derived from e-ink.nvim/lua/e-ink/palette.lua
# Format: VARIANT_NAME=HEXVALUE (no # prefix)

# --- Dark mono (16 greyscale shades, dark to light) ---
DARK_MONO1=333333
DARK_MONO2=474747
DARK_MONO3=4A4A4A
DARK_MONO4=545454
DARK_MONO5=5E5E5E
DARK_MONO6=686868
DARK_MONO7=727272
DARK_MONO8=7C7C7C
DARK_MONO9=868686
DARK_MONO10=909090
DARK_MONO11=9A9A9A
DARK_MONO12=A4A4A4
DARK_MONO13=AEAEAE
DARK_MONO14=B8B8B8
DARK_MONO15=C2C2C2
DARK_MONO16=CCCCCC

# --- Light mono (reversed) ---
LIGHT_MONO1=CCCCCC
LIGHT_MONO2=C2C2C2
LIGHT_MONO3=B8B8B8
LIGHT_MONO4=AEAEAE
LIGHT_MONO5=A4A4A4
LIGHT_MONO6=9A9A9A
LIGHT_MONO7=909090
LIGHT_MONO8=868686
LIGHT_MONO9=7C7C7C
LIGHT_MONO10=727272
LIGHT_MONO11=686868
LIGHT_MONO12=5E5E5E
LIGHT_MONO13=545454
LIGHT_MONO14=4A4A4A
LIGHT_MONO15=474747
LIGHT_MONO16=333333

# --- Dark everforest accents ---
DARK_RED=E67E80
DARK_YELLOW=DBBC7F
DARK_GREEN=A7C080
DARK_BLUE=7FBBB3
DARK_AQUA=83C092
DARK_PURPLE=D699B6
DARK_ORANGE=E69875

# --- Light everforest accents ---
LIGHT_RED=F85552
LIGHT_YELLOW=DFA000
LIGHT_GREEN=8DA101
LIGHT_BLUE=3A94C5
LIGHT_AQUA=35A77C
LIGHT_PURPLE=DF69BA
LIGHT_ORANGE=F57D26

# --- Background accent colors ---
DARK_BG_RED=4C3743
DARK_BG_GREEN=3C4841
DARK_BG_BLUE=384B55
LIGHT_BG_RED=FFE7DE
LIGHT_BG_GREEN=f3f5d9
LIGHT_BG_BLUE=ECF5ED

# --- Semantic mono aliases (dark) ---
# Contrast scale: MONO1 = least contrast from background → MONO16 = max contrast.
# For dark mode MONO1 is the darkest shade (BG) and MONO16 the lightest (INTENSE).
# Pick values by asking: "how much should this element stand out from the background?"
# BG primary background (windows, panels)
DARK_BG=$DARK_MONO1
# SURFACE raised surface (cards, inactive tabs, popup bg)
DARK_SURFACE=$DARK_MONO2
# OVERLAY hovered/overlaid element, modal backdrop
DARK_OVERLAY=$DARK_MONO4
# FAINT faintest UI element, divider lines
DARK_FAINT=$DARK_MONO5
# DIM dim UI element (disabled glyphs, placeholder text)
DARK_DIM=$DARK_MONO6
# MUTED muted text (code comments, unfocused status bar segments)
DARK_MUTED=$DARK_MONO7
# SUBTLE subtle foreground (icons in idle/resting state)
DARK_SUBTLE=$DARK_MONO8
# BORDER default border / separator between regions
DARK_BORDER=$DARK_MONO9
# SECONDARY secondary text (timestamps, less-important labels)
DARK_SECONDARY=$DARK_MONO10
# TERTIARY tertiary text (metadata, line numbers)
DARK_TERTIARY=$DARK_MONO11
# FG primary body text (most prose and UI labels)
DARK_FG=$DARK_MONO12
# EMPHASIS emphasized text (active menu item, selected list entry)
DARK_EMPHASIS=$DARK_MONO13
# STRONG strong foreground (headings, prominent status icons)
DARK_STRONG=$DARK_MONO14
# BRIGHT bright/highlighted text (search match foreground, notifications)
DARK_BRIGHT=$DARK_MONO15
# INTENSE max-contrast: cursor, active tab indicator, strongest focus ring
DARK_INTENSE=$DARK_MONO16

# --- Semantic mono aliases (light) ---
# Same contrast-scale model as dark above; MONO1 is now the lightest shade (BG)
# and MONO16 is the darkest (INTENSE).  The alias names and semantics are identical.
# BG primary background (windows, panels)
LIGHT_BG=$LIGHT_MONO1
# SURFACE raised surface (cards, inactive tabs, popup bg)
LIGHT_SURFACE=$LIGHT_MONO2
# OVERLAY hovered/overlaid element, modal backdrop
LIGHT_OVERLAY=$LIGHT_MONO4
# FAINT faintest UI element, divider lines
LIGHT_FAINT=$LIGHT_MONO5
# DIM dim UI element (disabled glyphs, placeholder text)
LIGHT_DIM=$LIGHT_MONO6
# MUTED muted text (code comments, unfocused status bar segments)
LIGHT_MUTED=$LIGHT_MONO7
# SUBTLE subtle foreground (icons in idle/resting state)
LIGHT_SUBTLE=$LIGHT_MONO8
# BORDER default border / separator between regions
LIGHT_BORDER=$LIGHT_MONO9
# SECONDARY secondary text (timestamps, less-important labels)
LIGHT_SECONDARY=$LIGHT_MONO10
# TERTIARY tertiary text (metadata, line numbers)
LIGHT_TERTIARY=$LIGHT_MONO11
# FG primary body text (most prose and UI labels)
LIGHT_FG=$LIGHT_MONO12
# EMPHASIS emphasized text (active menu item, selected list entry)
LIGHT_EMPHASIS=$LIGHT_MONO13
# STRONG strong foreground (headings, prominent status icons)
LIGHT_STRONG=$LIGHT_MONO14
# BRIGHT bright/highlighted text (search match foreground, notifications)
LIGHT_BRIGHT=$LIGHT_MONO15
# INTENSE max-contrast: cursor, active tab indicator, strongest focus ring
LIGHT_INTENSE=$LIGHT_MONO16

# --- Semantic accent aliases (dark) ---
# Accent semantics are identical across variants; only the raw hex values differ.
# ERROR failures, critical battery, disconnected network
DARK_ERROR=$DARK_RED
# WARNING warnings, low battery, degraded state
DARK_WARNING=$DARK_YELLOW
# OK success, charging, active/healthy state
DARK_OK=$DARK_GREEN
# INFO informational highlight (cyan-ish)
DARK_INFO=$DARK_AQUA
# HINT hints, URLs, hyperlinks (blue-ish)
DARK_HINT=$DARK_BLUE
# SEARCH search/find highlights (orange-ish)
DARK_SEARCH=$DARK_ORANGE
# VCS_ADD added lines / new file indicator in git status
DARK_VCS_ADD=$DARK_GREEN
# VCS_CHANGE modified lines / changed file indicator in git status
DARK_VCS_CHANGE=$DARK_BLUE
# VCS_REMOVE deleted lines / removed file indicator in git status
DARK_VCS_REMOVE=$DARK_RED

# --- Semantic accent aliases (light) ---
# Same semantics as dark block above.
# ERROR failures, critical battery, disconnected network
LIGHT_ERROR=$LIGHT_RED
# WARNING warnings, low battery, degraded state
LIGHT_WARNING=$LIGHT_YELLOW
# OK success, charging, active/healthy state
LIGHT_OK=$LIGHT_GREEN
# INFO informational highlight (cyan-ish)
LIGHT_INFO=$LIGHT_AQUA
# HINT hints, URLs, hyperlinks (blue-ish)
LIGHT_HINT=$LIGHT_BLUE
# SEARCH search/find highlights (orange-ish)
LIGHT_SEARCH=$LIGHT_ORANGE
# VCS_ADD added lines / new file indicator in git status
LIGHT_VCS_ADD=$LIGHT_GREEN
# VCS_CHANGE modified lines / changed file indicator in git status
LIGHT_VCS_CHANGE=$LIGHT_BLUE
# VCS_REMOVE deleted lines / removed file indicator in git status
LIGHT_VCS_REMOVE=$LIGHT_RED

# --- Semantic diff background aliases ---
# Low-saturation tinted backgrounds for diff views; pair with VCS_* foregrounds.
# DIFF_ADD background tint for added/inserted content
DARK_DIFF_ADD=$DARK_BG_GREEN
# DIFF_CHANGE background tint for modified content
DARK_DIFF_CHANGE=$DARK_BG_BLUE
# DIFF_REMOVE background tint for deleted/removed content
DARK_DIFF_REMOVE=$DARK_BG_RED
LIGHT_DIFF_ADD=$LIGHT_BG_GREEN
LIGHT_DIFF_CHANGE=$LIGHT_BG_BLUE
LIGHT_DIFF_REMOVE=$LIGHT_BG_RED
