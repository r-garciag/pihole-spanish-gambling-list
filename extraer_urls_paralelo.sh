#!/bin/bash

# Archivo de salida
OUTPUT_FILE="hosts.txt"
OUTPUT_FILE_CON_ENCABEZADO="es_gambling_hosts.txt"

# Rango de páginas a revisar
for page in {0..8}; do
    echo "Procesando página $page..."
    
    # Descargar contenido de la página (ignorando certificados)
    webpage_content=$(curl -ks "https://www.ordenacionjuego.es/operadores-juego/operadores-licencia/operadores?page=$page")

    # Extraer el contenido dentro del div class="item-list"
    item_list=$(echo "$webpage_content" | awk '/<div class="item-list">/,/<\/div>/')
    # Extraer URLs dentro de la sección filtrada
    extracted_urls=$(echo "$item_list" | grep -oE 'https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u)

    # Añadir URLs al archivo solo si se encontraron
    if [[ -n "$extracted_urls" ]]; then
        echo "$extracted_urls" >> "$OUTPUT_FILE"
    fi
done

# Ordenar y eliminar duplicados
sort -u -o "$OUTPUT_FILE" "$OUTPUT_FILE"

# Contar el número de dominios únicos (sin rutas repetidas)
url_count=$(grep -Eo 'https?://[^/"]+' "$OUTPUT_FILE" | sort -u | wc -l)

# Generar el encabezado con el número de dominios únicos y la fecha actual
header="#  Spanish Gambling Sites
#
# This host file tries to disable all gambling-related websites
# that operates in Spain. Urls provided by the Ministry of Consumer of Spain.
#
# Based on: \"https://www.ordenacionjuego.es/es/url-operadores\"
#
#
# Number of unique domains: $url_count
#
# Last update: $(date +"%d-%m-%Y")
#
# ============================================================================
"

# Escribir el encabezado y las URLs en el nuevo archivo
{
    echo "$header"
    cat "$OUTPUT_FILE"
} > "$OUTPUT_FILE_CON_ENCABEZADO"

echo "Extracción completa. Se encontraron $url_count dominios únicos. El resultado se ha guardado en $OUTPUT_FILE_CON_ENCABEZADO"

# Mostrar el contenido del nuevo archivo
echo "Contenido de $OUTPUT_FILE_CON_ENCABEZADO:"
cat "$OUTPUT_FILE_CON_ENCABEZADO"
