#!/usr/bin/env bash

# Set trap to catch SIGINT (Ctrl+C) and exit the script immediately
trap 'echo -e "\nCtrl+C pressed, exiting script..."; exit' SIGINT

# Exit immediately if a command exits with a non-zero status
set -e

echo -e "\n[1/x] Installing prerequisites"
sudo apt update
sudo apt install -y curl

echo -e "\n[2/x] Configure Bash shell"
curl -sS https://starship.rs/install.sh | sh
ln -sf $HOME/dotfiles/.bashrc $HOME/.bashrc
ln -sf $HOME/dotfiles/.profile $HOME/.profile
ln -sf $HOME/dotfiles/.config/starship.toml $HOME/.config/starship.toml

echo -e "\n[3/x] Configure git"
sudo apt install -y git
ln -sf $HOME/dotfiles/.gitconfig $HOME/.gitconfig

echo -e "\n[4/x] Configure fonts"
mkdir -p $HOME/.local/share/fonts
ln -sf $HOME/dotfiles/.local/share/fonts/* $HOME/.local/share/fonts
fc-cache -f

echo -e "\n[5/x] Configure VSCode"
ln -sf $HOME/dotfiles/.config/Code/User/settings.json $HOME/.config/Code/User/settings.json
ln -sf $HOME/dotfiles/.config/Code/User/keybindings.json $HOME/.config/Code/User/keybindings.json

echo -e "\n[6/x] Configure ranger"
sudo apt install -y ranger
mkdir -p $HOME/.config/ranger
ln -sf $HOME/dotfiles/.config/ranger/rc.conf $HOME/.config/ranger/rc.conf

echo -e "\n[7/x] Configure vim"
sudo apt install -y vim
ln -sf $HOME/dotfiles/.vimrc $HOME/.vimrc

echo -e "\n[8/x] Configure Gnome Terminal"
profileUuid=$(dconf dump /org/gnome/terminal/legacy/profiles:/ | grep -oP '[0-9a-f-]{36}')
dconf load /org/gnome/terminal/legacy/profiles:/:$profileUuid/ < $HOME/dotfiles/gnome-terminal-profile.dconf


echo -e "\n[8/x] Installation complete! Please restart your terminal."