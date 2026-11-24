#!/usr/bin/env bash
# Etapa quality: análisis estático con SonarQube. El job falla si el quality gate no se cumple.
set -euo pipefail
cd "$(dirname "$0")/.."
source ./scripts/common.sh

: "${SONAR_HOST_URL:?Falta SONAR_HOST_URL en las variables de CI/CD}"
: "${SONAR_TOKEN:?Falta SONAR_TOKEN en las variables de CI/CD}"
SONAR_PROJECT_KEY="${SONAR_PROJECT_KEY:-inventario}"

SLN="$(find_solution)"

# El escáner de .NET necesita Java
if ! command -v java >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y -qq default-jre-headless >/dev/null
fi

dotnet tool install --global dotnet-sonarscanner >/dev/null 2>&1 \
  || dotnet tool update --global dotnet-sonarscanner >/dev/null
export PATH="$PATH:$HOME/.dotnet/tools"

dotnet sonarscanner begin \
  /k:"$SONAR_PROJECT_KEY" \
  /d:sonar.host.url="$SONAR_HOST_URL" \
  /d:sonar.token="$SONAR_TOKEN" \
  /d:sonar.qualitygate.wait=true \
  /d:sonar.cs.vstest.reportsPaths="TestResults/*.trx" \
  /d:sonar.cs.opencover.reportsPaths="TestResults/**/coverage.opencover.xml"

dotnet build "$SLN" --no-incremental --configuration Release
dotnet sonarscanner end /d:sonar.token="$SONAR_TOKEN"
