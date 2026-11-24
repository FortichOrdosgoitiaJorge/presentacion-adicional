#!/usr/bin/env bash
# Funciones compartidas por los scripts del pipeline. Se carga con: source ./scripts/common.sh

find_solution() {
  local sln
  sln="$(find . -name '*.sln' -not -path './.git/*' -not -path '*/obj/*' -not -path '*/bin/*' | head -n 1)"
  if [ -z "$sln" ]; then
    echo "ERROR: no se encontró ningún archivo .sln en el repositorio." >&2
    echo "       El proyecto de la aplicación todavía no existe; el pipeline no puede continuar." >&2
    exit 1
  fi
  echo "$sln"
}
