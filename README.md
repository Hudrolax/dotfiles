## Description

This repository contains a set of scripts and configurations for quickly deploying and setting up your environment.

## Quick Start

1. Clone the repository:

   ```bash
   git clone https://github.com/Hudrolax/dotfiles.git ~/dotfiles
````

2. Make the scripts executable:

   ```bash
   chmod +x ~/dotfiles/hudro/*.sh ~/dotfiles/hudro/scripts/*.sh
   ```
3. Run the full installer (Arch Linux only):

   ```bash
   source ~/dotfiles/hudro/install-arch-linux.sh
   ```

   This script will install all required packages, clone the ML4W Dotfiles, and set up the `hudro` configs.

## Main Scripts

### `install-arch-linux.sh`

The full installer for Arch Linux. It performs the following steps:

1. Updates the system and installs base packages.
2. Installs packages from `native-packages.txt` and `aur-packages.txt` via `install-arch-packages.sh`.
3. Clones the ML4W Dotfiles and deploys them to your home directory.
4. Runs `link_hudro_config.sh` to create symbolic links for the `hudro` configs.
5. Adds sourcing of your `~/.zshrc-hudro` configuration to `.zshrc` via `add_zshrc-hudro.sh`.

### `scripts/install-arch-packages.sh`

Installs all specified packages for Arch Linux:

* From the official repositories (`native-packages.txt`).
* From AUR (`aur-packages.txt`).

### `scripts/link_hudro_config.sh`

Creates symbolic links (`ln -sf`) from the `hudro/.config` folder to `~/.config`, overwriting existing files as needed.

### `scripts/add_zshrc-hudro.sh`

Adds the following line to the end of your `~/.zshrc`, if it isn’t already present:

```bash
source "$HOME/dotfiles/hudro/.zshrc-hudro"
```

## Configuration and Customization

* All configurations reside in the `.config/` directory and are symlinked by the scripts.
* The `.zshrc-hudro` file contains personal aliases, functions, and Zsh settings.
* To modify packages, edit `native-packages.txt` and/or `aur-packages.txt`.
* To regenerate package lists, run: `./make_requirements.sh`.

---

*Author: Sergei Nazarov*
