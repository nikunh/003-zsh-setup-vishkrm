echo "Running $(basename "$0")"

shellinator() { docker run -it \
-v $(pwd| awk -F 'Terrarun/' '{print $1}')/:/root/repos/ \
-h "$(whoami)" \
-v $HOME/.tmux:/root/.tmux \
-v $HOME/.tmux.conf:/root/.tmux.conf \
-v $HOME/.ssh:/root/.ssh \
-v $HOME/.aws:/root/.aws \
-v $HOME/.zshrc:/root/.zshrc \
-v $HOME/.yankring_history_v2.txt:/root/.yankring_history_v2.txt \
-v $HOME/.vimrc:/root/.vimrc \
-v $HOME/.vim:/root/.vim \
-v $HOME/.direnvrc:/root/.direnvrc \
-v $HOME/.zsh_history:/root/.zsh_history \
-v $HOME/.ohmyzsh_source_load_scripts:/root/.ohmyzsh_source_load_scripts \
shellinator  /bin/zsh }

keybase-docker() {
  if [[ -n "${KEYBASE_USERNAME}" && -n "${KEYBASE_PAPERKEY}" ]]; then
    docker run --rm \
      -e KEYBASE_USERNAME="${KEYBASE_USERNAME}" \
      -e KEYBASE_PAPERKEY="${KEYBASE_PAPERKEY}" \
      -e KEYBASE_SERVICE="1" \
      keybaseio/client
  else
    echo "Error: KEYBASE_USERNAME and KEYBASE_PAPERKEY must be set in environment"
    return 1
  fi
}



code-server-run() {\
  docker run -d \
  --name code-server \
  -p 7070:8080 \
  -v ${CODE_SERVER_VOLUME}:/home/coder/project \
  -v /volume1/1821_backups/backups/kbfs/ssh_files/others/synnas1821/code-server/code_server_id_ed25519:/root/.ssh/code_server_id_ed25519:rw \
  -v /volume1/1821_backups/backups/kbfs/ssh_files/others/synnas1821/code-server/code_server_id_ed25519.pub:/root/.ssh/code_server_id_ed25519.pub:rw \
  -v /volume1/1821_backups/backups/kbfs/ssh_files/others/synnas1821/code-server/config:/root/.ssh/config:rw \
  -v /volume1/docker/code-server-nikun/code-server-nikun-dotfiles:/root/.dotfiles:rw \
  -v /volume1/docker/code-server-nikun/code-server-nikun-dotfiles/.bashrc:/root/.bashrc:rw \
  -e DOCKER_USER=${DOCKER_USER} \
  -e PASSWORD=${CODE_SERVER_PASSWORD} \
  -e DOTFILES_INSTALL=1 \
  --restart unless-stopped \
  --user "${UID}:${GID}" \
  --tty \
  --interactive \
  bencdr/code-server-deploy-container:latest
}