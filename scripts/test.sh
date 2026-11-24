#!/usr/bin/env bash
# Etapa test: ejecuta las pruebas unitarias y deja los resultados en TestResults/.
set -euo pipefail
cd "$(dirname "$0")/.."
source ./scripts/common.sh

SLN="$(find_solution)"
dotnet restore "$SLN"
dotnet test "$SLN" --no-restore --configuration Release \
  --collect:"XPlat Code Coverage" \
  --logger "trx;LogFileName=results.trx" \
  --results-directory ./TestResults
