#!/bin/zsh
# Installer for iterm-project-badges
#   curl -fsSL https://raw.githubusercontent.com/tstambulsky/iterm-project-badges/main/install.sh | zsh
#
# Installs the plugin to ~/.config/iterm-project-badges/ and adds a
# source line to ~/.zshrc (idempotent — safe to run twice).

set -e

REPO_RAW="https://raw.githubusercontent.com/tstambulsky/iterm-project-badges/main"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/iterm-project-badges"
PLUGIN_FILE="$CONFIG_DIR/iterm-project-badges.zsh"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
MARKER="# iterm-project-badges"

mkdir -p "$CONFIG_DIR"

# If run from a local checkout, copy the plugin; otherwise download it.
local_plugin="${0:a:h}/iterm-project-badges.zsh"
if [[ -f "$local_plugin" ]]; then
  cp "$local_plugin" "$PLUGIN_FILE"
  echo "Installed plugin from local checkout."
else
  curl -fsSL "$REPO_RAW/iterm-project-badges.zsh" -o "$PLUGIN_FILE"
  echo "Downloaded plugin."
fi

# Example config (never overwritten).
if [[ ! -f "$CONFIG_DIR/config.zsh" ]]; then
  cat > "$CONFIG_DIR/config.zsh" <<'EOF'
# iterm-project-badges — user configuration (optional)
# Everything works out of the box; uncomment to customize.

# Friendly display names (default: repo folder name)
# PROJECT_NAMES[my-long-repo-name]="My App"

# Tab colors as "R,G,B" (default: auto-generated per repo)
# PROJECT_COLORS[my-long-repo-name]="52,199,89"

# Badge text color as hex without '#'. "auto" = match the project color.
# IPB_BADGE_COLOR="00ff41"

# Disable individual features (1 = on, 0 = off)
# IPB_SET_BADGE=1
# IPB_SET_TAB_COLOR=1
# IPB_SET_TITLE=1
EOF
  echo "Created example config at $CONFIG_DIR/config.zsh"
fi

# Add source line to .zshrc, only once.
if ! grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
  {
    echo ""
    echo "$MARKER — https://github.com/tstambulsky/iterm-project-badges"
    echo "[[ -r \"$PLUGIN_FILE\" ]] && source \"$PLUGIN_FILE\""
  } >> "$ZSHRC"
  echo "Added source line to $ZSHRC"
else
  echo "Source line already present in $ZSHRC — skipped."
fi

echo ""
echo "✅ iterm-project-badges installed."
echo "   Restart your terminal or run:  source $PLUGIN_FILE"
echo ""
echo "   Customize:  $CONFIG_DIR/config.zsh"
echo "   Uninstall:  remove the '$MARKER' lines from $ZSHRC"
echo "               and delete $CONFIG_DIR"
