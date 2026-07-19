# Dotfiles

Configuracion personal de Neovim, tmux, LazyGit, Git, Starship y Zsh.

## Que incluye

- `nvim/`: configuracion completa de Neovim con `lazy.nvim`.
- `lazygit/config.yml`: configuracion de LazyGit con iconos Nerd Fonts.
- `git/`: configuracion de Git para separar repos personales y de trabajo.
- `starship/starship.toml`: configuracion del prompt Starship.
- `tmux/tmux.conf`: configuracion principal de tmux.
- `tmux/tmux.conf.local`: configuracion local/tema que ya usabas.
- `zsh/zshrc`: configuracion de Zsh, aliases y herramientas de shell.
- `install.sh`: instalador que crea backups, enlaza archivos y descarga TPM si falta.

No se versionan plugins descargados, caches ni repos externos dentro de `~/.tmux/plugins`.
TPM y Lazy se encargan de descargarlos de nuevo.

## Requisitos

### Paquetes base en Ubuntu/Debian

```bash
sudo apt update
sudo apt install git tmux ripgrep fd-find xclip wl-clipboard zsh curl eza nvim unzip python3.12-venv
chsh -s "$(command -v zsh)"
```

En sesiones Wayland, `wl-clipboard` es importante para que Neovim, tmux y apps
de terminal lean el mismo portapapeles. Si solo esta `xclip`, Neovim puede pegar
contenido viejo aunque otra app haya copiado texto correctamente.

### NVM

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

Luego abre una nueva terminal o carga `nvm` en la sesion actual antes de
instalar Node.js.

Neovim no se instala con `apt`: esta configuracion espera la version oficial
ubicada en `/opt/nvim-linux-x86_64`.

### Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Starship

El prompt requiere una [Nerd Font](https://www.nerdfonts.com/font-downloads)
configurada en la terminal.

```bash
mkdir -p "$HOME/.local/bin"
curl -sS https://starship.rs/install.sh | sh -s -- -b "$HOME/.local/bin"
```

### Zoxide

```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

### fzf

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

### Neovim desde el release oficial

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm nvim-linux-x86_64.tar.gz
```

La ruta `/opt/nvim-linux-x86_64/bin` ya esta incluida en `zsh/zshrc`.

### LazyGit desde el release oficial

```bash
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": *"v\K[^"]*')
LAZYGIT_ARCH=$(uname -m | sed 's/aarch64/arm64/')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm lazygit lazygit.tar.gz
```

### Git Delta

Descarga el paquete `.deb` apropiado desde los
[releases oficiales de Git Delta](https://github.com/dandavison/delta/releases)
y luego instalalo:

```bash
sudo dpkg -i git-delta_*_amd64.deb
```

El ejecutable instalado se llama `delta`. LazyGit ya esta configurado para
usarlo como pager.

### macOS

```bash
brew install git tmux neovim ripgrep fd zsh starship zoxide lazygit git-delta eza
```

## Instalar los dotfiles

Una vez instalados los requisitos:

```bash
git clone git@github.com:jamesnoria/dotfiles.git ~/personal/dotfiles
cd ~/personal/dotfiles
./install.sh
```

Para instalar tambien paquetes base y herramientas externas:

```bash
./install.sh --install-deps
```

Ese modo instala paquetes base con `apt`, Oh My Zsh, NVM, Starship, Zoxide,
fzf, Neovim oficial, LazyGit, Git Delta, TPM y sincroniza plugins de Neovim.

Si solo quieres enlazar dotfiles sin sincronizar plugins de Neovim:

```bash
./install.sh --no-nvim-sync
```

## Actualizar el repo con cambios locales

Como el instalador crea symlinks, los cambios hechos en `~/.config/nvim`,
`~/.config/lazygit/config.yml`, `~/.config/starship.toml`, `~/.gitconfig`,
`~/.gitconfig-personal`, `~/.gitconfig-work`, `~/.tmux.conf`,
`~/.tmux.conf.local` o `~/.zshrc` apuntan a este repo.

```bash
cd ~/personal/dotfiles
git status
git add nvim lazygit git starship tmux zsh install.sh README.md
git commit -m "Update dotfiles configuration"
git push
```

## Git personal y trabajo

La configuracion principal usa `includeIf`:

- Repos bajo `~/personal/` usan `~/.gitconfig-personal`.
- Repos bajo `~/work/` usan `~/.gitconfig-work`.

Para GitHub personal, `~/.gitconfig-personal` reescribe `git@github.com:` a
`git@github-personal:`. El alias SSH esperado esta documentado en
`git/ssh-config.example`. No se versionan llaves SSH ni tokens.

## Restaurar backups

El instalador mueve configuraciones existentes a:

```bash
~/.dotfiles-backup/YYYYMMDD_HHMMSS/
```

Puedes copiar o mover esos archivos de regreso si necesitas revertir la instalacion.
