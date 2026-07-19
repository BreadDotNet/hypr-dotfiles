# AGENTS.md

## Purpose

This repository manages personal cross-platform dotfiles with GNU Stow. Preserve
working user behavior and make the smallest justified changes. Never add an app
configuration merely to demonstrate the architecture.

## Architecture

- `packages/<name>/` is the only location for active Stow packages. Every package
  mirrors paths relative to `$HOME`.
- `manifests/` selects packages. Automatic selection is `common`, then `linux`,
  then a known distribution such as `arch`; macOS uses `common`, then `macos`.
- An unknown Linux distribution receives common+linux config only. Never infer a
  package manager.
- Platform adapters live in `scripts/platforms/`. Add a new adapter instead of
  adding distribution conditionals to the CLI core.
- `archive/legacy/` is recovery-only and must never be stowed or listed in an
  active manifest.
- `hosts/` contains examples and non-secret machine overrides. Keep actual local
  secrets outside the repository.

## Overlay order

When multiple layers affect one application, use one owning Stow target that
optionally loads fragments in this order:

```text
common -> linux -> arch/macos -> host -> local
```

Do not create two automatically selected packages with the same target path.
Missing optional fragments must be harmless. Hardware-specific monitor config is
host/local data, not a common default.

## Theme contract

- `themes/palettes/<base>.env` owns shared ANSI/semantic colors;
  `themes/<name>.env` owns variant metadata and surfaces. Generated files are
  artifacts, not hand-edited palettes.
- Theme files are trusted POSIX assignments with quoted `#RRGGBB` values. Keep an
  explicit allowlist and validate every required base and semantic token before
  sourcing.
- Resolution order is base palette, variant, optional host override, ignored
  local override.
- Generate the entire candidate tree in a temporary directory, validate all
  integrations, then atomically switch the runtime symlink
  `~/.config/dotfiles/theme`. On error preserve the previous complete theme.
- The runtime symlink is deliberately managed by the CLI rather than Stow so
  theme switching never changes tracked repository state. Never replace an
  ordinary file or an unmanaged symlink at that path.
- Generation must be deterministic. Applying the same inputs twice must produce
  byte-identical files.
- Integrate only applications already configured here. Preserve non-color user
  settings and do not duplicate literal HEX values in their main configs.
- `terminal-basic`/`terminal-pro` are portable Terminal-compatible palettes, not
  claims about pixel-identical Terminal.app rendering.
- Explicit `theme apply/toggle` synchronizes system appearance and live apps;
  `install`, `restow`, isolated tests and `--no-reload` must never do so.

## Safety rules

- Never commit tokens, credentials, SSH keys, cookies, shell history, private
  certificates, keychain material, personal data, `.migration-backups/`, or local
  override files.
- Do not change Git remotes, push, rewrite history, use destructive filtering, or
  discard unrelated working-tree changes.
- Do not run package installation, `sudo`, login-shell changes, macOS `defaults`,
  system-service changes, or application reloads without an explicit user
  request.
- Theme appearance on macOS uses the explicit `osascript` appearance adapter;
  never write Terminal.app profiles or macOS `defaults` from theme switching.
- Replacing a live Hyprland config symlink may leave the compositor attached to
  the previous inode. With explicit authorization, run `Hyprland --verify-config`
  before a full `hyprctl reload`, then verify input options, monitor state, and
  `hyprctl configerrors`. Never infer permission to reload from `install` alone.
- Never delete a user file to resolve a Stow conflict. Report it first; make a
  recoverable backup only through an explicit opt-in path.
- Do not use `stow --adopt`.
- Preserve lock files that make active tools reproducible.
- Tests must use a temporary HOME/XDG tree, dry-run, or another isolated target.
  They must not download or update Neovim/tmux plugins.

## Shell and macOS compatibility

- New management scripts must be POSIX `sh`, use `set -eu`, quote paths, clean up
  temporary files with traps, and remain idempotent.
- Resolve the repository relative to the script, never the caller's current
  directory.
- Paths containing spaces must work.
- Do not require Bash 4+, `readlink -f`, GNU-only `sed` or `date`, or other Linux
  extensions unavailable in the default macOS userland.
- Detect Darwin with `uname`; detect Linux distributions through
  `/etc/os-release`.
- Keep package installation explicit. Arch official and AUR lists stay separate;
  do not select an AUR helper. Homebrew must already exist before using Brewfile.

## Validation commands

Run all available checks after relevant changes:

```sh
git status --short
./bin/dotfiles doctor
./bin/dotfiles install --dry-run
./bin/dotfiles theme toggle --dry-run
sh -n bin/dotfiles
find scripts -type f -name '*.sh' -exec sh -n {} \;
```

In addition:

- run repository test scripts in a temporary HOME;
- install twice/restow, then uninstall from the same temporary HOME;
- test an ordinary-file conflict and its recoverable backup path;
- simulate macOS and unknown Linux platform selection;
- verify no selected packages own duplicate targets and archive is never selected;
- compare two theme generations byte-for-byte and test invalid-theme rollback;
- verify `theme` switching leaves `git status` unchanged and test live adapters
  with fake processes/system APIs rather than the real desktop;
- search for nested `.git`, `.git` files, mode `160000` gitlinks, broken symlinks,
  and likely secrets;
- run offline Neovim headless and an isolated tmux config check if installed;
- run `shellcheck` and `shfmt` when available, but never install them implicitly.

Document every skipped check and never claim real macOS validation when testing
only on Linux.

Use `DOTFILES_UNAME_S` and `DOTFILES_OS_RELEASE` only in isolated test fixtures
to inject platform detection. They are test seams, not user-facing configuration.

## Completion checklist

- [ ] Working behavior and unrelated user changes are preserved.
- [ ] Active files live under `packages/`; no archive path is stowed.
- [ ] Manifests and adapters implement the documented overlay order.
- [ ] No duplicate selected target, nested Git repository, gitlink, or broken link
      remains.
- [ ] Theme generation validates first, switches atomically, and is deterministic.
- [ ] Fresh install, repeated install/restow, conflict handling, and uninstall pass
      in an isolated HOME.
- [ ] No secret or personal artifact is newly tracked.
- [ ] README and AUDIT reflect behavior actually tested, including skipped checks
      and platform limitations.
- [ ] `git status` is reviewed; no remote, history, package, shell, or system state
      was changed outside the authorized scope.
