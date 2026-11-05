# ---------------------------------------------------------------------------
# zsh configuration
#
# This file is symlinked to ~/.zshrc; the modules it sources live next to it
# in the dotfiles repo, so resolve the symlink to find them.
#
#   path.zsh           PATH (nvm, ~/.local/bin, dotnet tools, opencode)
#   env.zsh            environment variables (EDITOR)
#   aliases.zsh        aliases
#   terminal-gate.zsh  defines zshrc_wanted_terminal, used below
#   oh-my-zsh.zsh      oh-my-zsh settings, plugin list, oh-my-zsh.sh
#   completion.zsh     shell completions
#
# Everything above the gate is cheap and always applied, even for
# non-interactive shells (scripts, editors, agents). Everything below is slow
# and loads only in a terminal where a human is typing.
# ---------------------------------------------------------------------------

ZSH_CONFIG_DIR=${${(%):-%x}:A:h}

source $ZSH_CONFIG_DIR/path.zsh
source $ZSH_CONFIG_DIR/env.zsh
source $ZSH_CONFIG_DIR/aliases.zsh

# --- terminal gate ---------------------------------------------------------

source $ZSH_CONFIG_DIR/terminal-gate.zsh

if ! zshrc_wanted_terminal; then
  unfunction zshrc_wanted_terminal
  unset ZSH_CONFIG_DIR
  return
fi
unfunction zshrc_wanted_terminal

# --- interactive -----------------------------------------------------------

source $ZSH_CONFIG_DIR/oh-my-zsh.zsh
source $ZSH_CONFIG_DIR/completion.zsh

unset ZSH_CONFIG_DIR
