# Configuración de Neovim

Mi configuración personal de Neovim con lazy.nvim, LSP, Telescope y más.

## ✨ Características

- **Plugin Manager**: lazy.nvim
- **LSP**: Soporte completo con nvim-lspconfig y Mason
- **Formato**: Formatters gestionados por Mason y ejecutados con conform.nvim
- **Fuzzy Finder**: Telescope para búsqueda de archivos y contenido
- **File Explorer**: Neo-tree
- **Sintaxis**: Treesitter para highlighting mejorado
- **Git**: Integración con gitsigns y git-blame
- **UI**: Lualine, bufferline, dashboard
- **Utilidades**: Autopairs, indent-blankline, copilot, kulala

## 📋 Requisitos

### Obligatorios
- Neovim >= 0.9.0
- Git

### Recomendados
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Para búsqueda rápida con Telescope
- [fd](https://github.com/sharkdp/fd) - Para búsqueda de archivos con Telescope
- Node.js - Para algunos LSP servers
- Python 3 - Para algunos LSP servers

## 🚀 Instalación Rápida

### Instalación Automatizada (Recomendado)

```bash
# Clonar este repositorio
git clone https://github.com/TU_USUARIO/nvim-config.git ~/.config/nvim

# Ejecutar el instalador
cd ~/.config/nvim
bash install.sh
```

El script automáticamente:
- ✅ Verifica que Neovim esté instalado
- ✅ Hace backup de tu configuración actual (si existe)
- ✅ Instala lazy.nvim
- ✅ Instala todos los plugins
- ✅ Te ofrece instalar LSP servers básicos

### Instalación Manual

Si prefieres instalar manualmente:

```bash
# 1. Backup de configuración existente (opcional)
mv ~/.config/nvim ~/.config/nvim.backup

# 2. Clonar este repositorio
git clone https://github.com/TU_USUARIO/nvim-config.git ~/.config/nvim

# 3. Abrir Neovim (los plugins se instalarán automáticamente)
nvim
```

## 📦 Instalar Dependencias

### Ubuntu/Debian
```bash
sudo apt install neovim ripgrep fd-find
```

### Fedora
```bash
sudo dnf install neovim ripgrep fd-find
```

### Arch Linux
```bash
sudo pacman -S neovim ripgrep fd
```

### macOS
```bash
brew install neovim ripgrep fd
```

## ⚙️ Configuración Post-Instalación

### Instalar LSP Servers

Abre Neovim y ejecuta:
```vim
:Mason
```

Luego instala los LSP servers que necesites, por ejemplo:
- `lua_ls` - Lua
- `ts_ls` - TypeScript/JavaScript
- `pyright` - Python
- `rust_analyzer` - Rust
- `gopls` - Go

### Instalar Formatters

Los formatters principales se instalan automáticamente con Mason:
- `stylua` - Lua
- `prettier` - JavaScript/TypeScript/HTML/CSS/JSON/YAML/Markdown
- `black` - Python

Puedes revisar el estado del formateo con:
```vim
:ConformInfo
```

### Verificar Salud

```vim
:checkhealth
```

## ⌨️ Atajos de Teclado Principales

### General
- `<leader>` = Espacio (por defecto)
- `<Esc>` - Limpiar búsqueda resaltada
- `bd` - Cerrar buffer actual

### Telescope
- `<leader>ff` - Buscar archivos
- `<leader>fg` - Buscar en contenido (grep)
- `<leader>fb` - Buscar buffers
- `<leader>fh` - Buscar ayuda

### Neo-tree
- `<C-n>` - Toggle Neo-tree
- `<leader>nt` - Revelar archivo actual en Neo-tree
- `<leader>nr` - Restablecer Neo-tree al archivo actual
- `<leader>nf` - Enfocar árbol de archivos
- `<leader>nb` - Ver buffers en Neo-tree
- `<leader>ng` - Ver estado de Git en Neo-tree
- `n` - Crear archivo/carpeta
- `A` - Crear carpeta
- `d` - Eliminar
- `r` - Renombrar
- `y` - Copiar al clipboard
- `x` - Cortar
- `p` - Pegar
- `s` - Abrir en split horizontal
- `v` - Abrir en split vertical
- `t` - Abrir en tab
- `H` - Mostrar/ocultar archivos ocultos
- `/` - Buscar dentro del árbol

### LSP
- `gd` - Ir a definición
- `gr` - Ver referencias
- `K` - Mostrar documentación
- `<leader>ca` - Acciones de código
- `<leader>rn` - Renombrar símbolo
- `<leader>f` - Formatear archivo

### Git
- `<leader>gb` - Toggle git blame

## 📁 Estructura del Proyecto

```
~/.config/nvim/
├── init.lua              # Punto de entrada principal
├── install.sh            # Script de instalación
├── lazy-lock.json        # Versiones bloqueadas de plugins
└── lua/
    ├── config/
    │   ├── lazy.lua      # Configuración de lazy.nvim
    │   └── keymaps.lua   # Keymaps personalizados
    └── plugins/          # Configuraciones de plugins
        ├── lsp.lua
        ├── telescope.lua
        ├── treesitter.lua
        ├── neotree.lua
        ├── lualine.lua
        ├── colorscheme.lua
        ├── copilot.lua
        └── ...
```

## 🔄 Actualizar Configuración

Si clonaste desde Git:

```bash
cd ~/.config/nvim
git pull
nvim "+Lazy! sync" +qa
```

## 🐛 Solución de Problemas

### Los plugins no se instalan
```vim
:Lazy sync
```

### LSP no funciona
```vim
:LspInfo
:Mason
```

### Errores de salud
```vim
:checkhealth
```

### Restaurar backup
```bash
rm -rf ~/.config/nvim
mv ~/.config/nvim.backup.YYYYMMDD_HHMMSS ~/.config/nvim
```

## 🤝 Contribuir

Si encuentras algún problema o tienes sugerencias:
1. Abre un issue
2. Crea un pull request

## 📝 Licencia

MIT License - Siéntete libre de usar y modificar esta configuración.

## 🙏 Créditos

Esta configuración utiliza los siguientes proyectos increíbles:
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Y muchos más plugins excelentes...
