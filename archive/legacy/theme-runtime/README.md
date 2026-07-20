# Legacy theme runtime bridge

This directory preserves the intermediate tracked `themes/current` symlink, its
generated Basic output, the obsolete `theme-runtime` Stow package and both
intermediate Pro revisions. They were replaced by the CLI-managed runtime symlink
`~/.config/dotfiles/theme`, which can switch without modifying Git state.

Nothing below this directory is selected by a manifest or used by current theme
generation. The relative links were adjusted only so the archived recovery tree
does not contain broken symlinks.
