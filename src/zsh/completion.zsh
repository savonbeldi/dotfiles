# ---------------------------------------------------------------------------
# Autocomplete
#
# Interactive only -- sourced after oh-my-zsh.zsh, which runs compinit.
# Completions that shell out are the expensive part of startup, so each one
# is guarded by a check that its command exists.
# ---------------------------------------------------------------------------

# kubectl
(( $+commands[kubectl] )) && source <(kubectl completion zsh)

# Thalassa cloud cli
(( $+commands[tcloud] )) && source <(tcloud completion zsh)
