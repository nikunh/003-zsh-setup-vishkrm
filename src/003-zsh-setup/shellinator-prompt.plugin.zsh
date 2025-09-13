#!/bin/zsh
# Shellinator Prompt - Oh-My-Zsh Custom Plugin
# Centralized prompt management for fragment contributions
#
# This plugin provides a registration system for fragments to contribute
# prompt elements in a standardized way, following Oh-My-Zsh best practices.

# Plugin identification
# SHELLINATOR_PROMPT_VERSION="1.0.0"

# Global associative array for fragment registration
typeset -gA SHELLINATOR_PROMPT_FRAGMENTS

# Register a fragment for prompt display
# Usage: shellinator_register_fragment "name" "content" ["position"]
shellinator_register_fragment() {
    local fragment_name="$1"
    local content="$2" 
    local position="${3:-right}"
    
    if [[ -z "$fragment_name" || -z "$content" ]]; then
        return 1
    fi
    
    SHELLINATOR_PROMPT_FRAGMENTS["${fragment_name}_content"]=$content
    SHELLINATOR_PROMPT_FRAGMENTS["${fragment_name}_position"]=$position
}

# Unregister a fragment
# Usage: shellinator_unregister_fragment "name"
shellinator_unregister_fragment() {
    local fragment_name="$1"
    unset SHELLINATOR_PROMPT_FRAGMENTS["${fragment_name}_content"]
    unset SHELLINATOR_PROMPT_FRAGMENTS["${fragment_name}_position"]
}

# Format a fragment for display
# Usage: shellinator_format_fragment "name" "content"
shellinator_format_fragment() {
    local fragment_name="$1"
    local content="$2"
    echo "[frag:$fragment_name: $content]"
}

# Build and set the prompt from registered fragments
# This function is called via precmd hook
shellinator_build_prompt() {
    local rprompt_parts=()
    local lprompt_parts=()
    
    # Iterate through all registered fragments
    for key in ${(k)SHELLINATOR_PROMPT_FRAGMENTS}; do
        if [[ $key == *"_content" ]]; then
            local fragment_name=${key%_content}
            local position_key="${fragment_name}_position"
            local position=$SHELLINATOR_PROMPT_FRAGMENTS[$position_key]
            local content=$SHELLINATOR_PROMPT_FRAGMENTS[$key]
            
            # Only add non-empty content
            if [[ -n $content ]]; then
                local formatted=$(shellinator_format_fragment $fragment_name $content)
                
                case $position in
                    "right")
                        rprompt_parts+=($formatted)
                        ;;
                    "left")
                        lprompt_parts+=($formatted)
                        ;;
                esac
            fi
        fi
    done
    
    # Set prompts (space-separated for right, direct for left)
    if [[ ${#rprompt_parts[@]} -gt 0 ]]; then
        RPROMPT=${(j: :)rprompt_parts}
    else
        RPROMPT=""
    fi
    
    # Left prompt additions (if any) - be careful not to override existing prompt
    if [[ ${#lprompt_parts[@]} -gt 0 ]]; then
        # Only add to left if no existing theme is controlling it
        if [[ -z "$PS1_THEME_MANAGED" ]]; then
            PS1="${(j: :)lprompt_parts} $PS1"
        fi
    fi
}

# Clear all registered fragments
# Usage: shellinator_clear_fragments
shellinator_clear_fragments() {
    for key in ${(k)SHELLINATOR_PROMPT_FRAGMENTS}; do
        unset SHELLINATOR_PROMPT_FRAGMENTS[$key]
    done
}

# Debug: List all registered fragments
# Usage: shellinator_list_fragments
shellinator_list_fragments() {
    echo "Registered Shellinator prompt fragments:"
    for key in ${(k)SHELLINATOR_PROMPT_FRAGMENTS}; do
        if [[ $key == *"_content" ]]; then
            local fragment_name=${key%_content}
            local position_key="${fragment_name}_position"
            local position=$SHELLINATOR_PROMPT_FRAGMENTS[$position_key]
            local content=$SHELLINATOR_PROMPT_FRAGMENTS[$key]
            echo "  $fragment_name: '$content' (position: $position)"
        fi
    done
}

# Hook into Oh-My-Zsh precmd system
# This ensures our prompt builder runs before each prompt display
if [[ -z "${precmd_functions[(r)shellinator_build_prompt]}" ]]; then
    precmd_functions+=(shellinator_build_prompt)
fi

# Plugin loaded notification (debug)
# echo "Shellinator Prompt plugin loaded (Oh-My-Zsh compatible)"