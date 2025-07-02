#!/bin/bash
set -euo pipefail

ZSHRC_PATH="$HOME/dotfiles/hudro/.zshrc-hudro"
CUSTOM_ZSHRC="$HOME/.zshrc_custom"

touch "$CUSTOM_ZSHRC"

if ! grep -Fxq "source $ZSHRC_PATH" "$CUSTOM_ZSHRC"; then
  echo "source $ZSHRC_PATH" >> "$CUSTOM_ZSHRC"
fi
