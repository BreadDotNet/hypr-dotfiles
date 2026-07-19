# Theme artifacts

`palettes/terminal-macos.env` owns the shared 16 ANSI colors and semantic
application colors. `terminal-basic.env` and `terminal-pro.env` are the light
and dark variants: they add appearance metadata, background/foreground, cursor,
selection and mode-aware surface colors. These are portable Terminal
Basic/Pro-compatible palettes, not a guarantee of pixel-identical Terminal.app
rendering.

The files are trusted POSIX assignments, but the generator validates an explicit
variable allowlist before sourcing them. Resolution order is:

1. `themes/palettes/$THEME_BASE.env`;
2. `themes/<name>.env`;
3. `hosts/$DOTFILES_HOST/theme.env`, when selected;
4. ignored `themes/local.env`.

Generated base variants live in committed content-addressed directories under
`generated/<name>-<hash>/`. Host/local override output goes to ignored
`.generated-local/`. Generated files carry a warning header and must not be
edited directly.

The active selection is the runtime symlink
`~/.config/dotfiles/theme -> <repository>/themes/generated/...`; it is not a Git
file or Stow target. This keeps daily switching out of `git status`. `default`
contains the initial theme used by `dotfiles install` when no runtime selection
exists. Install never reloads applications or changes system appearance.

```sh
dotfiles theme list
dotfiles theme current
dotfiles theme toggle
dotfiles theme apply terminal-pro
dotfiles theme apply terminal-basic --no-reload
```

Apply/toggle validates and stages the whole candidate before atomically replacing
the runtime link. With live reload enabled it synchronizes system appearance and
reloads supported running applications. A generation or Hyprland preflight
failure preserves the previous selection; later integration failures are
reported with a nonzero status while the validated new selection remains active.

`generated/firefox-terminal-macos/themes.js` is a stable deterministic bundle
containing both variants. The Firefox background script follows
`prefers-color-scheme`, so it changes after the platform appearance adapter
selects light or dark. No Terminal.app profile or macOS `defaults` value is
written.
