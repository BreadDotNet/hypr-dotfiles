# Common interactive shell entrypoint. Optional overlays are safe to omit.
typeset -g DOTFILES_REPO_ROOT="${${(%):-%N}:A:h:h:h}"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="simple"
plugins=(git)
for dotfiles_plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/$dotfiles_plugin" ]]; then
    plugins+=("$dotfiles_plugin")
  fi
done
unset dotfiles_plugin

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

dotfiles_fragment="$HOME/.config/dotfiles/shell/common.zsh"
[[ -r "$dotfiles_fragment" ]] && source "$dotfiles_fragment"

case "$(uname -s 2>/dev/null)" in
  Darwin) dotfiles_platform_fragment="$HOME/.config/dotfiles/shell/macos.zsh" ;;
  Linux)
    dotfiles_fragment="$HOME/.config/dotfiles/shell/linux.zsh"
    [[ -r "$dotfiles_fragment" ]] && source "$dotfiles_fragment"
    dotfiles_platform_fragment=''
    if [[ -r /etc/os-release ]] && grep -Eq '^(ID|ID_LIKE)=.*arch' /etc/os-release; then
      dotfiles_platform_fragment="$HOME/.config/dotfiles/shell/arch.zsh"
    fi
    ;;
  *) dotfiles_platform_fragment='' ;;
esac
[[ -n "$dotfiles_platform_fragment" && -r "$dotfiles_platform_fragment" ]] && source "$dotfiles_platform_fragment"

for dotfiles_fragment in \
  "$HOME/.config/dotfiles/shell/host.zsh" \
  "$HOME/.config/dotfiles/shell/local.zsh"
do
  [[ -r "$dotfiles_fragment" ]] && source "$dotfiles_fragment"
done
unset dotfiles_fragment dotfiles_platform_fragment

if (( $+functions[dotfiles_theme_refresh] )); then
  dotfiles_theme_refresh
elif [[ -r "$HOME/.config/dotfiles/theme/fzf.zsh" ]]; then
  source "$HOME/.config/dotfiles/theme/fzf.zsh"
fi
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh 2>/dev/null)
fi
if (( ! $+functions[dotfiles_theme_refresh] )) && [[ -r "$HOME/.config/dotfiles/theme/zsh-theme.zsh" ]]; then
  source "$HOME/.config/dotfiles/theme/zsh-theme.zsh"
fi

# Uncomment to enable starship
# export STARSHIP_CONFIG="$HOME/.config/dotfiles/theme/starship.toml"
# if command -v starship >/dev/null 2>&1; then
#   eval "$(starship init zsh)"
# fi
