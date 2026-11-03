#!/bin/sh

set -eu

TEST_DIR=$(CDPATH= cd -P "$(dirname "$0")" && pwd)
TEST_ROOT=$(CDPATH= cd -P "$TEST_DIR/../.." && pwd)
if ! command -v tmux >/dev/null 2>&1; then
    printf '%s\n' 'SKIP: tmux-wikkeo integration (tmux unavailable)'
    exit 0
fi
TEST_REAL_TMUX=$(command -v tmux)
TEST_TMP=$(mktemp -d /tmp/dfw.XXXXXX)
TEST_SOCKET="$TEST_TMP/tmux.sock"
TEST_LOG="$TEST_TMP/connect.log"
cleanup() {
    "$TEST_REAL_TMUX" -S "$TEST_SOCKET" kill-server 2>/dev/null || :
    rm -rf "$TEST_TMP"
}
trap cleanup EXIT HUP INT TERM
export TEST_REAL_TMUX TEST_SOCKET TEST_LOG
export HOME="$TEST_TMP/home with spaces"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export SHELL=/bin/sh
export WIKKEO_PROJECTS_ROOT="$HOME/projects/wikkeo"
unset TMUX
mkdir -p "$TEST_TMP/bin" "$HOME/.local/bin" "$HOME/zsh-scripts"
ln -s "$TEST_ROOT/packages/shell/.local/bin/tmux-wikkeo" "$HOME/.local/bin/tmux-wikkeo"
cat > "$TEST_TMP/bin/tmux" <<'EOF'
#!/bin/sh
set -eu
case "$1" in
    attach-session|switch-client) printf '%s\n' "$*" >> "$TEST_LOG" ;;
    *) unset TMUX; exec "$TEST_REAL_TMUX" -S "$TEST_SOCKET" "$@" ;;
esac
EOF
chmod +x "$TEST_TMP/bin/tmux"
export PATH="$TEST_TMP/bin:$PATH"
launcher="$HOME/.local/bin/tmux-wikkeo"

# Validate every directory before touching the server.
mkdir -p "$WIKKEO_PROJECTS_ROOT/wikkeo-catalog-intake" "$WIKKEO_PROJECTS_ROOT/wikkeo-seller-app"
if "$launcher" > "$TEST_TMP/missing.out" 2>&1; then exit 1; fi
grep -q 'missing project directory:.*wikkeo_flutter' "$TEST_TMP/missing.out"
[ ! -e "$TEST_SOCKET" ]
mkdir -p "$WIKKEO_PROJECTS_ROOT/wikkeo_flutter"
if "$launcher" unexpected > "$TEST_TMP/usage.out" 2>&1; then exit 1; else [ "$?" -eq 2 ]; fi
[ ! -e "$TEST_SOCKET" ]

# Load only the repository config in the isolated server, without plugins.
tmux -f "$TEST_ROOT/packages/tmux/.tmux.conf" new-session -d -s fixture
(unset WIKKEO_PROJECTS_ROOT; "$launcher")
[ "$(cat "$TEST_LOG")" = 'attach-session -t =intake' ]
[ "$(tmux list-sessions -F '#{session_name}' | sort)" = "$(printf '%s\n' client fixture intake seller)" ]
# Session IDs establish creation order independently of alphabetical listing.
previous=0
for session in intake seller client; do
    id=$(tmux display-message -p -t "$session:" '#{session_id}')
    id=${id#\$}
    [ "$id" -gt "$previous" ]
    previous=$id
    case "$session" in
        intake) project=wikkeo-catalog-intake ;;
        seller) project=wikkeo-seller-app ;;
        client) project=wikkeo_flutter ;;
    esac
    [ "$(tmux list-windows -t "=$session" -F '#{window_index}:#{window_name}')" = "$(printf '%s\n' 1:editor 2:shell 3:ai)" ]
    [ "$(tmux display-message -p -t "$session:" '#{window_name}')" = editor ]
    for window in editor shell ai; do
        [ "$(tmux show-options -wv -t "$session:$window" automatic-rename)" = off ]
        [ "$(tmux show-options -wv -t "$session:$window" allow-rename)" = off ]
        [ "$(tmux display-message -p -t "$session:$window" '#{pane_current_path}')" = "$WIKKEO_PROJECTS_ROOT/$project" ]
        [ "$(tmux display-message -p -t "$session:$window" '#{pane_current_command}')" = sh ]
    done
done
binding=$(tmux list-keys -T prefix | grep 'choose-tree.*index')
case "$binding" in
    *choose-tree*index*) : ;;
    *) printf 'Unexpected session binding: %s\n' "$binding" >&2; exit 1 ;;
esac

# Reuse even a customized session without restarting or adding windows.
tmux rename-window -t seller:shell work
tmux new-window -d -t seller: -n extra
tmux list-panes -a -F '#{pane_id}:#{pane_pid}' > "$TEST_TMP/panes.before"
"$launcher"
tmux list-panes -a -F '#{pane_id}:#{pane_pid}' > "$TEST_TMP/panes.after"
cmp "$TEST_TMP/panes.before" "$TEST_TMP/panes.after"
[ "$(tmux list-windows -t '=seller' -F '#{window_name}')" = "$(printf '%s\n' editor work ai extra)" ]
TMUX=isolated-fixture "$launcher"
[ "$(tail -n 1 "$TEST_LOG")" = 'switch-client -t =intake' ]

# The shell function must preserve the legacy command and forward arguments.
if command -v zsh >/dev/null 2>&1; then
    cat > "$HOME/zsh-scripts/tmux.sh" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$HOME/legacy.args"
EOF
    chmod +x "$HOME/zsh-scripts/tmux.sh"
    zsh -f -c 'source "$1"; tdev "argument with spaces"; tdev --wikkeo' test \
        "$TEST_ROOT/packages/shell/.config/dotfiles/shell/common.zsh"
    [ "$(cat "$HOME/legacy.args")" = 'argument with spaces' ]
else
    printf '%s\n' 'SKIP: tdev dispatch (zsh unavailable)'
fi

# With an empty PATH, the launcher should fail before attempting tmux.
if PATH="$TEST_TMP/empty" /bin/sh "$launcher" > "$TEST_TMP/no-tmux.out" 2>&1; then
    exit 1
else
    [ "$?" -eq 127 ]
fi
grep -q 'tmux is not installed' "$TEST_TMP/no-tmux.out"
printf '%s\n' 'PASS: tmux-wikkeo isolated integration and tdev dispatch'
