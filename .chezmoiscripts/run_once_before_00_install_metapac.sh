#!/usr/bin/env bash
set -e

echo "==> [chezmoi] Updating system databases and packages..."
sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
    echo "==> [chezmoi] yay not found. Installing via pamac..."
    pamac build --no-confirm yay
fi

if ! command -v metapac &> /dev/null; then
    echo "==> [chezmoi] metapac not found. Installing from AUR via pamac..."
    pamac build --no-confirm metapac
else
    echo "==> [chezmoi] metapac is already installed."
fi
