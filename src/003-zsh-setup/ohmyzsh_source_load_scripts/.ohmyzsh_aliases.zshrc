echo "Running $(basename "$0")"

# Generic system aliases - safe for public use
alias vi="nvim"
alias vim="nvim"

# Generic SSH helper function (no private IPs)
ssh_list_recognised_hosts() {
  # Find all config files (main + included)
  find ~/.ssh -type f -name "config*" -exec grep -h '^Host ' {} \; |
    awk '{for(i=2; i<=NF; i++) print $i}' | # Extract all host aliases, one per line
    grep -v '[*?]' |                       # Exclude wildcard hosts (e.g., Host *)
    sort -u                                # Sort uniquely
}

# Generic development aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Docker aliases (generic)
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias dlog='docker logs'
alias dexec='docker exec -it'

# Development helpers
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias reload='source ~/.zshrc'

# Generic helper function
help_aliases() {
  echo "Available aliases in this environment:"
  echo "====================================="
  echo ""
  echo "Editor:"
  echo "  vi, vim       - Launch neovim"
  echo ""
  echo "Git shortcuts:"
  echo "  gs, ga, gc, gp, gl, gd - Common git commands"
  echo ""
  echo "Docker shortcuts:"
  echo "  dps, dpsa, dimg, dlog, dexec - Common docker commands"
  echo ""
  echo "System helpers:"
  echo "  ll, la, l     - Directory listings"
  echo "  ports         - Show network ports"
  echo "  myip          - Show external IP"
  echo "  reload        - Reload shell configuration"
  echo ""
  echo "Functions:"
  echo "  ssh_list_recognised_hosts - List SSH hosts from config"
  echo "  help_aliases              - Show this help"
}

# Note: Personal aliases and credentials have been moved to a private feature
# They can be dynamically loaded when connected to private infrastructure