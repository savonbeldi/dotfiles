#!/usr/bin/env bash

# Set trap to catch SIGINT (Ctrl+C) and exit the script immediately
trap 'echo -e "\nCtrl+C pressed, exiting script..."; exit' SIGINT

# Exit immediately if a command exits with a non-zero status
set -e

echo -e "\n[1/x] Install prerequisites"
sudo apt update
sudo apt install -y curl git

echo -e "\n[2/x] Configure bash"
ln -sf $HOME/dotfiles/src/bash/.bashrc $HOME/.bashrc
ln -sf $HOME/dotfiles/src/bash/.profile $HOME/.profile

echo -e "\n[3/x] Configure zsh"
sudo apt install -y zsh
chsh -s $(which zsh)
rm -rf /home/$USER/.oh-my-zsh /home/$USER/.zshrc
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
ln -sf $HOME/dotfiles/src/zsh/.zshrc $HOME/.zshrc

echo -e "\n[4/x] Configure Starship"
sh -c "$(curl -sS https://starship.rs/install.sh)" "" --yes
ln -sf $HOME/dotfiles/src/starship/starship.toml $HOME/.config/starship.toml

echo -e "\n[5/x] Configure git"
sudo apt install -y git
ln -sf $HOME/dotfiles/src/git/.gitconfig $HOME/.gitconfig

echo -e "\n[6/x] Configure vim"
sudo apt install -y vim
ln -sf $HOME/dotfiles/src/vim/.vimrc $HOME/.vimrc

echo -e "\n[7/x] Configure ranger"
sudo apt install -y ranger
mkdir -p $HOME/.config/ranger
ln -sf $HOME/dotfiles/src/ranger/rc.conf $HOME/.config/ranger/rc.conf

echo -e "\n[8/x] Configure fonts"
mkdir -p $HOME/.local/share/fonts
ln -sf $HOME/dotfiles/src/fonts/* $HOME/.local/share/fonts
fc-cache -f

echo -e "\n[9/x] Configure VSCode"
mkdir -p $HOME/.config/Code/User
ln -sf $HOME/dotfiles/src/vscode/settings.json $HOME/.config/Code/User/settings.json
ln -sf $HOME/dotfiles/src/vscode/keybindings.json $HOME/.config/Code/User/keybindings.json

echo -e "\n[10/x] Configure node"
ln -sf $HOME/dotfiles/src/node/.npmrc $HOME/.npmrc

echo -e "\nInstallation complete! Please restart your terminal."