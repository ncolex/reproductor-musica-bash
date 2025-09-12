#!/bin/bash

# Comprobar si se proporcionó un término de búsqueda
if [ -z "$*" ]; then
  echo "Uso: ./musica.sh <nombre de la canción o artista>"
  exit 1
fi

QUERY="$*"
echo "Buscando: '$QUERY'..."

# Obtener los 5 mejores resultados (título e ID de video) y guardarlos en un archivo temporal
# Usamos un archivo temporal para procesar los resultados de forma segura
RESULTS_FILE=$(mktemp)
yt-dlp "ytsearch5:$QUERY" --get-title --get-id > "$RESULTS_FILE"

# Comprobar si se encontraron resultados
if [ ! -s "$RESULTS_FILE" ]; then
    echo "No se encontraron resultados para '$QUERY'."
    rm "$RESULTS_FILE"
    exit 1
fi

# Leer los títulos y los IDs en arrays separados
declare -a titles
declare -a ids
while read -r title; read -r id; do
    titles+=("$title")
    ids+=("$id")
done < "$RESULTS_FILE"

# Limpiar el archivo temporal
rm "$RESULTS_FILE"

# Mostrar la lista numerada de títulos
echo "Resultados de la búsqueda:"
for i in "${!titles[@]}"; do
  printf "%d) %s\n" "$((i+1))" "${titles[$i]}"
done
echo "0) Salir"
echo ""

# Pedir al usuario que elija
read -p "Elige un número para reproducir: " choice

# Validar la elección del usuario
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 0 ] || [ "$choice" -gt "${#titles[@]}" ]; then
  echo "Selección inválida."
  exit 1
fi

# Salir si el usuario elige 0
if [ "$choice" -eq 0 ]; then
  echo "Saliendo."
  exit 0
fi

# Obtener el ID del video seleccionado (ajustando el índice del array)
SELECTED_ID=${ids[$((choice-1))]}
VIDEO_URL="https://www.youtube.com/watch?v=$SELECTED_ID"

echo "Reproduciendo..."

# Usar mpv para reproducir el audio de la URL
mpv --no-video "$VIDEO_URL"