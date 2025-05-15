#!/usr/bin/env bash
set -euo pipefail


#--------------------------------------------------------
# Скрипт установки neovim + окружения (zsh уже должен быть)
# Запускать под sudo:  sudo ./install-nvim.sh
#--------------------------------------------------------

# 1) Проверка прав

if [[ $EUID -ne 0 ]]; then
  echo "Запустите скрипт под sudo или root:"
  echo "  sudo $0"
  exit 1
fi

# Определяем пользователя, для которого всё ставим
USER_HOME=$(eval echo "~${SUDO_USER:-$USER}")
USER_NAME=${SUDO_USER:-$USER}

# 2) Обновление и установка основных утилит
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
    curl wget git gpg pass zip unzip tmux gcc build-essential \
    bsdmainutils htop fzf bat ripgrep unzip

# 3) Создаём каталог для сторонних билдов
mkdir -p "${USER_HOME}/.soft"
chown "${USER_NAME}:${USER_NAME}" "${USER_HOME}/.soft"

# 4) Установка NVM и Node.js
#     Берём последнюю версию nvm и устанавливаем Node.js v22
# ------------------------------------------------------
su - "${USER_NAME}" -c '
  set -euo pipefail

  export NVM_DIR="$HOME/.nvm"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

  # загружаем nvm без перезапуска shell
  source "$NVM_DIR/nvm.sh"
  nvm install 22
  nvm alias default 22
  npm install -g tree-sitter-cli
'


# 5) Установка lazygit (последний релиз)
# ------------------------------------------------------
LAZYGIT_VER=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
  | grep -Po '"tag_name":\s*"v\K[0-9.]+')
curl -fsSL -o lazygit.tar.gz \
     "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VER}/lazygit_${LAZYGIT_VER}_Linux_x86_64.tar.gz"

tar -xzf lazygit.tar.gz -C .

install -m755 lazygit /usr/local/bin/lazygit
rm lazygit lazygit.tar.gz

# 6) Установка gdu (последний релиз)
# ------------------------------------------------------
curl -fsSL https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz \
  | tar xz -C .

install -m755 gdu_linux_amd64 /usr/local/bin/gdu
rm gdu_linux_amd64

# 7) Установка bottom (btm)
# ------------------------------------------------------
BTM_DEB="bottom_0.10.2-1_amd64.deb"
curl -fsSL -o "${BTM_DEB}" \
     "https://github.com/ClementTsang/bottom/releases/download/0.10.2/${BTM_DEB}"
dpkg -i "${BTM_DEB}" || apt-get -fy install -qq
rm "${BTM_DEB}"

# 8) Установка Neovim (stable release)
# ------------------------------------------------------
NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
wget -qO nvim-linux.tar.gz "${NVIM_URL}"
tar -xzf nvim-linux.tar.gz -C "${USER_HOME}/.soft"
mv "${USER_HOME}/.soft/nvim-linux-x86_64" "${USER_HOME}/.soft/nvim"
ln -sf "${USER_HOME}/.soft/nvim/bin/nvim" /usr/local/bin/nvim
rm nvim-linux.tar.gz

# 9) Установка AstroNvim и резерв существующих конфига
# ------------------------------------------------------
su - "${USER_NAME}" -c '
  set -euo pipefail
  for dir in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
    [[ -e "$dir" ]] && mv "$dir" "${dir}.bak"
  done
  git clone https://github.com/Hudrolax/astronvim_config.git ~/.config/nvim
'


echo 

echo "✅ Установка завершена!"
echo " - Подтвердите, что nvim, lazygit, gdu, btm, tree-sitter-cli доступны в PATH:"
echo "     nvim --version"
echo "     lazygit --version"
echo "     gdu --version"

echo "     btm --version"
echo "     tree-sitter"
echo
echo "Не забудь установить нужные LSP и автоформаттеры через :LspInstall и :MasonInstall"
