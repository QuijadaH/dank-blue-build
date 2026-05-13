#!/usr/bin/env bash

set -euo pipefail

wait_for_escape() {
    while true; do
        read -rsn1 key
        if [[ $key == $'\e' ]]; then
            echo
            break
        fi
    done
}

STAMP_PATH="$HOME/.local/state/dank-blue-build"
mkdir -p "$STAMP_PATH"

if [[ -f "$STAMP_PATH/desktop-setup-done" ]]; then
    echo "Setup has already been completed."
    echo "Press ESC to exit..."
    wait_for_escape
    exit 0
fi

echo "Running setup script for user ${USER}..."

if [[ -f "$STAMP_PATH/sync-dankgreeter-done" ]]; then
    echo "DankGreeter has already been synced."
else
    echo "Syncing DankGreeter..."
    if dms greeter sync; then
        echo "Successfully synced DankGreeter."
        touch "$STAMP_PATH/sync-dankgreeter-done"
    else
        echo "Failed to sync DankGreeter." >&2
        echo "Press ESC to exit..."
        wait_for_escape
        exit 1
    fi      
fi

if [[ -e "/usr/lib/dank-blue-build/skel-init-done" ]]; then
    echo "Disabling 'skel-init.service'..."
    if ! sudo systemctl disable --now skel-init.service; then
        echo "Failed to disable 'skel-init.service'." >&2
    else
        echo "Successfully disabled 'skel-init.service'."
    fi
fi

echo "Setup completed successfully."
touch "$STAMP_PATH/desktop-setup-done"

echo "Locking desktop-setup.sh to prevent accidental re-runs..."
if mv $HOME/.config/autostart/desktop-setup.desktop $HOME/.config/autostart/desktop-setup.desktop.lock; then
    echo "Successfully locked desktop-setup.sh."
else
    echo "Failed to lock desktop-setup.sh." >&2
fi

echo "Press ESC to exit..."
wait_for_escape
exit 0