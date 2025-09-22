#!/bin/zsh
# Feature Update Prompt Extension for Shellinator DevContainers
# Displays available feature updates in the zsh prompt

# Path to the feature update checker script
FEATURE_UPDATE_CHECKER="/usr/local/lib/babaji-config/modules/feature-update-checker.sh"

# Function to get feature update status for prompt
get_feature_updates_prompt() {
    # Only run in DevContainer environment
    if [[ "$DEVPOD" == "true" || "$REMOTE_CONTAINERS" == "true" ]]; then
        # Check if the update checker script exists
        if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
            # Run the checker in prompt mode (quick, uses cache)
            local update_status=$("$FEATURE_UPDATE_CHECKER" prompt 2>/dev/null)

            # Return the update status if any updates are available
            if [[ -n "$update_status" ]]; then
                echo " $update_status"
            fi
        fi
    fi
}

# Function to manually check for updates
check_updates() {
    if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
        "$FEATURE_UPDATE_CHECKER" status
    else
        echo "Feature update checker not available"
    fi
}

# Function to force update check
force_update_check() {
    if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
        echo "🔄 Checking for feature updates..."
        "$FEATURE_UPDATE_CHECKER" force
    else
        echo "Feature update checker not available"
    fi
}

# Aliases for convenience
alias check-updates='check_updates'
alias force-check='force_update_check'

# Add to PowerLevel10k if available
if [[ -n "$POWERLEVEL9K_VERSION" ]]; then
    # Define custom PowerLevel10k segment
    function prompt_feature_updates() {
        local update_info=$(get_feature_updates_prompt)
        if [[ -n "$update_info" ]]; then
            p10k segment -f 214 -t "$update_info"
        fi
    }

    # Register the segment
    typeset -g POWERLEVEL9K_FEATURE_UPDATES_SHOW_ON_COMMAND='check-updates|force-check|babaji-config'
fi

# For other themes, provide a function that can be called in PROMPT
function feature_updates_prompt_info() {
    get_feature_updates_prompt
}

# Auto-check on container startup (once per session)
if [[ -z "$FEATURE_UPDATES_CHECKED" ]]; then
    export FEATURE_UPDATES_CHECKED=1

    # Run initial check in background after a short delay
    (
        sleep 5
        if [[ -f "$FEATURE_UPDATE_CHECKER" ]]; then
            "$FEATURE_UPDATE_CHECKER" force >/dev/null 2>&1
        fi
    ) &
fi