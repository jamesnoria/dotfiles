#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

info() {
  printf '\033[1;34m==>\033[0m %s\n' "$1"
}

ok() {
  printf '\033[1;32mOK\033[0m %s\n' "$1"
}

warn() {
  printf '\033[1;33mWARN\033[0m %s\n' "$1"
}

backup_path() {
  local path="$1"

  if [ -e "$path" ] || [ -L "$path" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$path" "$BACKUP_DIR/"
    warn "Backup: $path -> $BACKUP_DIR/"
  fi
}

link_path() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    ok "Ya enlazado: $target"
    return
  fi

  backup_path "$target"
  ln -s "$source" "$target"
  ok "Enlazado: $target -> $source"
}

ensure_tpm() {
  local tpm_dir="${HOME}/.tmux/plugins/tpm"

  if [ -d "$tpm_dir/.git" ]; then
    ok "TPM ya esta instalado"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    warn "Git no esta instalado; no puedo instalar TPM automaticamente"
    return
  fi

  info "Instalando TPM para tmux"
  mkdir -p "$(dirname "$tpm_dir")"
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  ok "TPM instalado"
}

sync_neovim_plugins() {
  if ! command -v nvim >/dev/null 2>&1; then
    warn "Neovim no esta instalado; omito Lazy sync"
    return
  fi

  info "Sincronizando plugins de Neovim"
  nvim --headless "+Lazy! sync" +qa
}

main() {
  info "Instalando dotfiles desde $DOTFILES_DIR"

  link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  link_path "$DOTFILES_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
  link_path "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
  link_path "$DOTFILES_DIR/tmux/tmux.conf.local" "$HOME/.tmux.conf.local"
  link_path "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"

  ensure_tpm

  if command -v tmux >/dev/null 2>&1; then
    warn "Dentro de tmux, recarga con: tmux source-file ~/.tmux.conf"
    warn "Luego instala plugins con: prefix + I"
  else
    warn "tmux no esta instalado"
  fi

  sync_neovim_plugins

  info "Listo"
  if [ -d "$BACKUP_DIR" ]; then
    warn "Backups guardados en $BACKUP_DIR"
  fi
}

main "$@"
