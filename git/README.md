# Git Profiles

Esta configuracion separa Git personal y Git de trabajo segun la carpeta donde
esta cada repo.

## Estructura

- `gitconfig`: config principal que usa `includeIf`.
- `gitconfig-personal`: identidad personal y reglas para GitHub personal.
- `gitconfig-work`: identidad de trabajo.
- `ssh-config.example`: ejemplo de hosts SSH para GitHub.

El instalador enlaza estos archivos como:

```bash
~/.gitconfig -> ~/personal/dotfiles/git/gitconfig
~/.gitconfig-personal -> ~/personal/dotfiles/git/gitconfig-personal
~/.gitconfig-work -> ~/personal/dotfiles/git/gitconfig-work
```

## Como Funciona

`~/.gitconfig` carga una config distinta segun la ruta del repo:

```gitconfig
[includeIf "gitdir:~/personal/"]
  path = ~/.gitconfig-personal

[includeIf "gitdir:~/work/"]
  path = ~/.gitconfig-work
```

Repos bajo `~/personal/` usan:

```gitconfig
[user]
  email = contact@jamesnoria.com
  name = James Noria
```

Repos bajo `~/work/` usan:

```gitconfig
[user]
  email = james.noria@rimac.com.pe
  name = James Noria
```

## GitHub Personal

En `gitconfig-personal` hay esta regla:

```gitconfig
[url "git@github-personal:"]
  insteadOf = git@github.com:
```

Eso significa que, dentro de `~/personal/`, un remote como este:

```bash
git@github.com:jamesnoria/dotfiles.git
```

Git lo usa como si fuera:

```bash
git@github-personal:jamesnoria/dotfiles.git
```

El host `github-personal` debe existir en `~/.ssh/config` y apuntar a la llave
SSH personal.

## Configurar SSH

Crear llave personal:

```bash
ssh-keygen -t ed25519 -C "contact@jamesnoria.com" -f ~/.ssh/github_personal
```

Crear llave de trabajo, si no existe:

```bash
ssh-keygen -t ed25519 -C "james.noria@rimac.com.pe" -f ~/.ssh/id_ed25519
```

Agregar hosts en `~/.ssh/config`:

```sshconfig
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_personal
  IdentitiesOnly yes

Host github-work
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

Si tambien usas `github.com` directamente para trabajo, puedes dejar una entrada
separada para `github.com` apuntando a la llave de trabajo.

## Agregar Llaves a GitHub

Mostrar llave publica personal:

```bash
cat ~/.ssh/github_personal.pub
```

Mostrar llave publica de trabajo:

```bash
cat ~/.ssh/id_ed25519.pub
```

Agregar cada llave en la cuenta correcta:

```text
GitHub -> Settings -> SSH and GPG keys -> New SSH key
```

No subas ni compartas archivos sin `.pub`. Esos son llaves privadas.

## Verificar Autenticacion

Personal:

```bash
ssh -T git@github-personal
```

Resultado esperado:

```text
Hi jamesnoria! You've successfully authenticated, but GitHub does not provide shell access.
```

Default o trabajo:

```bash
ssh -T git@github.com
```

Si responde con la cuenta incorrecta, revisa `~/.ssh/config` y la llave asociada
a ese host.

## Verificar Una Repo

Dentro de una repo personal:

```bash
git config --show-origin --get user.email
git config --show-origin --get-regexp '^url\.'
git remote -v
```

Debe mostrar `contact@jamesnoria.com` y la regla `github-personal`.

Dentro de una repo de trabajo:

```bash
git config --show-origin --get user.email
git config --show-origin --get-regexp '^url\.' || true
git remote -v
```

Debe mostrar `james.noria@rimac.com.pe`. No deberia heredar la regla personal.

## Corregir Remote

Para forzar una repo personal a usar el host personal:

```bash
git remote set-url origin git@github-personal:jamesnoria/dotfiles.git
```

Tambien puedes dejar el remote como `git@github.com:owner/repo.git` si la repo
esta bajo `~/personal/`, porque `insteadOf` lo reescribe automaticamente.

Para revisar que el push funcionaria sin empujar nada:

```bash
git push --dry-run origin main
```

## Que No Se Versiona

No versionar nunca:

- `~/.ssh/github_personal`
- `~/.ssh/id_ed25519`
- tokens de GitHub
- `~/.config/gh/hosts.yml`
- archivos con passwords, webhooks o secretos

Solo se versionan configs reproducibles y ejemplos sin secretos.

## Troubleshooting

Si `git push` dice que no tienes permisos:

```bash
ssh -T git@github.com
ssh -T git@github-personal
git remote -v
```

Si `git@github.com` autentica como cuenta de trabajo dentro de `~/personal/`,
confirma que esta activa la regla:

```bash
git config --show-origin --get-regexp '^url\.'
```

Si no aparece, confirma que la repo este dentro de `~/personal/` y que
`~/.gitconfig` sea el symlink correcto.

```bash
readlink ~/.gitconfig
git config --show-origin --get user.email
```
