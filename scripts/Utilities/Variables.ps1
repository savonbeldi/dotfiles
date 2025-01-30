$USER_HOME = $env:HOME
$ROOT_HOME = Join-Path / root
$DOTFILES = Join-Path $USER_HOME dotfiles
$IsWSL = [bool]$env:WSL_DISTRO_NAME