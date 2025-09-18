echo "Running $(basename "$0")"

# Generic Docker development helper
shellinator() {
  docker run -it \
    -v $(pwd):/workspace \
    -h "$(whoami)" \
    -v $HOME/.tmux:/root/.tmux \
    -v $HOME/.tmux.conf:/root/.tmux.conf \
    -v $HOME/.ssh:/root/.ssh \
    -v $HOME/.zshrc:/root/.zshrc \
    -v $HOME/.vimrc:/root/.vimrc \
    -v $HOME/.vim:/root/.vim \
    -v $HOME/.zsh_history:/root/.zsh_history \
    -v $HOME/.ohmyzsh_source_load_scripts:/root/.ohmyzsh_source_load_scripts \
    shellinator /bin/zsh
}

# Generic code-server runner
code-server-run() {
  docker run -d \
    --name code-server \
    -p 8080:8080 \
    -v $(pwd):/home/coder/project \
    -e PASSWORD="${CODE_SERVER_PASSWORD:-changeme}" \
    --restart unless-stopped \
    codercom/code-server:latest
}

# Docker cleanup helpers
docker-cleanup() {
  echo "Cleaning up Docker system..."
  docker system prune -f
  docker volume prune -f
  echo "Cleanup complete!"
}

# Docker stats helper
docker-stats-all() {
  docker stats --no-stream --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
}

# Note: Personal Docker configurations have been moved to a private feature
# They can be dynamically loaded when connected to private infrastructure