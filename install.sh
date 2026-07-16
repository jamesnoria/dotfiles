#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
INSTALL_DEPS=false
SYNC_NVIM=true

info() {
  printf '\033[1;34m==>\033[0m %s\n' "$1"
}

ok() {
  printf '\033[1;32mOK\033[0m %s\n' "$1"
}

warn() {
  printf '\033[1;33mWARN\033[0m %s\n' "$1"
}

usage() {
  cat <<USAGE
Usage: ./install.sh [options]

Options:
  --install-deps     Instala paquetes base y herramientas externas.
  --no-nvim-sync     Omite la sincronizacion headless de plugins Neovim.
  -h, --help         Muestra esta ayuda.
USAGE
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --install-deps)
        INSTALL_DEPS=true
        ;;
      --no-nvim-sync)
        SYNC_NVIM=false
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        warn "Opcion desconocida: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_base_packages() {
  if ! command_exists apt-get; then
    warn "apt-get no esta disponible; omito paquetes base"
    return
  fi

  info "Instalando paquetes base"
  sudo apt-get update
  sudo apt-get install -y git tmux ripgrep fd-find xclip zsh curl eza nvim unzip python3.12-venv build-essential cmake
}

ensure_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "Oh My Zsh ya esta instalado"
    return
  fi

  info "Instalando Oh My Zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

ensure_nvm() {
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    ok "NVM ya esta instalado"
    return
  fi

  info "Instalando NVM"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
}

ensure_starship() {
  if command_exists starship; then
    ok "Starship ya esta instalado"
    return
  fi

  info "Instalando Starship"
  mkdir -p "$HOME/.local/bin"
  curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
}

ensure_zoxide() {
  if command_exists zoxide || [ -x "$HOME/.local/bin/zoxide" ]; then
    ok "Zoxide ya esta instalado"
    return
  fi

  info "Instalando Zoxide"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

ensure_fzf() {
  if [ -d "$HOME/.fzf/.git" ]; then
    ok "fzf ya esta instalado"
  else
    info "Instalando fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  fi

  "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
}

ensure_neovim_official() {
  local arch
  arch="$(uname -m)"

  if [ "$arch" != "x86_64" ]; then
    warn "Instalacion oficial de Neovim solo automatizada para x86_64; arch actual: $arch"
    return
  fi

  info "Instalando Neovim oficial en /opt/nvim-linux-x86_64"
  curl -L -o /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
  rm -f /tmp/nvim-linux-x86_64.tar.gz
}

ensure_lazygit() {
  local version arch archive

  if command_exists lazygit; then
    ok "LazyGit ya esta instalado"
    return
  fi

  info "Instalando LazyGit"
  version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": *"v\K[^"]*')"
  arch="$(uname -m | sed 's/aarch64/arm64/')"
  archive="/tmp/lazygit.tar.gz"
  curl -L -o "$archive" "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch}.tar.gz"
  tar -C /tmp -xf "$archive" lazygit
  sudo install /tmp/lazygit -D -t /usr/local/bin/
  rm -f "$archive" /tmp/lazygit
}

ensure_delta() {
  local version arch package

  if command_exists delta; then
    ok "Git Delta ya esta instalado"
    return
  fi

  info "Instalando Git Delta"
  version="$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest | grep -Po '"tag_name": *"\K[^"]*')"
  case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64) arch="arm64" ;;
    *)
      warn "Git Delta no automatizado para arch: $(uname -m)"
      return
      ;;
  esac
  package="/tmp/git-delta_${version}_${arch}.deb"
  curl -L -o "$package" "https://github.com/dandavison/delta/releases/download/${version}/git-delta_${version}_${arch}.deb"
  sudo dpkg -i "$package"
  rm -f "$package"
}

install_dependencies() {
  install_base_packages
  ensure_oh_my_zsh
  ensure_nvm
  ensure_starship
  ensure_zoxide
  ensure_fzf
  ensure_neovim_official
  ensure_lazygit
  ensure_delta
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
  if [ "$SYNC_NVIM" != true ]; then
    warn "Lazy sync omitido por --no-nvim-sync"
    return
  fi

  if ! command -v nvim >/dev/null 2>&1; then
    warn "Neovim no esta instalado; omito Lazy sync"
    return
  fi

  info "Sincronizando plugins de Neovim"
  nvim --headless "+Lazy! sync" +qa
}

main() {
  parse_args "$@"

  info "Instalando dotfiles desde $DOTFILES_DIR"

  if [ "$INSTALL_DEPS" = true ]; then
    install_dependencies
  fi

  link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  link_path "$DOTFILES_DIR/lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
  link_path "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
  link_path "$DOTFILES_DIR/git/gitconfig-personal" "$HOME/.gitconfig-personal"
  link_path "$DOTFILES_DIR/git/gitconfig-work" "$HOME/.gitconfig-work"
  link_path "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
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
