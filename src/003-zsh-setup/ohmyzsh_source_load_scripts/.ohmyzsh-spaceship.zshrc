

echo "Running $(basename "$0")"

SPACESHIP_TIME_SHOW=true
SPACESHIP_DIR_SHOW=true
SPACESHIP_DIR_TRUNC=0
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_PROMPT_ADD_NEWLINE=true

SPACESHIP_TIME_FORMAT="%T %D" 
SPACESHIP_KUBECTL_SHOW=true
SPACESHIP_KUBECTL_VERSION_SHOW=true
SPACESHIP_KUBECTL_CONTEXT_SHOW=true
SPACESHIP_KUBECTL_PREFIX='{K8S '
SPACESHIP_KUBECTL_SYMBOL=' ☸️ :'
SPACESHIP_KUBECTL_SUFFIX=' }'
SPACESHIP_KUBECTL_CONTEXT_COLOR_GROUPS=(
  # red if namespace is "kube-system"
  red    '\(kube-system)$'
  # red if namespace is "kube-system"
  red    prd
  red    prod

  # else, green if "dev-01" is anywhere in the context or namespace
  green  dev
  yellow test

  # else, orange if context name ends with ".k8s.local" _and_ namespace is "system"
  orange    '\.k8s\.local \(system)$'


)



SPACESHIP_TERRAFORM_SHOW=true
SPACESHIP_TERRAFORM_PREFIX='{TF '
SPACESHIP_TERRAFORM_SYMBOL=' 🛠️· :'
SPACESHIP_TERRAFORM_SUFFIX=' }'
SPACESHIP_TERRAFORM_COLOR=105

SPACESHIP_AWS_SHOW=true	
SPACESHIP_AWS_COLOR=208

# spaceship add --after dir line_sep
# spaceship add --after git line_sep



if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  SPACESHIP_PROMPT_ORDER=(
    time          # Time stampts section
    user          # Username section
    dir           # Current directory section
    host          # Hostname section
    git           # Git section (git_branch + git_status)
    hg            # Mercurial section (hg_branch  + hg_status)
    # package       # Package version
    node          # Node.js section
    ruby          # Ruby section
    elm           # Elm section
    elixir        # Elixir section
    xcode         # Xcode section
    swift         # Swift section
    golang        # Go section
    php           # PHP section
    rust          # Rust section
    haskell       # Haskell Stack section
    julia         # Julia section
    docker        # Docker section
    aws           # Amazon Web Services section
    venv          # virtualenv section
    conda         # conda virtualenv section
    pyenv         # Pyenv section
    dotnet        # .NET section
    ember         # Ember.js section
    kubectl   # Kubectl context section
    terraform # Terraform context section
    exec_time     # Execution time
    line_sep      # Line break
    battery       # Battery level and status
    vi_mode       # Vi-mode indicator
    jobs          # Background jobs indicator
    exit_code     # Exit code section
    char          # Prompt character
    
  )
else
  SPACESHIP_PROMPT_ORDER=(
      time          # Time stampts section
      user          # Username section
      dir           # Current directory section
      host          # Hostname section
      git           # Git section (git_branch + git_status)
      hg            # Mercurial section (hg_branch  + hg_status)
      package       # Package version
      node          # Node.js section
      ruby          # Ruby section
      elm           # Elm section
      elixir        # Elixir section
      xcode         # Xcode section
      swift         # Swift section
      golang        # Go section
      php           # PHP section
      rust          # Rust section
      haskell       # Haskell Stack section
      julia         # Julia section
      docker        # Docker section
      aws           # Amazon Web Services section
      venv          # virtualenv section
      conda         # conda virtualenv section
      pyenv         # Pyenv section
      dotnet        # .NET section
      ember         # Ember.js section
      kubectl   # Kubectl context section
      terraform # Terraform context section
      exec_time     # Execution time
      line_sep      # Line break
      battery       # Battery level and status
      vi_mode       # Vi-mode indicator
      jobs          # Background jobs indicator
      exit_code     # Exit code section
      char          # Prompt character
    )
fi


