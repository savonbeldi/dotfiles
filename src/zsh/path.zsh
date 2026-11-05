# ---------------------------------------------------------------------------
# PATH
#
# Always applied, even for non-interactive shells (scripts, editors, agents).
# Keep this cheap -- no subshells.
# ---------------------------------------------------------------------------

# node: put nvm's default version (and its global npm bins -- cf, pnpm, ...)
# on PATH without sourcing nvm.sh, which is slow. The oh-my-zsh nvm plugin
# takes over in interactive shells (cf. oh-my-zsh.zsh).
export NVM_DIR="$HOME/.nvm"
if [[ -z $NVM_BIN && -d $NVM_DIR/versions/node ]]; then
  _nvm_default=
  [[ -r $NVM_DIR/alias/default ]] && _nvm_default=$(<$NVM_DIR/alias/default)
  _nvm_bins=( $NVM_DIR/versions/node/v${_nvm_default#v}*/bin(/Nn) )
  (( $#_nvm_bins )) || _nvm_bins=( $NVM_DIR/versions/node/*/bin(/Nn) )
  (( $#_nvm_bins )) && export PATH="${_nvm_bins[-1]}:$PATH"
  unset _nvm_default _nvm_bins
fi

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet/tools"           # dotnet global tools
export PATH="$HOME/.opencode/bin:$PATH"           # opencode
