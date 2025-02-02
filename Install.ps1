. $(Join-Path $PSScriptRoot scripts Utilities Variables.ps1)
. $(Join-Path $DOTFILES scripts Utilities Helpers.ps1)
. $(Join-Path $DOTFILES scripts Utilities Logger.ps1)

Write-Host "`n[DOTFILES] Install dotfiles" -ForegroundColor Blue 

Write-Host "`n[1/4] Install prerequisites"
bash -c "sudo apt update && sudo apt install -y git curl wget"
if (!$?)
{
  Write-Error "Failed to install prerequisites"
  exit 1
}
Write-Ok "Prerequisites installed"

Write-Host "`n[2/4] Symlinking PowerShell, Bash and Git configuration files"
Write-Host "(1/2) PowerShell Core"
$powershellPath = Join-Path .config powershell profile.ps1
Symlink-Files -Source $(Join-Path $DOTFILES $powershellPath) -Target $(Join-Path $USER_HOME $powershellPath)
Write-Ok "PowerShell Core files symlinked to $USER_HOME/$powershellPath"

Write-Host "(2/3) Bash"
Symlink-Files -Source $(Join-Path $DOTFILES .profile) -Target $(Join-Path $USER_HOME .profile)
Symlink-Files -Source $(Join-Path $DOTFILES .bashrc) -Target $(Join-Path $USER_HOME .bashrc)

Write-Host "`n(3/3) .gitconfig"
Symlink-Files -Source $(Join-Path $DOTFILES .gitconfig) -Target $(Join-Path $USER_HOME .gitconfig)
Write-Ok "Git configuration file symlinked to $USER_HOME/.gitconfig"

Write-Host "`n[3/4] Install CLI applications"
Write-Host "`n(1/8) Starship"
Write-Host "Install Starship configuration files"
$starshipPath = Join-Path .config starship.toml
Symlink-Files -Source $(Join-Path $DOTFILES $starshipPath) -Target $(Join-Path $USER_HOME $starshipPath)
Write-Ok "Starship configuration file symlinked to $USER_HOME/$starshipPath"

Write-Host "Install Starship"
if (Get-Command starship -ErrorAction SilentlyContinue)
{
  Write-Ok "Starship is already installed"
}
else
{
  Write-Host "Install Starship"
  bash -c "curl -sS https://starship.rs/install.sh | sh"
  Write-Ok "Starship installed"
}

Write-Host "`n(2/8) posh-git"
if (!(Get-Module -ListAvailable -Name posh-git))
{
  Install-Module posh-git -Scope CurrentUser -ErrorAction Stop
  Import-Module posh-git -ErrorAction Stop
  Write-Ok "posh-git installed"
}
else
{
  Write-Ok "posh-git is already installed"
}

Write-Host "`n(3/8) Ranger"
Write-Host "Install Ranger configuration files"
$rangerPath = Join-Path .config ranger
Symlink-Files -Source $(Join-Path $DOTFILES $rangerPath) -Target $(Join-Path $USER_HOME $rangerPath)
Write-Ok "Ranger files symlinked to $USER_HOME/$rangerPath"

Write-Host "`nInstall Ranger"
bash -c "sudo apt install -y ranger"
Write-Ok "Ranger installed"

Write-Host "`n(4/8) Vim"
Write-Host "Install Vim configuration file"
Symlink-Files -Source $(Join-Path $DOTFILES .vimrc) -Target $(Join-Path $USER_HOME .vimrc)
Write-Ok "Vim configuration file symlinked to $USER_HOME/.vimrc"

Write-Host "`nInstall Vim"
bash -c "sudo apt install -y vim"
Write-Ok "Vim installed"

Write-Host "`n(5/8) DockerCompletion"
if (!(Get-Module -ListAvailable -Name DockerCompletion))
{
  Install-Module DockerCompletion -Scope CurrentUser
  Import-Module DockerCompletion -ErrorAction Stop
  Write-Ok "DockerCompletion installed"
}
else
{
  Write-Ok "DockerCompletion is already installed"
}

Write-Host "`n(6/7) dotnet"
Write-Host "Install global.json"
Symlink-Files -Source $(Join-Path $DOTFILES global.json) -Target $(Join-Path $USER_HOME global.json)

Write-Host "`nInstall dotnet 8"
bash -c "sudo apt install -y dotnet-sdk-8.0"
Write-Ok "dotnet 8 installed"

Write-Host "`nInstall dotnet 9"
bash -c "sudo add-apt-repository ppa:dotnet/backports && sudo apt install -y dotnet-sdk-9.0"
Write-Ok "dotnet 9 installed"

Write-Host "`n(7/7) nodejs"
Write-Host "Install nvm"
Symlink-Files -Source $(Join-Path $DOTFILES .nvmrc) -Target $(Join-Path $USER_HOME .nvmrc)
if (!(Get-Module -ListAvailable -Name nvm))
{
  Install-Module nvm -Scope CurrentUser -ErrorAction Stop
  Import-Module nvm -ErrorAction Stop
  Write-Ok "nvm installed"
}
else
{
  Write-Ok "nvm is already installed"
}

Write-Host "`nInstall nodejs"
try 
{
  Install-NodeVersion
  Write-Ok "Nodejs installed"
}
catch
{
  Write-Warning "Failed to install nodejs: $($_.Exception.Message)"
}

Write-Host "`n[3/4] Install GUI applications"
if ($IsWsl -eq $false)
{
  if ($(Confirm-Action -Message "Do you want to install the GUI applications?" -Default "Y") -eq $true)
  {
    Write-Host "`n(1/5) Chromium"
    bash -c "sudo snap install chromium"
    Write-Ok "Chromium installed"

    Write-Host "`n(2/5) VSCode"
    Write-Host "Install vscode configuration files"
    $vsCodePath = Join-Path .config Code
    Symlink-Files -Source $(Join-Path $DOTFILES $vsCodePath) -Target $(Join-Path $USER_HOME $vsCodePath)
    Write-Ok "Code files symlinked to $USER_HOME/$vsCodePath"
    bash -c "sudo snap install code --classic"
    Write-Ok "VSCode installed"

    Write-Host "`n(3/5) Mullvad"
    if (Get-Command mullvad -ErrorAction SilentlyContinue)  
    {
      Write-Host "Mullvad is already installed"
      Write-Host "Updating Mullvad"
      bash -c "sudo apt install -y mullvad-vpn" 
      Write-Ok "Mullvad updated"
    }
    else
    {
      # source: https://mullvad.net/en/download/vpn/linux
      # Download the Mullvad signing key
      bash -c "sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc"

      # Add the Mullvad repository server to apt
      bash -c 'echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list'

      # Install the package
      bash -c "sudo apt update && sudo apt install mullvad-vpn"
      Write-Ok "Mullvad installed"
    }

    Write-Host "`n(/5) KeepassXC"
    sudo snap install keepassxc
    Write-Ok "KeepassXC installed"

    Write-Host "`n(5/5) Docker"
    if (Get-Command docker -ErrorAction SilentlyContinue)
    {
      Write-Host "Docker is already installed"
      Write-Host "Updating Docker"
      bash -c "sudo apt install -y docker-desktop"
      Write-Ok "Docker updated"
    }
    else
    {
      # source: https://docs.docker.com/desktop/setup/install/linux/ubuntu/#install-docker-desktop

      # Add Docker's official GPG key:
      bash -c "sudo apt install ca-certificates curl"
      bash -c "sudo install -m 0755 -d /etc/apt/keyrings"
      bash -c "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc"
      bash -c "sudo chmod a+r /etc/apt/keyrings/docker.asc"

      # Add the repository to Apt sources:
      bash -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
      bash -c "sudo apt update"

      bash -c "sudo curl -fsSL https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb -o docker-desktop.deb"
      bash -c "sudo apt install -y ./docker-desktop.deb"
      bash -c "rm -f docker-desktop.deb"

      Write-Ok "Docker installed"
    }

    if ($(Confirm-Action -Message "`n[5/5] Do you want to install GNOME Terminal profile?" -Default "Y") -eq $true)
    {
      Write-Host "`nInstall GNOME Terminal profile"
      $profileUuid = bash -c "dconf dump /org/gnome/terminal/legacy/profiles:/ | grep -oP '[0-9a-f-]{36}'"
      bash -c "dconf load /org/gnome/terminal/legacy/profiles:/:$profileUuid/ < $PWD/gnome-terminal-profile.dconf"
      Write-Ok "GNOME Terminal profile installed"
    }

    if ($(Confirm-Action -Message "`n[6/6] Do you want to install fonts?" -Default "Y") -eq $true)
    {
      Write-Host "`nInstall fonts"
      # Symlinking fonts does not work unfortunately
      bash -c "mkdir -p $HOME/.local/share/fonts && install -v -m 0644 $PWD/.local/share/fonts/* $HOME/.local/share/fonts && fc-cache -f"
      Write-Ok "Fonts installed"
    }
  }
  else
  {
    Write-Warning "GUI applications installation skipped"
  }
}
else
{
  Write-Warning "WSL detected, GUI applications installation skipped"
}

Write-Ok "Dotfiles installed" -NewLine