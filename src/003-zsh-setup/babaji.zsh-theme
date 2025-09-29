# Babaji theme for oh-my-zsh
# A combination of agnoster and robbyrussell themes with some custom elements

# Get the current user and hostname
local user='%{$fg[cyan]%}%n%{$reset_color%}'
local host='%{$fg[blue]%}@%m%{$reset_color%}'
local pwd='%{$fg[yellow]%}%~%{$reset_color%}'

# Git info
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%})"

# Get the git info
git_prompt() {
  local git_status="$(git_prompt_info)"
  if [[ -n $git_status ]]; then
    echo "$git_status"
  fi
}

# Get the current time
current_time() {
  echo "%{$fg[magenta]%}%*%{$reset_color%}"
}

# Determine if we're running as root
prompt_char() {
  if [[ $UID -eq 0 ]]; then
    echo "%{$fg[red]%}#%{$reset_color%}"
  else
    echo "%{$fg[green]%}$%{$reset_color%}"
  fi
}

# Determine if we're in a container
in_container() {
  if [ -f /.dockerenv ]; then
    echo " %{$fg[blue]%}[🐳]%{$reset_color%}"
  fi
}

# Build the prompt
PROMPT='${user}${host}${in_container} ${pwd} $(git_prompt)
$(prompt_char) '

RPROMPT='$(current_time)'
