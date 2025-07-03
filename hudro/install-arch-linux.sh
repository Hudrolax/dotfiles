#!/bin/bash
set -euo pipefail

export RUNZSH=yes
export CHSH=yes
export KEEP_ZSHRC=no
export YES=1

SCRIPTS_PATH="$HOME/dotfiles/hudro/scripts"


# request sudo pwd
if [[ $EUID -ne 0 ]]; then
  if ! sudo -n true 2>/dev/null; then
    echo "🔒sudo password:"
    sudo -v || exit 1
  fi
fi

sudo chmod -R +x "$SCRIPTS_PATH"

source "$SCRIPTS_PATH/install-arch-packages.sh"

echo "Install ML4W dotfiles..."
bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-arch.sh)"

source "$SCRIPTS_PATH/install-oh-my-zsh-and-plugins.sh"
source "$SCRIPTS_PATH/link_hudro_config.sh"
source "$SCRIPTS_PATH/add_zshrc-hudro.sh"
source "$SCRIPTS_PATH/make_suspend.sh"

