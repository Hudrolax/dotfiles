#!/bin/bash

# Save installed packages
mkdir -p ~/dotfiles
pacman -Qqen > ~/dotfiles/native-packages.txt
pacman -Qqem > ~/dotfiles/aur-packages.txt
