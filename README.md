# Dotfiles

> **WIP**

A collection of dotfiles and configuration scripts for setting up a Linux development environment with PowerShell Core as the default shell. These dotfiles are designed to work on both native Ubuntu installations and Windows Subsystem for Linux (WSL).

## Overview

This repository contains configuration files and installation scripts for:

- PowerShell Core as the default shell
- Starship prompt customization
- Development tools (git, VSCode, dotnet and node)
- CLI utilities (ranger, vim)
- GUI applications (optional)
- Nerd fonts compatible with Windows and Linux (optional)
  > Install them manually when using Wsl.
- Useful aliases such as `Open-Item` and `Find-Item`

## Prerequisites

- Ubuntu (tested on latest LTS) or WSL
- Basic build tools (`curl`, `wget`, `git`)

## Installation

1. Fork this repository and clone it:

   ```bash
   $ git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   ```

2. Run the installation script:

   ```bash
   $ cd ~/dotfiles

     # Installs PowerShell Core and automatically continue the installation in PowerShell.
   $ ./install.sh
   ```

## Customization

To add custom configurations:

- Git work config: Create `work.gitconfig`
- PowerShell work profile: `.config/powershell/profile.ps1.d/Work.ps1`

## Known Issues

- When pressing `Ctrl+C` in completion menu freezes the terminal.
  > use `esc` to exit completion menu instead
  - Known on github: https://github.com/PowerShell/PSReadLine/issues/1487

## License

No license nonsense, just don't be a \_\_\_ and give credits when you use it.

## TODO

- Fix bug: when pressing ctrl+c during auto completion the terminal freezes.
  - Known issues: https://github.com/PowerShell/PSReadLine/issues/1487
- Symlink windows code settings to C:\Users\User\AppData\Roaming\Code\User\settings.json
  - Some windows installation have the symlink feature disabled.
- Rewrite all bash scripts to PowerShell
