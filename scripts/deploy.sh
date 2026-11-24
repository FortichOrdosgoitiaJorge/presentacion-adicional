#!/usr/bin/env bash
# Despliegue por SSH de una imagen ya publicada en el registro.
# Uso: deploy.sh <dev|qa|staging|production> <imagen:tag>
#
# Requiere (variables de CI/CD del entorno): DEPLOY_HOST, DEPLOY_USER, DB_PASSWORD.
# Requiere (variables predefinidas): CI_REGISTRY, CI_REGISTRY_USER, CI_REGISTRY_PASSWORD.
# La llave SSH está en ~/.ssh/id_deploy (la prepara el job en before_script).
set -euo pipefail
cd "$(dirname "$0")/.."

ENV_NAME="${1:?uso: deploy.sh <dev|qa|staging|production> <imagen:tag>}"
IMAGE="${2:?falta la imagen a desplegar}"

: "${DEPLOY_HOST:?Falta DEPLOY_HOST para el entorno $ENV_NAME}"
: "${DEPLOY_USER:?Falta DEPLOY_USER para el entorno $ENV_NAME}"
: "${DB_PASSWORD:?Falta DB_PASSWORD para el entorno $ENV_NAME}"
: "${CI_REGISTRY:?Variable predefinida CI_REGISTRY no disponible}"

case "$ENV_NAME" in
  dev)        ASPNET_ENV="Development" ;;
  qa)         ASPNET_ENV="QA" ;;
  staging)    ASPNET_ENV="Staging" ;;
  production) ASPNET_ENV="Production" ;;
  *) echo "ERROR: entorno desconocido: $ENV_NAME" >&2; exit 1 ;;
esac

SSH_OPTS=(-i "$HOME/.ssh/id_deploy" -o StrictHostKeyChecking=accept-new -o BatchMode=yes)
TARGET="$DEPLOY_USER@$DEPLOY_HOST"
APP_DIR="/opt/inventario/$ENV_NAME"

# 1) Copia el archivo de Compose del repositorio al servidor
ssh "${SSH_OPTS[@]}" "$TARGET" "mkdir -p '$APP_DIR'"
scp "${SSH_OPTS[@]}" deploy/docker-compose.yml "$TARGET:$APP_DIR/docker-compose.yml"

# 2) Ejecuta el despliegue. Los secretos viajan por la entrada estándar, no como argumentos.
{
  printf 'IMAGE=%q\n' "$IMAGE"
  printf 'APP_DIR=%q\n' "$APP_DIR"
  printf 'ASPNETCORE_ENVIRONMENT=%q\n' "$ASPNET_ENV"
  printf 'DB_PASSWORD=%q\n' "$DB_PASSWORD"
  printf 'REG=%q\n' "$CI_REGISTRY"
  printf 'REG_USER=%q\n' "$CI_REGISTRY_USER"
  printf 'REG_PASS=%q\n' "$CI_REGISTRY_PASSWORD"
  cat <<'REMOTE'
set -euo pipefail
echo "$REG_PASS" | docker login -u "$REG_USER" --password-stdin "$REG"
docker pull "$IMAGE"
cd "$APP_DIR"
export IMAGE ASPNETCORE_ENVIRONMENT DB_PASSWORD
docker compose up -d --remove-orphans
docker image prune -f >/dev/null
docker compose ps
REMOTE
} | ssh "${SSH_OPTS[@]}" "$TARGET" "bash -s"

echo "Despliegue de $IMAGE en $ENV_NAME completado."
