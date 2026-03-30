export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Aliases
alias lg="lazygit"
alias tdev="~/zsh-scripts/tmux.sh"
alias theme="~/dotfiles/theme/switch.sh"

eval "$(starship init zsh)"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

[ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Use on start
source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Variables
# export FZF_DEFAULT_COMMAND="ag --hiden --ignore .git -l -g """
# Open in tmux popup if on tmux, otherwise use --height mode
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"
export PATH="$HOME/development/flutter/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin/:$PATH"
export PATH="$HOME/bin:$PATH"
export GOPATH="$HOME/go"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export GIT_EDITOR="nvim"

