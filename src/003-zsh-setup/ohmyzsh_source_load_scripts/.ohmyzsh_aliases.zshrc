echo "Running $(basename "$0")"

# # set -o ignoreeof
# if [[ "$OSTYPE" == "linux-gnu"* ]]; then
#         echo "setting for ubuntu. no aliases"
# else
#   alias vi='/Applications/MacVim.app/Contents/MacOS/Vim '
#   alias sshsynology='ssh ${NAS_USERNAME}@${NAS_SERVER_IP} -p ${SSH_NAS_PORT} -i ${SSH_KEY_PATH}'
#   alias vim='/Applications/MacVim.app/Contents/MacOS/Vim '
#   alias rm='trash -F'
#   alias xfirefox='docker run -it \
#     --memory 2gb \
#     --security-opt seccomp=unconfined `#optional` \
#     -e PUID=1000 \
#     -e PGID=1000 \
#     -e TZ=Etc/UTC \
#     -p 3000:3000 \
#     -v ${HOME}/.config/firefox-config:/config \
#     --shm-size="1gb" \
#     --restart unless-stopped \
#     -e DISPLAY="${CUSTOM_DISPLAY}" \
#     lscr.io/linuxserver/firefox:latest'
#     alias xwebtop='docker run -it \
#         --name=webtop \
#         -e TZ=Etc/UTC \
#         -e TITLE=Webtop `#optional` \
#         --memory 2gb \
#         --security-opt seccomp=unconfined `#optional` \
#         -e PUID=1000 \
#         -e PGID=1000 \
#         -e TZ=Etc/UTC \
#         -p 3001:3001 \
#         -e TITLE=Webtop `#optional` \
#         -v ${HOME}/.config/firefox-config:/config \
#         --shm-size="1gb" \
#         --restart unless-stopped \
#         -e DISPLAY="${CUSTOM_DISPLAY}" \
#         lscr.io/linuxserver/webtop:latest'

  
# fi

# create a python3 based snake game, use TUI library to create a nice professional interface, create requirements.txt for required modules, in the end create the venv, cd into code directory, swtich to venv and test venv is active, install requirements  and last run the program. This is an ubuntu 24.04 system, hence make sure to switch to venv before running any pip or python commands.


#Set aliases for system usage
alias vi="nvim"
alias vim="nvim"

#SSH related aliases:
ssh_list_recognised_hosts() {
  # Find all config files (main + included)
  find ~/.ssh -type f -name "config*" -exec grep -h '^Host ' {} \; |
    awk '{for(i=2; i<=NF; i++) print $i}' | # Extract all host aliases, one per line
    grep -v '[*?]' |                       # Exclude wildcard hosts (e.g., Host *)
    sort -u                                # Sort uniquely
}

cloudflare-token-set() { export TUNNEL_TOKEN=$(lpass show --password cloudflare.com | awk '{print $NF}') }
cloudflare-run() { cloudflared tunnel run --token `lpass show --password cloudflare.com | awk '{print $NF}'` > /dev/null 2>&1 & }
lpass-login() { lpass login $(gum input --placeholder "Enter your LastPass email ID") }
aider-watch-openrouter() {OPENROUTER_API_KEY= aider --model openrouter/meta-llama/llama-3.2-1b-instruct:free --watch-files .}
aider-edit() { AIDER_EDITOR=nvim }
openrouter_key_export() { export OPENROUTER_API_KEY=$(lpass show --notes  AI_keys | yq  '.AI | to_entries[].value.openrouter[0].key' | grep -v null| sed -e 's/"//g') }
anthropic_key_export() { export ANTHROPIC_API_KEY=$(lpass show --notes  AI_keys | yq  '.AI | to_entries[].value.anthropic[0].key '| grep -v null| sed -e 's/"//g') }
ssh_synnas_shell() {
  if [[ -n "${NAS_SERVER_IP}" && -n "${NAS_USERNAME}" && -n "${SSH_SHELL_PORT}" ]]; then
    sshpass -p "$(lpass show --password '${NAS_SERVER_IP}:5000/#!/home - DSM')" ssh ${NAS_USERNAME}@${NAS_SERVER_IP} -p ${SSH_SHELL_PORT}
  else
    echo "Error: NAS_SERVER_IP, NAS_USERNAME, and SSH_SHELL_PORT must be set in environment"
    return 1
  fi
}

# Key aliases for AI usage
#======OLLAMA=====================================================================
# ollama_url="${OLLAMA_URL}"
 ollama_code_model="ollama/deepseek-coder-v2"
# alias aider-chat="pipx run aider-chat --edit-format whole"
# alias aider-chat="OLLAMA_IP=\"$ollama_url\" aider --model $ollama_code_model --browser ."
# alias aider-watch="OLLAMA_IP=\"$ollama_url\" aider --model $ollama_code_model --watch-files ."
# alias aider-chat="OLLAMA_IP=\"$ollama_url\" aider --model $ollama_code_model ."


#======OPENROUTER=====================================================================
babaji_aider_watch_with_OPENROUTER_API_KEY() {
  export OPENROUTER_API_KEY=$(lpass show --notes AI_keys | yq '.AI | to_entries[].value.openrouter[0].key' | grep -v null | sed -e 's/"//g')
  aider --model openrouter/meta-llama/llama-3.1-405b-instruct:free --watch-files .
}

babaji_aider_watch_prompt_with_OPENROUTER_API_KEY() {
  if [[ ! -f prompt.txt ]]; then
    echo "Error: prompt.txt not found."
    return 1
  fi
  export OPENROUTER_API_KEY=$(lpass show --notes AI_keys | yq '.AI | to_entries[].value.openrouter[0].key' | grep -v null | sed -e 's/"//g')
  local test_cmd=$(grep 'test_cmd:' prompt.txt | cut -d'"' -f2)
  local watch_patterns=$(grep 'watch_patterns:' prompt.txt | cut -d'[' -f2 | cut -d']' -f1 | tr -d ' ')
  if [[ -z "$test_cmd" || -z "$watch_patterns" ]]; then
    echo "Error: Missing test_cmd or watch_patterns in prompt.txt."
    return 1
  fi
  aider --auto-test --test-cmd "$test_cmd" --message-file prompt.txt --model openrouter/deepseek/deepseek-chat-v3-0324:free --watch-files "$watch_patterns"
}


alias babaji_export_OPENROUTER_API_KEY="export OPENROUTER_API_KEY=$(lpass show --notes  AI_keys | yq  '.AI | to_entries[].value.openrouter[0].key' | grep -v null| sed -e 's/"//g')"
#======GEMINI=====================================================================
babaji_aider_watch_with_GEMINI_API_KEY() {
  export GEMINI_API_KEY=$(lpass show --notes AI_keys | yq '.AI | to_entries[].value.Gemini[0].key' | grep -v null | sed -e 's/"//g')
  aider --model gemini-exp  --watch-files .
}

alias babaji_export_GEMINI_API_KEY="export GEMINI_API_KEY=$(lpass show --notes  AI_keys | yq  '.AI | to_entries[].value.Gemini[0].key' | grep -v null| sed -e 's/"//g')"

# create alias as a help manual that shows all exported and aliased keys from this file, with short documentation to use, and also lets users search for and run one of the aliases or exports in this file
babaji() {
  echo 'This is a help manual for all exported and aliased keys from this file.'
  echo 'You can search for and run one of the aliases or exports in this file.'
  grep -E '^alias|^export|^\w+\(\)\s*\{' ~/.zshrc | sed -e 's/alias //g' -e 's/export //g' -e 's/() {$//' | awk '{print $1}'
}

#  ANTHROPIC_API_KEY=$(lpass show --notes  AI_keys | yq  '.AI | to_entries[].value.Gemini[0].key' | grep -v null| sed -e 's/"//g') aider --model gemini/gemini-1.5-pro-latest --watch-files .

# OLLAMA_IP="${ollama_url}" aider --model ollama/deepseek-coder-v2 --watch-files .

# CODESTRAL_API_KEY=$(lpass show --notes  AI_keys | yq  '.AI | to_entries[].value.mistral[0].key' | grep -v null| sed -e 's/"//g') aider --model codestral/codestral-latest  --watch-files .
alias sshsynology='ssh ${NAS_USERNAME}@${NAS_SERVER_IP} -p ${SSH_NAS_PORT} -i ${SSH_KEY_PATH}'
alias rm='trash -F'
alias xfirefox='docker run -it \
--memory 2gb \
--security-opt seccomp=unconfined `#optional` \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=Etc/UTC \
-p 3000:3000 \
-v ${HOME}/.config/firefox-config:/config \
--shm-size="1gb" \
--restart unless-stopped \
-e DISPLAY="${CUSTOM_DISPLAY}" \
lscr.io/linuxserver/firefox:latest'
alias xwebtop='docker run -it \
--name=webtop \
-e TZ=Etc/UTC \
-e TITLE=Webtop `#optional` \
--memory 2gb \
--security-opt seccomp=unconfined `#optional` \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=Etc/UTC \
-p 3001:3001 \
-e TITLE=Webtop `#optional` \
-v ${HOME}/.config/firefox-config:/config \
--shm-size="1gb" \
--restart unless-stopped \
-e DISPLAY="${CUSTOM_DISPLAY}" \
lscr.io/linuxserver/webtop:latest'