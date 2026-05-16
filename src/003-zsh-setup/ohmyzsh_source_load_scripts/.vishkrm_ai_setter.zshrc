ai_env_setup() {
  # Requires: gum, lpass, yq, sed

  # Stage 1: Provider selection
  local provider
  provider=$(gum choose "ollama" "openrouter" "gemini" --header "Select AI Provider") || return

  # Stage 2: API Key retrieval (if needed)
  local api_key=""
  if [[ "$provider" != "ollama" ]]; then
    api_key=$(PROVIDER=$provider lpass show --notes AI_keys | \
      yq '.AI | to_entries[].value[env(PROVIDER)][0].key' | \
      grep -v null | sed -e 's/"//g')
    if [[ -z "$api_key" ]]; then
      gum style --foreground 1 "Error: No API key found for $provider!"
      return 1
    fi
  fi

  # Stage 3: Model selection
  local model
  if [[ "$provider" == "ollama" ]]; then
    model=$(gum choose \
      "qwen2.5-coder" \
      "llama3:latest" \
      "deepseek-coder" \
      --header "Select Local Ollama Model") || return
  elif [[ "$provider" == "openrouter" ]]; then
    model=$(gum choose \
      "google/gemini-2.5-pro:free" \
      "meta-llama/llama-3-70b-instruct:free" \
      "deepseek/deepseek-chat-v3-0324:free" \
      "qwen/qwen2-5-coder:free" \
      "microsoft/phi-4:free" \
      "google/codegemma-7b:free" \
      "google/gemma-2-9b:free" \
      "ollama/llama3:free" \
      --header "Select Free OpenRouter Model") || return
  elif [[ "$provider" == "gemini" ]]; then
    model=$(gum choose \
      "gemini-2.5-pro-exp-03-25" \
      "gemini-2.5-flash-exp-03-25" \
      "gemini-code-assist" \
      --header "Select Free Gemini Model") || return
  fi

  # Stage 4: Export variables for use in shell and plugins
  if [[ "$provider" == "ollama" ]]; then
    export OLLAMA_MODEL="$model"
    gum style --foreground 2 "OLLAMA_MODEL exported as $model"
  elif [[ "$provider" == "openrouter" ]]; then
    export OPENROUTER_API_KEY="$api_key"
    export OPENROUTER_MODEL="$model"
    gum style --foreground 2 "OPENROUTER_API_KEY and OPENROUTER_MODEL exported"
  elif [[ "$provider" == "gemini" ]]; then
    export GEMINI_API_KEY="$api_key"
    export GEMINI_MODEL="$model"
    gum style --foreground 2 "GEMINI_API_KEY and GEMINI_MODEL exported"
  fi

  # Show summary for user
  gum style --border double --margin "1 2" --padding "1 2" --foreground 4 "Provider: $provider\nModel: $model\nAPI Key: ${api_key:+(set)}"
}

# Optionally, call the function automatically on shell init:
# ai_env_setup
