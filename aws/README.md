# AWS

Guia para recrear la configuracion local de AWS sin versionar informacion sensible.

## Requisitos

Instala AWS CLI v2 y `awsp`:

```bash
npm i -g awsp
```

En Ubuntu/WSL, AWS CLI v2 se instala desde el paquete oficial:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip
```

Verifica:

```bash
aws --version
awsp --help
```

## Archivos Locales

La carpeta `~/.aws` debe existir localmente, pero no se versiona completa porque contiene sesiones y credenciales temporales.

Estructura esperada:

```text
~/.aws/
  config
  credentials
  sso/
```

No subas estos archivos al repo:

```text
~/.aws/config
~/.aws/credentials
~/.aws/sso/
```

## Configurar Perfiles SSO

Ejemplo seguro de `~/.aws/config` usando placeholders:

```ini
[profile nombre-del-perfil]
sso_start_url = https://TU-START-URL.awsapps.com/start
sso_region = us-east-1
sso_account_id = 000000000000
sso_role_name = NombreDelRol
region = us-east-1
output = json
```

Agrega una seccion `[profile ...]` por cada cuenta/rol que necesites. Reemplaza `nombre-del-perfil`, `sso_start_url`, `sso_account_id`, `sso_role_name` y `region` con los valores reales de tu organizacion.

## Uso Con Zsh

El `zsh/zshrc` de este repo define:

```zsh
alias awsp="source _awsp"
alias update-aws="bash ~/personal/dotfiles/scripts/update-aws.sh"
```

Despues de instalar los dotfiles o recargar Zsh:

```bash
source ~/.zshrc
```

Selecciona un perfil para la shell actual:

```bash
awsp
```

Refresca sesiones SSO y exporta credenciales temporales a `~/.aws/credentials`:

```bash
update-aws
```

Verifica un perfil:

```bash
aws sts get-caller-identity --profile nombre-del-perfil
```

## Notas

- `scripts/update-aws.sh` esta versionado en este repo.
- El script lee perfiles SSO desde `~/.aws/config`.
- El script escribe credenciales temporales en `~/.aws/credentials`.
- No versionar IDs reales de cuenta, URLs internas, tokens, credenciales ni cache SSO.
