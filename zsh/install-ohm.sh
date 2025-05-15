#!/usr/bin/env bash
set -euo pipefail


# 1) Проверка прав
if [[ $EUID -ne 0 ]]; then
  echo "Запустите скрипт под sudo или root:"
  echo "  sudo $0"
  exit 1
fi

# 2) Обновление и установка зависимостей
apt update
apt install -y curl zsh git

# 3) Установка Oh My Zsh без интерактива
export RUNZSH=yes    # не запускать zsh сразу после установки
export CHSH=yes      # не менять shell автоматически
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 4) Клонирование плагинов
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGINS=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)
for plug in "${PLUGINS[@]}"; do
  target="$ZSH_CUSTOM/plugins/$plug"
  if [[ -d $target ]]; then
    echo "Плагин $plug уже установлен, пропускаем."
  else
    git clone --depth=1 "https://github.com/zsh-users/$plug.git" "$target"
  fi
done


# 5) Смена shell на zsh (для пользователя, который запускал sudo)
USER_TO_CHANGE="${SUDO_USER:-$USER}"
chsh -s "$(command -v zsh)" "$USER_TO_CHANGE" || \
  echo "Не удалось автоматически поменять shell — сделайте это вручную: chsh -s \$(which zsh) $USER_TO_CHANGE"

echo
echo "Установка завершена! Теперь скопируй все из zshrc-export в ~/.zshrc и затем выполните 'exec zsh'."
