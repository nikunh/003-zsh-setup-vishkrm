#!/bin/sh
set -e

# Logging mechanism for debugging
LOG_FILE="/tmp/003-zsh-setup-install.log"
log_debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] $*" >> "$LOG_FILE"
}

# Initialize logging
log_debug "=== 003-ZSH-SETUP INSTALL STARTED ==="
log_debug "Script path: $0"
log_debug "PWD: $(pwd)"
log_debug "Environment: USER=$USER HOME=$HOME"

# This script must be run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
# Token fix test - trigger automation Mon Sep 23 22:10:00 BST 2025
SKEL_DIR="/etc/skel"
ZSH="${SKEL_DIR}/.oh-my-zsh"
USERNAME=${USERNAME:-"babaji"}
USER_HOME="/home/${USERNAME}"

echo "=== ZSH SETUP DEBUG INFO ==="
echo "FEATURE_DIR: $FEATURE_DIR"
echo "SKEL_DIR: $SKEL_DIR"
echo "USERNAME: $USERNAME"
echo "USER_HOME: $USER_HOME"
echo "USER_HOME exists: $([ -d "$USER_HOME" ] && echo 'YES' || echo 'NO')"
echo "=============================="

echo "Setting up Zsh and Oh My Zsh configuration in /etc/skel..."

# Set DEBIAN_FRONTEND to noninteractive to prevent prompts
export DEBIAN_FRONTEND=noninteractive

# 1. Install Zsh and dependencies (including fonts for Powerlevel10k)
apt-get update
apt-get install -y --no-install-recommends zsh git curl wget ca-certificates fontconfig

# 2. Install Nerd Fonts for Powerlevel10k (MesloLGS NF - recommended by P10k)
echo "Installing Nerd Fonts for Powerlevel10k..."
mkdir -p /usr/share/fonts/truetype/meslo
cd /usr/share/fonts/truetype/meslo
# Download the recommended MesloLGS NF fonts
for style in Regular Bold Italic BoldItalic; do
  wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${style}.ttf" || true
done
# Update font cache
fc-cache -f 2>/dev/null || true
cd - > /dev/null

# 3. Clean up existing Oh My Zsh if present to avoid install errors
if [ -d "$ZSH" ]; then
  rm -rf "$ZSH"
fi

# 4. Install Oh My Zsh to /etc/skel
#    This will be automatically copied to new user home directories
export ZSH
mkdir -p ${SKEL_DIR}
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" sh --unattended

# 5. Configure git for non-interactive builds and install plugins
echo "Configuring git for non-interactive environment..."
git config --global user.email "build@devcontainer.local"
git config --global user.name "DevContainer Build"
git config --global init.defaultBranch main
git config --global advice.detachedHead false

ZSH_CUSTOM="${ZSH}/custom"
echo "Installing zsh plugins..."
timeout 300 git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions || echo "zsh-autosuggestions clone failed"
timeout 300 git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting || echo "zsh-syntax-highlighting clone failed"
timeout 300 git clone --depth=1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM}/plugins/zsh-completions || echo "zsh-completions clone failed"

# Install Powerlevel10k theme (comprehensive installation)
echo "Installing Powerlevel10k theme..."
timeout 300 git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k || echo "powerlevel10k clone failed"

# Also install Powerlevel10k for existing user if they exist (to handle both skel and user scenarios)
if [ -d "$USER_HOME/.oh-my-zsh" ]; then
    USER_ZSH_CUSTOM="$USER_HOME/.oh-my-zsh/custom"
    P10K_USER_DIR="$USER_ZSH_CUSTOM/themes/powerlevel10k"
    
    mkdir -p "$USER_ZSH_CUSTOM/themes"
    
    # Remove existing directory if it exists  
    if [ -d "$P10K_USER_DIR" ]; then
        rm -rf "$P10K_USER_DIR"
    fi
    
    echo "Installing Powerlevel10k to existing user directory..."
    timeout 300 git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_USER_DIR" || echo "user powerlevel10k clone failed"
    
    # Fix ownership
    if [ "$USER" != "$USERNAME" ]; then
        chown -R ${USERNAME}:${USERNAME} "$P10K_USER_DIR" 2>/dev/null || chown -R ${USERNAME}:users "$P10K_USER_DIR" 2>/dev/null || true
    fi
fi

# Install Shellinator Prompt Plugin (custom Oh-My-Zsh plugin)
echo "Installing Shellinator Prompt Plugin..."
mkdir -p ${ZSH_CUSTOM}/plugins/shellinator-prompt
cp "${FEATURE_DIR}/shellinator-prompt.plugin.zsh" ${ZSH_CUSTOM}/plugins/shellinator-prompt/
echo "Shellinator Prompt Plugin installed successfully."

# 5. Copy our pre-configured zshrc and theme to /etc/skel (this will overwrite the default oh-my-zsh .zshrc)
echo "Copying custom files to /etc/skel..."
cp "${FEATURE_DIR}/zshrc" "${SKEL_DIR}/.zshrc"
# Copy Powerlevel10k configuration
cp "${FEATURE_DIR}/p10k.zsh" "${SKEL_DIR}/.p10k.zsh"
# Remove destination first to avoid circular copying
rm -rf "${SKEL_DIR}/.ohmyzsh_source_load_scripts"
cp -r "${FEATURE_DIR}/ohmyzsh_source_load_scripts" "${SKEL_DIR}/.ohmyzsh_source_load_scripts"
cp "${FEATURE_DIR}/babaji.zsh-theme" "${ZSH_CUSTOM}/themes/babaji.zsh-theme"

echo "Contents of /etc/skel after setup:"
ls -la "${SKEL_DIR}/"

echo "Zsh and Oh My Zsh configuration installed to /etc/skel successfully."

# 6. If the user already exists, copy the configuration to their home directory
if [ -d "$USER_HOME" ]; then
  echo "User $USERNAME already exists, copying zsh configuration to $USER_HOME..."
  
  echo "Before cleanup - USER_HOME contents:"
  ls -la "$USER_HOME/" | grep -E "\.(zshrc|oh-my-zsh)" || echo "No zsh files found"
  
  # Remove any existing oh-my-zsh and zshrc to avoid conflicts
  rm -rf "$USER_HOME/.oh-my-zsh" "$USER_HOME/.zshrc" "$USER_HOME/.ohmyzsh_source_load_scripts"
  
  echo "After cleanup - removed old files"
  
  # Copy oh-my-zsh (ensure target doesn't exist first)
  rm -rf "$USER_HOME/.oh-my-zsh"
  cp -r "${SKEL_DIR}/.oh-my-zsh" "$USER_HOME/"
  echo "Copied .oh-my-zsh"
  
  # Copy zshrc and source scripts (our custom versions)
  cp "${SKEL_DIR}/.zshrc" "$USER_HOME/"
  echo "Copied .zshrc"
  
  # Copy PowerLevel10k configuration
  cp "${SKEL_DIR}/.p10k.zsh" "$USER_HOME/"
  echo "Copied .p10k.zsh"
  
  # Copy source scripts (ensure target doesn't exist first)
  rm -rf "$USER_HOME/.ohmyzsh_source_load_scripts"
  cp -r "${SKEL_DIR}/.ohmyzsh_source_load_scripts" "$USER_HOME/"
  echo "Copied .ohmyzsh_source_load_scripts"
  
  # Fix ownership - ensure the user group exists
  if ! getent group ${USERNAME} > /dev/null 2>&1; then
    echo "User group ${USERNAME} not found, using 'users' group"
    chown -R ${USERNAME}:users "$USER_HOME/.oh-my-zsh" "$USER_HOME/.zshrc" "$USER_HOME/.p10k.zsh" "$USER_HOME/.ohmyzsh_source_load_scripts"
  else
    chown -R ${USERNAME}:${USERNAME} "$USER_HOME/.oh-my-zsh" "$USER_HOME/.zshrc" "$USER_HOME/.p10k.zsh" "$USER_HOME/.ohmyzsh_source_load_scripts"
  fi
  echo "Fixed ownership"
  
  # Set proper permissions
  chmod 644 "$USER_HOME/.zshrc"
  chmod 644 "$USER_HOME/.p10k.zsh"
  chmod -R 755 "$USER_HOME/.oh-my-zsh"
  # Only chmod .zshrc files if they exist
  if ls "$USER_HOME/.ohmyzsh_source_load_scripts"/*.zshrc 1> /dev/null 2>&1; then
    chmod -R 644 "$USER_HOME/.ohmyzsh_source_load_scripts"/*.zshrc
  fi
  echo "Set permissions"
  
  echo "After copy - USER_HOME contents:"
  ls -la "$USER_HOME/" | grep -E "\.(zshrc|oh-my-zsh|ohmyzsh)" || echo "No zsh files found"
  
  echo "Zsh configuration copied to existing user $USERNAME successfully."
else
  echo "User directory $USER_HOME does not exist - files will be copied when user is created"
fi

# 7. Create the core environment cleanup fragment using symlink approach
echo "Creating core environment cleanup fragment..."

# Create authoritative fragment in image
FRAGMENT_SOURCE_DIR="/etc/skel/.devcontainer-fragments"
mkdir -p "$FRAGMENT_SOURCE_DIR"

CLEANUP_FRAGMENT_SOURCE="$FRAGMENT_SOURCE_DIR/.00-cleanup.zshrc"
cat > "$CLEANUP_FRAGMENT_SOURCE" << 'EOF'
# 🧹 Core Environment Cleanup Fragment (Symlink-based v2.0)
# This fragment runs first (00- prefix) to clean up environment pollution

# Remove macOS/homebrew paths from Linux environment
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PATH=$(echo "$PATH" | tr ":" "\n" | \
        grep -v -E "(opt/homebrew|Users/.*\.local|/opt/X11|Users/.*/bin)" | \
        tr "\n" ":" | sed "s/:$//" | sed "s/^://")
    export PATH
fi

# Set basic NODE_PATH if node is available
if command -v node >/dev/null 2>&1 && [ -d "/usr/local/lib/node_modules" ]; then
    export NODE_PATH="/usr/local/lib/node_modules"
fi

# Ensure user local bin is in PATH
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
EOF

# Create symlink in skel directory
ln -sf "$CLEANUP_FRAGMENT_SOURCE" "$SKEL_DIR/.ohmyzsh_source_load_scripts/.00-cleanup.zshrc"

# Create symlink for existing user if they exist
if [ -d "$USER_HOME" ]; then
    mkdir -p "$USER_HOME/.ohmyzsh_source_load_scripts"
    ln -sf "$CLEANUP_FRAGMENT_SOURCE" "$USER_HOME/.ohmyzsh_source_load_scripts/.00-cleanup.zshrc"
    if ! getent group ${USERNAME} > /dev/null 2>&1; then
        chown -h ${USERNAME}:users "$USER_HOME/.ohmyzsh_source_load_scripts/.00-cleanup.zshrc"
    else
        chown -h ${USERNAME}:${USERNAME} "$USER_HOME/.ohmyzsh_source_load_scripts/.00-cleanup.zshrc"
    fi
fi

echo "Core cleanup fragment created successfully."

# 8. Handle common-utils:2 override protection
# The common-utils:2 feature runs after us and overwrites .zshrc with devcontainers theme
# We need to protect against this by creating a post-install fragment that restores our config
echo "Creating common-utils override protection..."

# Create post-install protection fragment in the image
POST_INSTALL_FRAGMENT_SOURCE="$FRAGMENT_SOURCE_DIR/.99-powerlevel10k-restore.zshrc"
cat > "$POST_INSTALL_FRAGMENT_SOURCE" << 'EOF'
# 🔧 PowerLevel10k Restore Fragment (Post-Install Protection)
# This fragment runs last (99- prefix) to restore PowerLevel10k after common-utils override

# If PowerLevel10k is available but theme is wrong, restore it
if [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    # Check if current theme is NOT powerlevel10k
    if [ -f "$HOME/.zshrc" ] && ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$HOME/.zshrc"; then
        echo "🔧 Restoring PowerLevel10k theme (common-utils override detected)"
        
        # Update theme in zshrc
        if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
            sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        else
            echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
        fi
        
        # Ensure P10k instant prompt is at the top
        if ! grep -q "p10k-instant-prompt" "$HOME/.zshrc"; then
            # Create temp file with P10k instant prompt at the top
            cat > "/tmp/zshrc_with_p10k" << 'INNER_EOF'
# PowerLevel10k instant prompt (must be near top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

INNER_EOF
            cat "$HOME/.zshrc" >> "/tmp/zshrc_with_p10k"
            mv "/tmp/zshrc_with_p10k" "$HOME/.zshrc"
        fi
        
        # Ensure P10k config loading at the end
        if ! grep -q "source.*\.p10k.zsh" "$HOME/.zshrc"; then
            echo '' >> "$HOME/.zshrc"
            echo '# Load PowerLevel10k configuration' >> "$HOME/.zshrc"
            echo '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' >> "$HOME/.zshrc"
        fi
    fi
    
    # Always set ZSH_THEME for this session
    export ZSH_THEME="powerlevel10k/powerlevel10k"
    
    # Load P10k configuration if available
    [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
fi
EOF

# Create symlink in skel directory
ln -sf "$POST_INSTALL_FRAGMENT_SOURCE" "$SKEL_DIR/.ohmyzsh_source_load_scripts/.99-powerlevel10k-restore.zshrc"

# Create symlink for existing user if they exist
if [ -d "$USER_HOME" ]; then
    mkdir -p "$USER_HOME/.ohmyzsh_source_load_scripts"
    ln -sf "$POST_INSTALL_FRAGMENT_SOURCE" "$USER_HOME/.ohmyzsh_source_load_scripts/.99-powerlevel10k-restore.zshrc"
    if ! getent group ${USERNAME} > /dev/null 2>&1; then
        chown -h ${USERNAME}:users "$USER_HOME/.ohmyzsh_source_load_scripts/.99-powerlevel10k-restore.zshrc"
    else
        chown -h ${USERNAME}:${USERNAME} "$USER_HOME/.ohmyzsh_source_load_scripts/.99-powerlevel10k-restore.zshrc"
    fi
fi

echo "PowerLevel10k protection fragment created successfully."

log_debug "=== 003-ZSH-SETUP INSTALL COMPLETED ==="
echo "=== ZSH SETUP COMPLETE ==="
# Auto-trigger build Wed Sep 25 15:57:00 GMT 2025
# Auto-trigger build Sun Sep 28 03:47:24 BST 2025
