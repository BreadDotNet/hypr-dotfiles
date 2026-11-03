#!/bin/sh
set -eu
TEST_DIR=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
TEST_ROOT=$(CDPATH= cd -P "$TEST_DIR/../.." && pwd)
TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/codex-workflow.XXXXXX")
trap 'rm -rf "$TEST_TMP"' EXIT HUP INT TERM
export HOME="$TEST_TMP/home with spaces"
mkdir -p "$HOME"
"$TEST_ROOT/bin/dotfiles" install --package codex --target "$HOME" >/dev/null 2>&1
"$TEST_ROOT/bin/dotfiles" install --package codex --target "$HOME" >/dev/null 2>&1
"$TEST_ROOT/bin/dotfiles" restow --package codex --target "$HOME" >/dev/null 2>&1
[ -L "$HOME/.codex/AGENTS.md" ]
[ -f "$HOME/.agents/skills/engineering-workflow/SKILL.md" ]
mkdir -p "$TEST_TMP/upstream with spaces/skills/example"
printf '%s\n' 'example' > "$TEST_TMP/upstream with spaces/skills/example/SKILL.md"
"$HOME/.local/bin/codex-superpowers-link" "$TEST_TMP/upstream with spaces" >/dev/null
"$HOME/.local/bin/codex-superpowers-link" "$TEST_TMP/upstream with spaces" >/dev/null
[ -f "$HOME/.agents/skills/superpowers-example/SKILL.md" ]
mkdir -p "$TEST_TMP/upstream with spaces/skills/conflict"
printf '%s\n' original > "$HOME/.agents/skills/superpowers-conflict"
printf '%s\n' example > "$TEST_TMP/upstream with spaces/skills/conflict/SKILL.md"
if "$HOME/.local/bin/codex-superpowers-link" "$TEST_TMP/upstream with spaces" >"$TEST_TMP/conflict.out" 2>&1; then exit 1; fi
[ "$(cat "$HOME/.agents/skills/superpowers-conflict")" = original ]
"$TEST_ROOT/bin/dotfiles" uninstall --package codex --target "$HOME" >/dev/null 2>&1
[ ! -e "$HOME/.codex/AGENTS.md" ]
[ -f "$HOME/.agents/skills/superpowers-example/SKILL.md" ]
# Explicit recoverable backup of an ordinary global instructions file.
mkdir -p "$HOME/.codex"
printf '%s\n' personal > "$HOME/.codex/AGENTS.md"
if "$TEST_ROOT/bin/dotfiles" install --package codex --target "$HOME" >"$TEST_TMP/install-conflict.out" 2>&1; then exit 1; fi
[ "$(cat "$HOME/.codex/AGENTS.md")" = personal ]
"$TEST_ROOT/bin/dotfiles" install --package codex --target "$HOME" --backup-conflicts >/dev/null 2>&1
find "$HOME/.local/state/dotfiles/backups" -name AGENTS.md -exec cat {} \; | grep -qx personal
printf '%s\n' 'PASS: Codex install lifecycle, recoverable conflict, native skills idempotence/conflict'
