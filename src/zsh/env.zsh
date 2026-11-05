# ---------------------------------------------------------------------------
# Environment
#
# Always applied, even for non-interactive shells.
# ---------------------------------------------------------------------------

# Preferred editor: nvim when installed, vim otherwise (and vim over SSH).
# Sourced after path.zsh so nvim is found wherever it lives.
if [[ -z $SSH_CONNECTION ]] && (( $+commands[nvim] )); then
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi
