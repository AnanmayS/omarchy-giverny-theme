#!/bin/bash
# Remove the Giverny light/dark switcher and the Giverny Light theme.
# The dark Giverny theme itself is left installed.

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

rm -f "$HOME/.config/omarchy/hooks/post-boot.d/giverny-autoswitch"
pkill -f "$THEME_DIR/autoswitch/autoswitch" 2>/dev/null

if [[ $(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null) == giverny-light ]]; then
  omarchy theme set giverny
fi
rm -rf "$HOME/.config/omarchy/themes/giverny-light"

echo "Giverny light/dark switcher and Giverny Light removed."
