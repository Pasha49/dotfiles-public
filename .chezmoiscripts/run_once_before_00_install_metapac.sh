#!/usr/bin/env bash
set -e

if ! command -v metapac &> /dev/null; then
    echo "==> [chezmoi] metapac not found. Installing from AUR via pamac..."
    pamac build --no-confirm metapac
else
    echo "==> [chezmoi] metapac is already installed."
fi
