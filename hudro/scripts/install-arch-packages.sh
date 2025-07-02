#!/bin/bash
set -euo pipefail

export RUNZSH=yes
export CHSH=yes
export KEEP_ZSHRC=no
export YES=1

# request sudo pwd
if [[ $EUID -ne 0 ]]; then
  if ! sudo -n true 2>/dev/null; then
    echo "🔒sudo password:"
    sudo -v || exit 1
  fi
fi

# Install dependencies
echo "Installing dependencies..."

# 1. Обновляем базу и систему
sudo pacman -Syu --noconfirm

# 2. Ставим инструменты сборки и git
sudo pacman -S --noconfirm --needed base-devel git

echo "Installing yay"
if ! command -v yay &>/dev/null; then
  TMPDIR=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$TMPDIR"
  cd "$TMPDIR"
  makepkg -si --noconfirm
  cd -
  rm -rf "$TMPDIR"
fi

echo "Installing pacman packages"
if [[ -f ~/dotfiles/native-packages.txt ]]; then
  sudo pacman -S --noconfirm --needed - < ~/dotfiles/native-packages.txt
else
  echo "⚠ ~/dotfiles/native-packages.txt not found!"
fi

echo "Installing AUR packages"
if [[ -f ~/dotfiles/aur-packages.txt ]]; then
  yay -S --noconfirm --needed - < ~/dotfiles/aur-packages.txt
else
  echo "⚠ ~/dotfiles/aur-packages.txt not found!"
fi

echo "All packages installed."
