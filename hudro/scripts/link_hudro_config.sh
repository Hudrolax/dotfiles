#!/bin/bash

# -----------------------------------------------------
# Hyprland config
# -----------------------------------------------------
if [[ -e $HOME/.config/hypr ]]; then
  # Link hyprland config
  ln -sfnT ~/dotfiles/hudro/.config/hypr/conf/custom-hudro.conf ~/.config/hypr/conf/custom-hudro.conf
  CUSTOM_HYPR_CONFIG="$HOME/.config/hypr/conf/custom.conf"
  HYPRLOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"

  HUDRO_CUSTOM_CONFIG_PATH="~/.config/hypr/conf/custom-hudro.conf"
  HUDRO_CUSTOM_HYPRLOCK_CONFIG_PATH="~/.config/hypr/hyprlock_custom.conf"

  # add custom hyprland config
  if ! grep -Fxq "source = $HUDRO_CUSTOM_CONFIG_PATH" "$CUSTOM_HYPR_CONFIG"; then
    echo "source = $HUDRO_CUSTOM_CONFIG_PATH" >> "$CUSTOM_HYPR_CONFIG"
  fi

  # hyprland binds config
  ln -sfnT ~/dotfiles/hudro/.config/hypr/conf/keybindings/hudro.conf ~/.config/hypr/conf/keybindings/hudro.conf
  echo "source = ~/.config/hypr/conf/keybindings/hudro.conf" > ~/.config/hypr/conf/keybinding.conf

  # screenshots config
  ln -sfnT ~/dotfiles/hudro/.config/hypr/scripts/take-area-screenshot.sh ~/.config/hypr/scripts/take-area-screenshot.sh
  chmod +x ~/.config/hypr/scripts/take-area-screenshot.sh

  # Link hyprlock config
  ln -sfnT ~/dotfiles/hudro/.config/hypr/hyprlock_custom.conf ~/.config/hypr/hyprlock_custom.conf

  # Turn OFF Walpeppers deamon (CPU usage)
  # sed -i.bak \
  #   's|^exec-once = ~/.config/hypr/scripts/wallpaper-restore.sh|#exec-once = ~/.config/hypr/scripts/wallpaper-restore.sh|' \
  #   ~/.config/hypr/conf/autostart.conf

  # Link waybar conf
  ln -sfnT ~/dotfiles/hudro/.config/waybar/themes/hudro ~/.config/waybar/themes/hudro
  ln -sfnT ~/dotfiles/hudro/.config/waybar/hudro-modules.json ~/.config/waybar/hudro-modules.json
  sed -i.bak \
    's|^options=$(find \$themes_path -maxdepth 2 -type d)|options=$(find -L \$themes_path -maxdepth 2 -type d)|' \
    ~/.config/waybar/themeswitcher.sh
  sed -i.bak \
    's|find \$value -maxdepth 1 -type d|find -L \$value -maxdepth 1 -type d|' \
    ~/.config/waybar/themeswitcher.sh
  echo "/hudro;/hudro" > ~/.config/ml4w/settings/waybar-theme.sh

  # add custom hyprlock config
  mv ~/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf.bak || true
  ln -sfnT ~/dotfiles/hudro/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf

  # Dock config
  mv -f $HOME/.config/nwg-dock-hyprland/launch.sh $HOME/.config/nwg-dock-hyprland/launch.sh.backup || true
  ln -sfnT ~/dotfiles/hudro/.config/nwg-dock-hyprland/launch.sh ~/.config/nwg-dock-hyprland/launch.sh

  mv -f $HOME/.config/nwg-dock-hyprland/style-dark.css $HOME/.config/nwg-dock-hyprland/style-dark.css.backup || true
  ln -sfnT ~/dotfiles/hudro/.config/nwg-dock-hyprland/style-dark.css ~/.config/nwg-dock-hyprland/style-dark.css

  # auto power profile
  ln -sfnT ~/dotfiles/hudro/.config/hypr/scripts/auto-power-profile.sh ~/.config/hypr/scripts/auto-power-profile.sh
  chmod +x ~/dotfiles/hudro/.config/hypr/scripts/auto-power-profile.sh

  # link hudro hypr conf
  ln -sfnT ~/dotfiles/hudro/.config/hypr/hudro-conf ~/.config/hypr/hudro-conf

  # auto start applications
  ln -sfnT ~/dotfiles/hudro/.config/hypr/scripts/autostart_applications.sh ~/.config/hypr/scripts/autostart_applications.sh

  # suspend non actived processes script
  ln -sfnT ~/dotfiles/hudro/.config/hypr/scripts/suspend_nonactied_processes.sh ~/.config/hypr/scripts/suspend_nonactied_processes.sh

  # waybar taskbar
  mkdir -p ~/.config/waybar/scripts
  ln -sfnT ~/dotfiles/hudro/.config/waybar/scripts/pin.sh ~/.config/waybar/scripts/pin.sh
  chmod +x ~/dotfiles/hudro/.config/waybar/scripts/pin.sh
else
  echo "⚠ Hyprland not installed!"
fi

# -----------------------------------------------------
# kitty config
# -----------------------------------------------------
if [[ -e $HOME/.config/kitty ]]; then
  ln -sfnT ~/dotfiles/hudro/.config/kitty/custom.conf ~/.config/kitty/custom.conf
else
  echo "kitty not installed!"
fi

# -----------------------------------------------------
# alacritty config
# -----------------------------------------------------
mv -f ~/.config/alacritty ~/.config/alacritty.old || true
ln -sfnT ~/dotfiles/hudro/.config/alacritty ~/.config/alacritty

# -----------------------------------------------------
# nvim config
# -----------------------------------------------------
mv -f ~/.config/nvim ~/.config/nvim.old || true
ln -sfnT ~/dotfiles/hudro/.config/nvim ~/.config/nvim

