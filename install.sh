#!/bin/bash

# Set trap to catch SIGINT (Ctrl+C) and exit the script immediately
trap 'echo -e "\nCtrl+C pressed, exiting script..."; exit' SIGINT

echo -e "\e[34m\n[DOTFILES] Install Powershell Core\e[0m"
echo -e "\e[90mThis script will install PowerShell Core and change the default shell to PowerShell for the current user\e[0m"
echo -e "\e[90mAfter the installation is complete, the script will continue in PowerShell to install the dotfiles\e[0m"

# source: https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.4#installation-via-package-repository-the-package-repository
echo -e "\n[1/4] Install prerequisites"
sudo apt update && sudo apt install -y wget apt-transport-https software-properties-common
if [ $? -eq 0 ]; then
  echo -e "\e[32m[OK] Prerequisites installed\e[0m"
else
  echo -e "\e[31m[ERROR] Failed to install prerequisites\e[0m"
  exit 1
fi

echo -e "\n[2/4] Install PowerShell Core"
source /etc/os-release
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb
sudo apt update && sudo apt install -y powershell
if [ $? -eq 0 ]; then
  echo -e "\e[32m[OK] PowerShell Core installed\e[0m"
else
  echo -e "\e[31m[ERROR] Failed to install PowerShell Core\e[0m"
  exit 1
fi

PWSH_PATH=$(which pwsh)
if [ -z "$PWSH_PATH" ]; then
    echo -e "\e[31m[ERROR] PowerShell installation failed: PWSH_PATH is not set\e[0m"
    exit 1
fi

echo -e "\n[3/4] Changing default shell for user"
chsh -s "$PWSH_PATH"
if [ $? -eq 0 ]; then
  echo -e "\e[32m[OK] Default shell changed\e[0m"
else
  echo -e "\e[31m[ERROR] Failed to change default shell\e[0m"
  exit 1
fi

echo -e "\n[4/4] Continuing installation in PowerShell"
pwsh -Command $PWD/Install.ps1
if [ $? -eq 0 ]; then
  echo -e "\e[32m[OK] Dotfiles installed\e[0m"
else
  echo -e "\e[31m[ERROR] Dotfiles installation failed, see errors above\e[0m"
  exit 1
fi