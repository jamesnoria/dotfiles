# Dotfiles

Configuracion personal de Neovim y tmux.

## Que incluye

- `nvim/`: configuracion completa de Neovim con `lazy.nvim`.
- `tmux/tmux.conf`: configuracion principal de tmux.
- `tmux/tmux.conf.local`: configuracion local/tema que ya usabas.
- `install.sh`: instalador que crea backups, enlaza archivos y descarga TPM si falta.

No se versionan plugins descargados, caches ni repos externos dentro de `~/.tmux/plugins`.
TPM y Lazy se encargan de descargarlos de nuevo.

## Instalar en otra maquina

```bash
git clone git@github.com:jamesnoria/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Requisitos recomendados

```bash
sudo apt install git tmux neovim ripgrep fd-find
```

En macOS:

```bash
brew install git tmux neovim ripgrep fd
```

## Actualizar el repo con cambios locales

Como el instalador crea symlinks, los cambios hechos en `~/.config/nvim`,
`~/.tmux.conf` o `~/.tmux.conf.local` apuntan a este repo.

```bash
cd ~/dotfiles
git status
git add nvim tmux install.sh README.md
git commit -m "Update nvim and tmux config"
git push
```

## Restaurar backups

El instalador mueve configuraciones existentes a:

```bash
~/.dotfiles-backup/YYYYMMDD_HHMMSS/
```

Puedes copiar o mover esos archivos de regreso si necesitas revertir la instalacion.
