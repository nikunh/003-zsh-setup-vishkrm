# ----------------------
# Tmux-Neovim-Git Configuration
# ----------------------
alias vi="nvim"
alias vim="nvim"
export OLLAMA_API_BASE=$ollama_url

# Aider chat alias
alias aider-chat='aider --chat-language en'

# Direnv hook
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# SSH Agent setup
if [ -x "$(command -v ssh)" ]; then
  eval $(ssh-agent -s)
fi
