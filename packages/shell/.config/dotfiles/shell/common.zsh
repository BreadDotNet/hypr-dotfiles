# Common aliases and user-space tool locations.
alias lg='lazygit'
function tdev() {
  "$HOME/zsh-scripts/tmux.sh" "$@"
}

function dotfiles_theme_refresh() {
  local runtime="$HOME/.config/dotfiles/theme"
  [[ -r "$runtime/fzf.zsh" ]] && source "$runtime/fzf.zsh"
  [[ -r "$runtime/zsh-theme.zsh" ]] && source "$runtime/zsh-theme.zsh"
  DOTFILES_THEME_RUNTIME_TARGET="$(readlink "$runtime" 2>/dev/null)"
}

function dotfiles_theme_precmd() {
  local runtime="$HOME/.config/dotfiles/theme"
  local current_target="$(readlink "$runtime" 2>/dev/null)"
  if [[ -n "$current_target" && "$current_target" != "${DOTFILES_THEME_RUNTIME_TARGET-}" ]]; then
    dotfiles_theme_refresh
  fi
}

if autoload -Uz add-zsh-hook 2>/dev/null; then
  add-zsh-hook precmd dotfiles_theme_precmd
fi

function theme() {
  local action="${1:-toggle}"
  local result
  (( $# == 0 )) || shift
  case "$action" in
    toggle) "$DOTFILES_REPO_ROOT/bin/dotfiles" theme toggle "$@" ;;
    light) "$DOTFILES_REPO_ROOT/bin/dotfiles" theme apply terminal-basic "$@" ;;
    dark) "$DOTFILES_REPO_ROOT/bin/dotfiles" theme apply terminal-pro "$@" ;;
    current|list) "$DOTFILES_REPO_ROOT/bin/dotfiles" theme "$action" "$@" ;;
    *)
      print -u2 'usage: theme [toggle|light|dark|current|list]'
      return 2
      ;;
  esac
  result=$?
  if [[ "$action" == toggle || "$action" == light || "$action" == dark ]]; then
    dotfiles_theme_refresh
    if [[ -o interactive ]] && zle >/dev/null 2>&1; then
      zle reset-prompt
    fi
  fi
  return "$result"
}

function y() {
  local tmp cwd
  command -v yazi >/dev/null 2>&1 || return 127
  tmp="$(mktemp -t 'yazi-cwd.XXXXXX')" || return
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export BUN_INSTALL="$HOME/.bun"
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.opencode/bin"
  "$HOME/development/flutter/bin"
  $path
)

export GOPATH="$HOME/go"
if command -v go >/dev/null 2>&1; then
  dotfiles_go_bin="$(go env GOBIN 2>/dev/null)"
  [[ -n "$dotfiles_go_bin" ]] && path+=("$dotfiles_go_bin")
  dotfiles_go_path="$(go env GOPATH 2>/dev/null)"
  [[ -n "$dotfiles_go_path" ]] && path+=("$dotfiles_go_path/bin")
  unset dotfiles_go_bin dotfiles_go_path
fi
export GIT_EDITOR='nvim'
export OMO_SEND_ANONYMOUS_TELEMETRY=0
export OMO_DISABLE_POSTHOG=1

[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
