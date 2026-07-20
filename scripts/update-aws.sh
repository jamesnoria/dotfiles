#!/bin/bash

# Script para refrescar sesiones AWS SSO seleccionadas
# y almacenar credenciales temporales en ~/.aws/credentials

# Colores para salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

open_browser_url() {
    local url="$1"

    if [ -z "$url" ]; then
        return 1
    fi

    if command -v wslview >/dev/null 2>&1; then
        wslview "$url" >/dev/null 2>&1
        return 0
    fi

    if command -v cmd.exe >/dev/null 2>&1; then
        cmd.exe /c start "" "$url" >/dev/null 2>&1
        return 0
    fi

    if command -v rundll32.exe >/dev/null 2>&1; then
        rundll32.exe url.dll,FileProtocolHandler "$url" >/dev/null 2>&1
        return 0
    fi

    if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command 'Start-Process -FilePath $args[0]' "$url" >/dev/null 2>&1
        return 0
    fi

    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url" >/dev/null 2>&1
        return 0
    fi

    return 1
}

login_url_with_code() {
    local url="$1"
    local code="$2"

    if [ -z "$url" ] || [ -z "$code" ]; then
        return 1
    fi

    if [[ "$url" == *user_code=* ]]; then
        printf "%s" "$url"
    elif [[ "$url" == *\?* ]]; then
        printf "%s&user_code=%s" "$url" "$code"
    else
        printf "%s?user_code=%s" "$url" "$code"
    fi
}

select_profiles_interactive() {
    local profiles=("$@")
    local selected=()
    local current=0
    local key
    local key_extra
    local old_stty

    if [ ! -t 0 ]; then
        return 1
    fi

    for _ in "${profiles[@]}"; do
        selected+=(0)
    done

    old_stty=$(stty -g < /dev/tty)
    stty -echo < /dev/tty
    tput civis > /dev/tty 2>/dev/null || true

    while true; do
        printf "\033[H\033[J" > /dev/tty
        echo -e "${YELLOW}Selecciona los perfiles a actualizar:${NC}" > /dev/tty
        echo "Usa ↑/↓ para moverte, espacio para marcar [x], Enter para confirmar, q para cancelar." > /dev/tty
        echo "" > /dev/tty

        for i in "${!profiles[@]}"; do
            local marker=" "
            local prefix="  "

            if [ "${selected[$i]}" -eq 1 ]; then
                marker="x"
            fi

            if [ "$i" -eq "$current" ]; then
                prefix="> "
            fi

            printf "%s[%s] %s\n" "$prefix" "$marker" "${profiles[$i]}" > /dev/tty
        done

        IFS= read -rsn1 key < /dev/tty

        case "$key" in
            $'\x1b')
                IFS= read -rsn2 -t 0.1 key_extra < /dev/tty
                case "$key_extra" in
                    "[A")
                        if [ "$current" -gt 0 ]; then
                            ((current--))
                        fi
                        ;;
                    "[B")
                        if [ "$current" -lt "$((${#profiles[@]} - 1))" ]; then
                            ((current++))
                        fi
                        ;;
                esac
                ;;
            " ")
                if [ "${selected[$current]}" -eq 1 ]; then
                    selected[$current]=0
                else
                    selected[$current]=1
                fi
                ;;
            "")
                break
                ;;
            q|Q)
                stty "$old_stty" < /dev/tty
                tput cnorm > /dev/tty 2>/dev/null || true
                printf "\033[H\033[J" > /dev/tty
                return 2
                ;;
        esac
    done

    stty "$old_stty" < /dev/tty
    tput cnorm > /dev/tty 2>/dev/null || true
    printf "\033[H\033[J" > /dev/tty

    for i in "${!profiles[@]}"; do
        if [ "${selected[$i]}" -eq 1 ]; then
            printf "%s\n" "${profiles[$i]}"
        fi
    done
}

echo "🔄 Iniciando actualización de sesiones AWS SSO..."

# Obtiene únicamente los perfiles que usan SSO desde ~/.aws/config
mapfile -t PROFILES < <(
    awk '
        /^\[profile [^]]+\]$/ {
            if (profile != "" && has_sso) print profile
            profile=$0
            sub(/^\[profile /, "", profile)
            sub(/\]$/, "", profile)
            has_sso=0
            next
        }

        /^\[/ {
            if (profile != "" && has_sso) print profile
            profile=""
            has_sso=0
            next
        }

        profile != "" && /^[[:space:]]*sso_/ { has_sso=1 }

        END {
            if (profile != "" && has_sso) print profile
        }
    ' ~/.aws/config
)

# Verifica si se encontraron perfiles
if [ ${#PROFILES[@]} -eq 0 ]; then
    echo -e "${RED}❌ No se encontraron perfiles SSO configurados en ~/.aws/config${NC}"
    exit 1
fi

echo -e "${YELLOW}Perfiles SSO encontrados:${NC}"
for i in "${!PROFILES[@]}"; do
    printf "%d) %s\n" "$((i + 1))" "${PROFILES[$i]}"
done
echo ""

SELECTED_PROFILES=()

if [ -t 0 ]; then
    TEMP_SELECTION=$(mktemp)
    select_profiles_interactive "${PROFILES[@]}" > "$TEMP_SELECTION"
    SELECT_STATUS=$?
    mapfile -t SELECTED_PROFILES < "$TEMP_SELECTION"
    rm -f "$TEMP_SELECTION"

    if [ "$SELECT_STATUS" -eq 2 ]; then
        echo -e "${YELLOW}Selección cancelada.${NC}"
        exit 0
    fi
else
    echo -e "${YELLOW}Selecciona los perfiles a actualizar:${NC}"
    echo "- Usa números separados por espacio o coma. Ejemplo: 1 3 5"
    echo "- Escribe 'all' para actualizar todos"
    read -r -p "Perfiles: " PROFILE_SELECTION

    if [ -z "$PROFILE_SELECTION" ]; then
        echo -e "${YELLOW}No se seleccionó ningún perfil. Cancelando.${NC}"
        exit 0
    fi

    if [[ "$PROFILE_SELECTION" =~ ^([aA][lL][lL]|[tT][oO][dD][oO][sS])$ ]]; then
        SELECTED_PROFILES=("${PROFILES[@]}")
    else
    PROFILE_SELECTION=${PROFILE_SELECTION//,/ }

        for SELECTED_INDEX in $PROFILE_SELECTION; do
            if ! [[ "$SELECTED_INDEX" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}❌ Selección inválida:${NC} $SELECTED_INDEX"
                exit 1
            fi

            PROFILE_POSITION=$((SELECTED_INDEX - 1))
            if [ "$PROFILE_POSITION" -lt 0 ] || [ "$PROFILE_POSITION" -ge "${#PROFILES[@]}" ]; then
                echo -e "${RED}❌ Número fuera de rango:${NC} $SELECTED_INDEX"
                exit 1
            fi

            SELECTED_PROFILES+=("${PROFILES[$PROFILE_POSITION]}")
        done
    fi
fi

if [ ${#SELECTED_PROFILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}No se seleccionó ningún perfil. Cancelando.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Perfiles seleccionados:${NC}"
for PROFILE in "${SELECTED_PROFILES[@]}"; do
    echo "- $PROFILE"
done
echo ""

# Contador para sesiones exitosas
SUCCESS_COUNT=0

# Para cada perfil seleccionado, intenta iniciar sesión SSO
for PROFILE in "${SELECTED_PROFILES[@]}"; do
    echo -e "${YELLOW}Actualizando sesión para perfil:${NC} $PROFILE"
        
        # Crear un archivo temporal para capturar la salida
        TEMP_OUTPUT=$(mktemp)
        
        # Ejecutar aws sso login en background y capturar su salida en tiempo real.
        # En WSL abrimos la URL manualmente en Windows para evitar que AWS CLI
        # intente usar un navegador Linux que no existe.
        aws sso login --profile "$PROFILE" --no-browser --use-device-code 2>&1 | tee "$TEMP_OUTPUT" &
        SSO_PID=$!

        URL_OPENED=0
        CODE_COPIED=0

        # Esperar hasta que AWS imprima la URL y el código de verificación.
        for _ in {1..30}; do
            LOGIN_URL=$(grep -Eo 'https://[^[:space:]]+' "$TEMP_OUTPUT" 2>/dev/null | grep -m1 'user_code=')
            if [ -z "$LOGIN_URL" ]; then
                LOGIN_URL=$(grep -Eo 'https://[^[:space:]]+' "$TEMP_OUTPUT" 2>/dev/null | head -1)
            fi
            VERIFICATION_CODE=$(grep -oP '[A-Z]{4}-[A-Z]{4}' "$TEMP_OUTPUT" 2>/dev/null | head -1)

            if [ "$URL_OPENED" -eq 0 ] && [ -n "$LOGIN_URL" ] && [ -n "$VERIFICATION_CODE" ]; then
                LOGIN_URL_COMPLETE=$(login_url_with_code "$LOGIN_URL" "$VERIFICATION_CODE")

                if open_browser_url "$LOGIN_URL_COMPLETE"; then
                    echo -e "${GREEN}🌐 Link abierto en el navegador con el código:${NC} $LOGIN_URL_COMPLETE"
                else
                    echo -e "${YELLOW}⚠️  No se pudo abrir el navegador automáticamente. Abre este link:${NC} $LOGIN_URL_COMPLETE"
                fi
                URL_OPENED=1
            fi

            if [ "$CODE_COPIED" -eq 0 ] && [ -n "$VERIFICATION_CODE" ]; then
                # Usar OSC 52 para copiar al portapapeles (funciona en Windows Terminal, tmux, etc)
                printf "\033]52;c;$(printf "%s" "$VERIFICATION_CODE" | base64 -w0)\a"
                echo -e "${GREEN}📋 Código copiado al portapapeles:${NC} $VERIFICATION_CODE"
                CODE_COPIED=1
            fi

            if [ "$URL_OPENED" -eq 1 ] && [ "$CODE_COPIED" -eq 1 ]; then
                break
            fi

            if ! kill -0 "$SSO_PID" 2>/dev/null; then
                break
            fi

            sleep 1
        done

        if [ "$URL_OPENED" -eq 0 ]; then
            echo -e "${YELLOW}⚠️  No se pudo detectar el link de login${NC}"
        fi

        if [ "$CODE_COPIED" -eq 0 ]; then
            echo -e "${YELLOW}⚠️  No se pudo detectar el código de verificación${NC}"
        fi
        
        # Esperar a que termine el proceso de login
        wait $SSO_PID
        LOGIN_STATUS=$?
        
        # Limpiar archivo temporal
        rm -f "$TEMP_OUTPUT"
        
        # Verifica si el login fue exitoso
        if [ $LOGIN_STATUS -eq 0 ]; then
            echo -e "${GREEN}✅ Sesión actualizada exitosamente para:${NC} $PROFILE"
            
            # Exportar credenciales temporales al archivo credentials
            echo -e "${YELLOW}Exportando credenciales para:${NC} $PROFILE"
            
            # Exportar credenciales usando el perfil SSO activo
            aws sts get-caller-identity --profile "$PROFILE" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                SESSION_OUTPUT=$(aws configure export-credentials --profile "$PROFILE" --format env-no-export 2>/dev/null)

                if [ $? -eq 0 ]; then
                    AWS_ACCESS_KEY_ID=$(printf '%s\n' "$SESSION_OUTPUT" | sed -n 's/^AWS_ACCESS_KEY_ID=//p')
                    AWS_SECRET_ACCESS_KEY=$(printf '%s\n' "$SESSION_OUTPUT" | sed -n 's/^AWS_SECRET_ACCESS_KEY=//p')
                    AWS_SESSION_TOKEN=$(printf '%s\n' "$SESSION_OUTPUT" | sed -n 's/^AWS_SESSION_TOKEN=//p')

                    # Eliminar únicamente el contenido de la sección existente.
                    sed -i "/^\[$PROFILE\]$/,/^\[/{ /^\[$PROFILE\]$/d; /^\[/!d; }" ~/.aws/credentials 2>/dev/null || true

                    {
                        echo "[$PROFILE]"
                        echo "aws_access_key_id = $AWS_ACCESS_KEY_ID"
                        echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY"
                        echo "aws_session_token = $AWS_SESSION_TOKEN"
                        echo ""
                    } >> ~/.aws/credentials

                    echo -e "${GREEN}✅ Credenciales exportadas exitosamente para:${NC} $PROFILE"
                else
                    echo -e "${RED}❌ No se pudieron exportar credenciales para:${NC} $PROFILE"
                fi
            else
                echo -e "${RED}❌ No se pudo obtener identidad para:${NC} $PROFILE"
            fi
            
            ((SUCCESS_COUNT++))
        else
            echo -e "${RED}❌ Error al actualizar sesión para:${NC} $PROFILE"
        fi
    echo "-----------------------------------"
done

echo ""
echo -e "${GREEN}📊 Resumen: $SUCCESS_COUNT sesiones actualizadas exitosamente${NC}"
echo -e "${YELLOW}📝 Puedes verificar tus credenciales con:${NC} aws sts get-caller-identity --profile <nombre-del-perfil>"
echo -e "${YELLOW}📝 Credenciales almacenadas en:${NC} ~/.aws/credentials"#
