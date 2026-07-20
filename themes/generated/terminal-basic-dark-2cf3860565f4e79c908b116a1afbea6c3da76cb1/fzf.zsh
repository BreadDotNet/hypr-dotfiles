# Generated from themes/terminal-basic-dark.env. Do not edit.
if (( ! ${+DOTFILES_FZF_BASE_OPTS} )); then
  typeset -g DOTFILES_FZF_BASE_OPTS="${FZF_DEFAULT_OPTS-}"
fi
export FZF_DEFAULT_OPTS="${DOTFILES_FZF_BASE_OPTS:+$DOTFILES_FZF_BASE_OPTS }--color=fg:#FFFFFF,bg:#1E1E1E,hl:#6A42F6,fg+:#FFFFFF,bg+:#3F638B,hl+:#41C4D1,info:#41C4D1,prompt:#6A42F6,pointer:#D6492E,marker:#42C732,spinner:#B8B72F,header:#909090,border:#909090"
