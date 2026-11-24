#!/usr/bin/env bash
# Etapa security: falla si alguna dependencia (directa o transitiva) tiene vulnerabilidades conocidas.
set -euo pipefail
cd "$(dirname "$0")/.."
source ./scripts/common.sh

SLN="$(find_solution)"
dotnet restore "$SLN"

REPORT="$(dotnet list "$SLN" package --vulnerable --include-transitive)"
echo "$REPORT"

if echo "$REPORT" | grep -q "has the following vulnerable packages"; then
  echo "ERROR: se encontraron paquetes vulnerables. Actualice las dependencias antes de integrar." >&2
  exit 1
fi
echo "Sin paquetes vulnerables conocidos."
