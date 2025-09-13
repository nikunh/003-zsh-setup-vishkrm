#!/bin/zsh
# Blue-Green Deployment Status Fragment for Powerlevel10k/Oh-My-Zsh
# Provides custom segment for P10k and fallback for other themes
# Part of Shellinator-Reloaded Fragment System

# Security check - only run in DevContainer environment
if [[ ! -d /coordination ]]; then
    # Not in blue-green environment - self-cleanup
    rm -f "$HOME/.ohmyzsh_source_load_scripts/.bluegreen-status.zshrc" 2>/dev/null
    return 0
fi

# ============================================================================
# BLUE-GREEN STATUS FUNCTIONS
# ============================================================================

# Read coordination files for blue-green status
_bluegreen_read_coordination() {
    local coord_dir="/coordination"
    local key="$1"
    
    [[ -f "$coord_dir/$key" ]] && cat "$coord_dir/$key" 2>/dev/null || echo ""
}

# Get current container's blue-green status
_bluegreen_get_status() {
    local coord_dir="/coordination"
    [[ -d "$coord_dir" ]] || return 1
    
    local current_version="${DEVCONTAINER_VERSION:-v1}"
    local container_id=$(hostname | cut -c1-8)
    local active_version=$(_bluegreen_read_coordination "current-active-version")
    [[ -z "$active_version" ]] && active_version="v1"
    
    local v1_status=$(_bluegreen_read_coordination "devcontainer-v1-status")
    [[ -z "$v1_status" ]] && v1_status="active"
    
    local v2_status=$(_bluegreen_read_coordination "devcontainer-v2-status") 
    local build_progress=$(_bluegreen_read_coordination "v2-build-progress")
    local switch_request=$(_bluegreen_read_coordination "switch-request")
    
    local status_parts=()
    
    # Current container status (always show what I am)
    if [[ "$current_version" == "$active_version" ]]; then
        status_parts+=("%F{blue}🔵 v1%f")
    else
        status_parts+=("%F{green}🟢 v2%f") 
    fi
    
    # V2 status (only show when relevant)
    case "$v2_status" in
        "building")
            if [[ -n "$build_progress" ]]; then
                status_parts+=("%F{yellow}🟡 v2:${build_progress}%%f")
            else
                status_parts+=("%F{yellow}🟡 v2:building%f")
            fi
            ;;
        "ready")
            status_parts+=("%F{green}🟢 v2:ready%f")
            ;;
        "failed")
            status_parts+=("%F{red}🔴 v2:failed%f")
            ;;
        "")
            # No V2 activity - don't show anything extra
            ;;
    esac
    
    # Switch status (if switching)
    if [[ -n "$switch_request" ]]; then
        status_parts+=("%F{cyan}🔄 ${switch_request}%f")
    fi
    
    # Join with spaces
    local IFS=" "
    echo "${status_parts[*]}"
}

# Get extended deployment information (optional)
_bluegreen_get_extended() {
    local coord_dir="/coordination"
    local ext_parts=()
    
    # Health score
    local health_file="$coord_dir/health-score"
    if [[ -f "$health_file" ]]; then
        local health_score=$(cat "$health_file" 2>/dev/null)
        [[ -n "$health_score" ]] && ext_parts+=("💚 ${health_score}%")
    fi
    
    # Feature count from fragment system
    if [[ -d "$HOME/.ohmyzsh_source_load_scripts" ]]; then
        local feature_count=$(ls "$HOME/.ohmyzsh_source_load_scripts" 2>/dev/null | wc -l)
        [[ "$feature_count" -gt 0 ]] && ext_parts+=("📦 ${feature_count}")
    fi
    
    # Deployment timestamp
    local deploy_time_file="$coord_dir/deployment-time"
    if [[ -f "$deploy_time_file" ]]; then
        local deploy_time=$(cat "$deploy_time_file" 2>/dev/null)
        if [[ -n "$deploy_time" && "$deploy_time" =~ ^[0-9]+$ ]]; then
            local current_time=$(date +%s)
            local age_hours=$(( (current_time - deploy_time) / 3600 ))
            if [[ "$age_hours" -lt 24 ]]; then
                ext_parts+=("⏰ ${age_hours}h")
            fi
        fi
    fi
    
    # Git status (if in git repo)
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        local commit=$(git rev-parse --short HEAD 2>/dev/null)
        if [[ -n "$branch" && -n "$commit" ]]; then
            ext_parts+=("📝 ${branch}:${commit}")
        fi
    fi
    
    # Join with spaces
    local IFS=" "
    echo "${ext_parts[*]}"
}

# ============================================================================
# RPROMPT INTEGRATION (NON-INTRUSIVE)
# ============================================================================

# Main function to generate blue-green RPROMPT content
bluegreen_rprompt() {
    local bg_status=$(_bluegreen_get_status 2>/dev/null)
    [[ -z "$bg_status" ]] && return
    
    # Configuration (can be overridden by user)
    local show_extended="${BLUEGREEN_SHOW_EXTENDED:-false}"
    local show_time="${BLUEGREEN_SHOW_TIME:-true}"
    
    local result="$bg_status"
    
    # Add extended info if enabled
    if [[ "$show_extended" == "true" ]]; then
        local extended=$(_bluegreen_get_extended 2>/dev/null)
        [[ -n "$extended" ]] && result="$result $extended"
    fi
    
    # Add timestamp if enabled
    if [[ "$show_time" == "true" ]]; then
        result="$result %F{244}%D{%H:%M:%S}%f"
    fi
    
    echo "$result"
}

# ============================================================================
# SAFE RPROMPT EXTENSION (PRESERVES EXISTING)
# ============================================================================

# Function to safely extend existing RPROMPT
_bluegreen_extend_rprompt() {
    local bg_content=$(bluegreen_rprompt)
    [[ -z "$bg_content" ]] && return
    
    # Check if RPROMPT already has content
    local existing_rprompt="$RPROMPT"
    
    if [[ -n "$existing_rprompt" ]]; then
        # Prepend blue-green to existing RPROMPT
        echo "$bg_content $existing_rprompt"
    else
        # Create new RPROMPT with just blue-green content
        echo "$bg_content"
    fi
}

# ============================================================================
# INITIALIZATION
# ============================================================================

# Only initialize if not already done (prevent double-loading)
if [[ -z "$_BLUEGREEN_STATUS_LOADED" ]]; then
    export _BLUEGREEN_STATUS_LOADED=1
    
    # Configuration options (user can override)
    export BLUEGREEN_SHOW_EXTENDED="${BLUEGREEN_SHOW_EXTENDED:-false}"
    export BLUEGREEN_SHOW_TIME="${BLUEGREEN_SHOW_TIME:-true}"
    export BLUEGREEN_UPDATE_INTERVAL="${BLUEGREEN_UPDATE_INTERVAL:-30}"
    
    # Try Powerlevel10k integration first
    if [[ "$ZSH_THEME" == *"powerlevel10k"* ]] || [[ -f ~/.p10k.zsh ]]; then
        # Powerlevel10k custom segment for blue-green status
        function prompt_bluegreen() {
            [[ -d /coordination ]] || return
            
            local version="${DEVCONTAINER_VERSION:-v1}"
            local status=$(cat /coordination/devcontainer-${version}-status 2>/dev/null || echo "unknown")
            local icon
            
            case $status in
                active) icon="🔵" ;;
                standby) icon="🟡" ;;
                building) icon="🟢" ;;
                *) icon="⚫" ;;
            esac
            
            # Use p10k segment API
            p10k segment -f blue -i "$icon" -t "$version"
        }
        
        # Add segment to P10k (will be activated in .p10k.zsh)
        echo "🔵🟢 Blue-Green status loaded (Powerlevel10k integration)" >&2
        
    # Try Spaceship theme integration
    elif [[ -n "$SPACESHIP_VERSION" ]] || [[ "$ZSH_THEME" == *"spaceship"* ]]; then
        # Spaceship custom section for blue-green status
        spaceship_bluegreen() {
            [[ -d /coordination ]] || return
            
            local bg_status=$(_bluegreen_get_status 2>/dev/null)
            [[ -z "$bg_status" ]] && return
            
            echo "$bg_status"
        }
        
        # Add to Spaceship right prompt order
        if [[ -v SPACESHIP_RPROMPT_ORDER ]]; then
            SPACESHIP_RPROMPT_ORDER+=(bluegreen)
        else
            SPACESHIP_RPROMPT_ORDER=(bluegreen)
        fi
        
        echo "🔵🟢 Blue-Green status loaded (Spaceship integration)" >&2
        
    # Fallback: Register with Shellinator Prompt Plugin if available, else direct RPROMPT
    else
        # Check if Shellinator Prompt Plugin is available
        if type shellinator_register_fragment &>/dev/null; then
            # Register with Shellinator Prompt Plugin
            _bluegreen_register_with_shellinator() {
                local bg_content=$(bluegreen_rprompt)
                if [[ -n "$bg_content" ]]; then
                    shellinator_register_fragment "bluegreen" "$bg_content" "right"
                fi
            }
            
            # Update registration before each command
            if ! [[ " ${precmd_functions[*]} " =~ " _bluegreen_register_with_shellinator " ]]; then
                precmd_functions+=(_bluegreen_register_with_shellinator)
            fi
            
            echo "🔵🟢 Blue-Green status loaded (Shellinator Plugin integration)" >&2
            
        else
            # Fallback to direct RPROMPT for themes without Shellinator Plugin
            RPROMPT='$(bluegreen_rprompt)'
            
            # Update prompt before each command
            if ! [[ " ${precmd_functions[*]} " =~ " _bluegreen_precmd " ]]; then
                _bluegreen_precmd() {
                    RPROMPT='$(bluegreen_rprompt)'
                }
                precmd_functions+=(_bluegreen_precmd)
            fi
            
            echo "🔵🟢 Blue-Green status loaded (Direct RPROMPT mode)" >&2
        fi
    fi
fi

# ============================================================================
# USER CONFIGURATION INTERFACE
# ============================================================================

# User-friendly commands to control blue-green display
alias bluegreen-show='export BLUEGREEN_SHOW_EXTENDED=true && zle && zle reset-prompt'
alias bluegreen-hide='export BLUEGREEN_SHOW_EXTENDED=false && zle && zle reset-prompt'
alias bluegreen-time-on='export BLUEGREEN_SHOW_TIME=true && zle && zle reset-prompt'
alias bluegreen-time-off='export BLUEGREEN_SHOW_TIME=false && zle && zle reset-prompt'
alias bluegreen-status='echo "Extended: $BLUEGREEN_SHOW_EXTENDED, Time: $BLUEGREEN_SHOW_TIME, Update: ${BLUEGREEN_UPDATE_INTERVAL}s"'