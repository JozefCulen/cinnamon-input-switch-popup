#!/usr/bin/env bash
# Symlink the extension into the user's Cinnamon extensions dir and enable it.
set -euo pipefail

UUID="input-switch-popup@JozefCulen"
SRC="$(cd "$(dirname "$0")" && pwd)/$UUID/files/$UUID"
DEST_DIR="$HOME/.local/share/cinnamon/extensions"

mkdir -p "$DEST_DIR"
ln -sfn "$SRC" "$DEST_DIR/$UUID"
echo "Linked $DEST_DIR/$UUID -> $SRC"

current="$(gsettings get org.cinnamon enabled-extensions)"
if [[ "$current" != *"'$UUID'"* ]]; then
    if [[ "$current" == "@as []" || "$current" == "[]" ]]; then
        new="['$UUID']"
    else
        new="${current%]}, '$UUID']"
    fi
    gsettings set org.cinnamon enabled-extensions "$new"
    echo "Enabled $UUID"
else
    dbus-send --session --dest=org.Cinnamon --type=method_call /org/Cinnamon \
        org.Cinnamon.ReloadXlet string:"$UUID" string:'EXTENSION'
    echo "Reloaded $UUID"
fi

if [[ "$(gsettings get org.gnome.desktop.interface toolkit-accessibility)" != "true" ]]; then
    cat <<EOF

Note: GTK apps and LibreOffice report the text caret out of the box.
Firefox, Chrome and Electron apps (VS Code, Slack...) only do so with
accessibility enabled; otherwise the popup appears at the mouse pointer.
To enable it, run:
    gsettings set org.gnome.desktop.interface toolkit-accessibility true
and restart those apps.
EOF
fi
