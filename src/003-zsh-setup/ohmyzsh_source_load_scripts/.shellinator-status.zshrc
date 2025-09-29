#!/bin/zsh
# Shellinator Status Display for RPROMPT
# Shows current shellinator branch/source and integrates with feature updates

# Path to the feature update checker script
FEATURE_UPDATE_CHECKER="/usr/local/lib/babaji-config/modules/feature-update-checker.sh"

# Get shellinator branch/source info
get_shellinator_branch() {
    # Check if we're in a known git repo structure
    local git_remote=""
    local branch_name=""

    # Try to detect from common locations
    if [[ -d "/workspaces/shellinator/.git" ]]; then
        # In workspace - check git info
        cd "/workspaces/shellinator" 2>/dev/null && {
            git_remote=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com/||' | sed 's|\.git$||')
            branch_name=$(git branch --show-current 2>/dev/null)
            cd - >/dev/null
        }
    elif [[ -f "/.devcontainer/devcontainer.json" ]]; then
        # Try to extract from devcontainer.json if it has source info
        local container_name=$(jq -r '.name // empty' /.devcontainer/devcontainer.json 2>/dev/null)
        if [[ -n "$container_name" ]]; then
            case "$container_name" in
                *"GitHub"*) git_remote="nikunh/shellinator"; branch_name="master" ;;
                *"Local"*) git_remote="local"; branch_name="dev" ;;
                *) git_remote="custom"; branch_name="unknown" ;;
            esac
        fi
    fi

    # Fallback detection
    if [[ -z "$git_remote" ]]; then
        if [[ -d "/workspaces" ]]; then
            git_remote="devcontainer"
            branch_name="workspace"
        else
            git_remote="local"
            branch_name="custom"
        fi
    fi

    # Always show branch name (this replaces the personality system)
    if [[ -n "$branch_name" ]]; then
        echo "$branch_name"
    else
        echo "unknown"
    fi
}

# Get feature update status for prompt
get_feature_updates_prompt() {
    # Only run in DevContainer environment
    if [[ "$DEVPOD" == "true" || "$REMOTE_CONTAINERS" == "true" ]]; then
        # Check if the update checker script exists
        if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
            # Run the checker in prompt mode (quick, uses cache)
            local update_status=$("$FEATURE_UPDATE_CHECKER" prompt 2>/dev/null)

            # Return the update status
            if [[ -n "$update_status" ]]; then
                echo "$update_status"
            fi
        fi
    fi
}

# Generate complete RPROMPT content
shellinator_rprompt() {
    local parts=()

    # Get shellinator branch/source
    local shellinator_info=$(get_shellinator_branch)
    if [[ -n "$shellinator_info" ]]; then
        parts+=("%F{cyan}${shellinator_info}%f")
    fi

    # Get feature updates
    local feature_status=$(get_feature_updates_prompt)
    if [[ -n "$feature_status" ]]; then
        parts+=("${feature_status}")
    fi

    # Join parts with space
    local IFS=" "
    echo "${parts[*]}"
}

# Store original RPROMPT if not already stored
if [[ -z "$ORIGINAL_RPROMPT_SAVED" ]]; then
    export ORIGINAL_RPROMPT="$RPROMPT"
    export ORIGINAL_RPROMPT_SAVED=1
fi

# Universal prompt integration
function __shellinator_status_precmd() {
    # Always start with the original RPROMPT
    RPROMPT="$ORIGINAL_RPROMPT"

    # Get shellinator status
    local shellinator_content=$(shellinator_rprompt)

    # Add to RPROMPT if available
    if [[ -n "$shellinator_content" ]]; then
        if [[ -n "$RPROMPT" ]]; then
            RPROMPT="${shellinator_content} ${RPROMPT}"
        else
            RPROMPT="${shellinator_content}"
        fi
    fi
}

# Hook into precmd for automatic prompt updates
# DISABLED: This functionality is now integrated into PowerLevel10k prompt_bluegreen() function
# if [[ -z "${precmd_functions[(r)__shellinator_status_precmd]}" ]]; then
#     precmd_functions+=(__shellinator_status_precmd)
# fi

# Auto-check on container startup (once per session)
if [[ -z "$SHELLINATOR_STATUS_CHECKED" ]]; then
    export SHELLINATOR_STATUS_CHECKED=1

    # Run initial check in background after a short delay
    (
        sleep 5
        if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
            "$FEATURE_UPDATE_CHECKER" force >/dev/null 2>&1
        fi
    ) &
fi

# Aliases for convenience (moved from feature-updates.zshrc)
check_updates() {
    if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
        "$FEATURE_UPDATE_CHECKER" status
    else
        echo "Feature update checker not available"
    fi
}

force_update_check() {
    if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
        echo "🔄 Checking for feature updates..."
        "$FEATURE_UPDATE_CHECKER" force
    else
        echo "Feature update checker not available"
    fi
}

list_features() {
    if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
        "$FEATURE_UPDATE_CHECKER" list
    else
        echo "Feature update checker not available"
    fi
}

alias check-updates='check_updates'
alias force-check='force_update_check'
alias list-features='list_features'