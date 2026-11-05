# ---------------------------------------------------------------------------
# Terminal gate
#
# oh-my-zsh, plugins and shell completions are slow and only useful when a
# human is typing. Load them only in the terminals I actually use: Ubuntu's
# built-in terminal (Ptyxis on 26.04, GNOME Terminal before) and VS Code's
# integrated terminal.
# Anything else -- Claude Code, scripts, tooling spawning a shell -- stops at
# the gate in .zshrc.
#
# Defines zshrc_wanted_terminal; .zshrc calls it and unfunctions it. The
# `return` has to happen in .zshrc itself -- returning from a sourced file
# only ends that file.
# ---------------------------------------------------------------------------

zshrc_wanted_terminal() {
  # Not a human at a prompt (scripts, `zsh -c`, tooling).
  [[ -o interactive ]] || return 1

  # An agent/CLI driving the shell, even inside an allowed terminal.
  [[ -n $CLAUDECODE || -n $CLAUDE_CODE_ENTRYPOINT || -n $AI_AGENT ]] && return 1

  # Ptyxis -- Ubuntu's built-in terminal since 25.10 / 26.04.
  [[ -n $PTYXIS_VERSION || -n $PTYXIS_PROFILE ]] && return 0

  # GNOME Terminal -- Ubuntu's built-in terminal before that.
  [[ -n $GNOME_TERMINAL_SCREEN || -n $GNOME_TERMINAL_SERVICE ]] && return 0

  # VS Code's integrated terminal.
  [[ $TERM_PROGRAM == vscode || -n $VSCODE_INJECTION || -n $VSCODE_GIT_IPC_HANDLE ]] && return 0

  # Any other VTE-based terminal, incl. a tmux/screen session started from one.
  [[ -n $VTE_VERSION ]] && return 0

  return 1
}
