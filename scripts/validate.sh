#!/usr/bin/env bash
# Etapa validate: restaura dependencias y verifica el formato del código.
set -euo pipefail
cd "$(dirname "$0")/.."
source ./scripts/common.sh

SLN="$(find_solution)"
dotnet restore "$SLN"
# Falla si el código no cumple el formato definido en .editorconfig
dotnet format "$SLN" --verify-no-changes --no-restore
