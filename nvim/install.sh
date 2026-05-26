#!/bin/bash

# Script de instalación para configuración de Neovim
# Autor: James Noria
# Uso: bash install.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_msg() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Verificar que Neovim está instalado
check_neovim() {
    print_msg "Verificando instalación de Neovim..."
    
    if ! command -v nvim &> /dev/null; then
        print_error "Neovim no está instalado"
        echo ""
        echo "Por favor instala Neovim primero:"
        echo "  Ubuntu/Debian: sudo apt install neovim"
        echo "  Fedora: sudo dnf install neovim"
        echo "  Arch: sudo pacman -S neovim"
        echo "  macOS: brew install neovim"
        echo ""
        echo "O descarga desde: https://github.com/neovim/neovim/releases"
        exit 1
    fi
    
    local nvim_version=$(nvim --version | head -n 1)
    print_success "Neovim encontrado: $nvim_version"
}

# Verificar dependencias opcionales pero recomendadas
check_dependencies() {
    print_msg "Verificando dependencias opcionales..."
    
    local missing_deps=()
    
    # Verificar herramientas útiles
    if ! command -v rg &> /dev/null; then
        missing_deps+=("ripgrep")
    fi
    
    if ! command -v fd &> /dev/null; then
        missing_deps+=("fd-find")
    fi
    
    if ! command -v git &> /dev/null; then
        print_error "Git es requerido y no está instalado"
        exit 1
    fi
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_success "Todas las dependencias están instaladas"
    else
        print_warning "Dependencias opcionales no encontradas: ${missing_deps[*]}"
        echo "  Estas herramientas mejoran la experiencia con Telescope"
        echo "  Ubuntu/Debian: sudo apt install ripgrep fd-find"
        echo "  Fedora: sudo dnf install ripgrep fd-find"
        echo "  Arch: sudo pacman -S ripgrep fd"
        echo "  macOS: brew install ripgrep fd"
    fi
}

# Hacer backup de la configuración existente
backup_existing_config() {
    local config_dir="$HOME/.config/nvim"
    
    if [ -d "$config_dir" ]; then
        local backup_dir="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        print_msg "Respaldando configuración existente..."
        mv "$config_dir" "$backup_dir"
        print_success "Backup guardado en: $backup_dir"
    fi
}

# Instalar la configuración
install_config() {
    local config_dir="$HOME/.config/nvim"
    local repo_url="https://github.com/jamesnoria/neovim_config"
    
    print_msg "Instalando configuración de Neovim..."
    
    # Crear directorio de config si no existe
    mkdir -p "$(dirname "$config_dir")"
    
    # Clonar el repositorio
    print_msg "Clonando configuración desde $repo_url..."
    git clone "$repo_url" "$config_dir"
    print_success "Configuración clonada a $config_dir"
}

# Instalar lazy.nvim
install_lazy() {
    local lazy_path="$HOME/.local/share/nvim/site/pack/lazy/opt/lazy.nvim"
    
    print_msg "Instalando lazy.nvim..."
    
    if [ -d "$lazy_path" ]; then
        print_success "lazy.nvim ya está instalado"
    else
        git clone --filter=blob:none https://github.com/folke/lazy.nvim.git \
            --branch=stable "$lazy_path"
        print_success "lazy.nvim instalado"
    fi
}

# Instalar plugins
install_plugins() {
    print_msg "Instalando plugins de Neovim..."
    print_warning "Esto puede tomar algunos minutos..."
    
    # Ejecutar Neovim en modo headless para instalar plugins
    nvim --headless "+Lazy! sync" +qa
    
    print_success "Plugins instalados correctamente"
}

# Instalar LSP servers
install_lsp_servers() {
    print_msg "¿Deseas instalar LSP servers ahora? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_msg "Instalando LSP servers básicos..."
        print_warning "Esto instalará: lua_ls, ts_ls, pyright"
        
        nvim --headless "+LspInstall lua_ls ts_ls pyright" +qa 2>/dev/null || true
        
        print_success "LSP servers instalados (si Mason está configurado)"
        echo "  Puedes instalar más LSPs desde Neovim con :Mason"
    else
        print_warning "Puedes instalar LSPs después con :Mason desde Neovim"
    fi
}

# Mostrar mensaje final
show_completion_message() {
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  Instalación completada!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "  1. Ejecuta: nvim"
    echo "  2. Espera a que los plugins terminen de cargar"
    echo "  3. Usa :Mason para instalar LSP servers adicionales"
    echo "  4. Usa :checkhealth para verificar que todo funciona"
    echo ""
    echo "Comandos útiles:"
    echo "  :Lazy - Administrar plugins"
    echo "  :Mason - Instalar LSP servers"
    echo "  :checkhealth - Verificar configuración"
    echo ""
    echo "Atajos de teclado:"
    echo "  <leader>ff - Buscar archivos"
    echo "  <leader>fg - Buscar en contenido"
    echo "  <C-n> - Abrir Neo-tree"
    echo ""
    
    if [ -n "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Nota: Tu configuración anterior fue respaldada en:${NC}"
        echo "  $BACKUP_DIR"
        echo ""
    fi
}

# Función principal
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Instalador de Configuración Neovim  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificaciones
    check_neovim
    check_dependencies
    
    # Preguntar si hacer backup
    if [ -d "$HOME/.config/nvim" ]; then
        echo ""
        print_warning "Se encontró una configuración existente de Neovim"
        echo "¿Deseas hacer un backup antes de continuar? (Y/n)"
        read -r response
        
        if [[ ! "$response" =~ ^([nN][oO]|[nN])$ ]]; then
            backup_existing_config
            BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        else
            rm -rf "$HOME/.config/nvim"
            print_warning "Configuración anterior eliminada sin backup"
        fi
    fi
    
    # Instalación
    install_config
    install_lazy
    install_plugins
    
    echo ""
    install_lsp_servers
    
    # Mensaje final
    show_completion_message
}

# Ejecutar script principal
main
