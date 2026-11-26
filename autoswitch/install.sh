#!/bin/bash
# Install Giverny Light and the automatic light/dark switcher.
#
#  - creates the "giverny-light" theme next to this one, sharing the same
#    paintings (hard links, so no extra disk space)
#  - installs a post-boot hook that starts the switcher at login
#  - starts the switcher now
#
# Safe to re-run; re-run after `omarchy theme update` to resync paintings.

set -e

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES="$HOME/.config/omarchy/themes"
LIGHT="$THEMES/giverny-light"
DAEMON="$THEME_DIR/autoswitch/autoswitch"
LOG="$HOME/.local/state/omarchy/giverny-autoswitch.log"

command -v inotifywait >/dev/null || omarchy pkg add inotify-tools

# Giverny Light: its own palette, the shared paintings.
mkdir -p "$LIGHT"
rm -rf "$LIGHT/backgrounds"
mkdir -p "$LIGHT/backgrounds"
cp "$THEME_DIR/light/colors.toml" "$THEME_DIR/light/preview.png" "$THEME_DIR/icons.theme" "$LIGHT/"
for f in "$THEME_DIR"/backgrounds/*; do
  ln -f "$f" "$LIGHT/backgrounds/${f##*/}" 2>/dev/null || cp "$f" "$LIGHT/backgrounds/"
done

# Start Giverny Light on a light painting the first time it is picked directly.
STATE="$HOME/.local/state/omarchy/theme-backgrounds"
mkdir -p "$STATE"
first_light=$(awk '!/^#/ && $2 == "light" { print $1; exit }' "$THEME_DIR/paintings.conf")
if [[ -n $first_light ]] && ! grep -qs "/backgrounds/" "$STATE/giverny-light"; then
  match=$(cd "$THEME_DIR/backgrounds" && ls "$first_light".* 2>/dev/null | head -1)
  [[ -n $match ]] && echo "$HOME/.local/state/omarchy/current/theme/backgrounds/$match" >"$STATE/giverny-light"
fi

# post-boot hook
hook=$(mktemp -d)/giverny-autoswitch
cat >"$hook" <<EOF
#!/bin/bash
# Start the Giverny light/dark switcher.
setsid -f "$DAEMON" </dev/null >>"$LOG" 2>&1
EOF
omarchy hook install post-boot "$hook" >/dev/null
rm -rf "${hook%/*}"

chmod +x "$DAEMON"
mkdir -p "${LOG%/*}"
pgrep -f "$DAEMON" >/dev/null || setsid -f "$DAEMON" </dev/null >>"$LOG" 2>&1

echo "Giverny Light installed and the light/dark switcher is running."
echo "Pick any painting (Super+Ctrl+Space or 'omarchy theme bg next') and the theme follows it."
