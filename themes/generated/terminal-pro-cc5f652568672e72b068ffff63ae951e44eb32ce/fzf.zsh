# Generated from themes/terminal-pro.env. Do not edit.
if (( ! ${+DOTFILES_FZF_BASE_OPTS} )); then
  typeset -g DOTFILES_FZF_BASE_OPTS="${FZF_DEFAULT_OPTS-}"
fi
export FZF_DEFAULT_OPTS="${DOTFILES_FZF_BASE_OPTS:+$DOTFILES_FZF_BASE_OPTS }--color=fg:#F2F2F2,bg:#000000,hl:#0000B2,fg+:#F2F2F2,bg+:#414141,hl+:#00A6B2,info:#00A6B2,prompt:#0000B2,pointer:#990000,marker:#00A600,spinner:#999900,header:#666666,border:#666666"
