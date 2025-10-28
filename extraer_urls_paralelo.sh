#!/bin/bash

# Archivo de salida temporal para URLs completas
OUTPUT_FILE_TEMP="hosts_temp.txt"
# Archivo de salida final con formato Pi-hole (solo dominios)
OUTPUT_FILE_PIHOLE="hosts_pihole.txt"
# Archivo de salida final con formato Pi-hole y encabezado
OUTPUT_FILE_CON_ENCABEZADO="es_gambling_hosts_pihole.txt"

# Limpiar archivo temporal si existe de ejecuciones anteriores
> "$OUTPUT_FILE_TEMP"

# Rango de páginas a revisar
for page in {0..8}; do
    echo "Procesando página $page..."

    # Descargar contenido de la página (ignorando certificados)
    webpage_content=$(curl -ks "https://www.ordenacionjuego.es/operadores-juego/operadores-licencia/operadores?page=$page")

    # Extraer el contenido dentro del div class="item-list"
    item_list=$(echo "$webpage_content" | awk '/<div class="item-list">/,/<\/div>/')

    # Extraer URLs completas dentro de la sección filtrada y ordenar/eliminar duplicados ya aquí
    extracted_urls=$(echo "$item_list" | grep -oE 'https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u)

    # Añadir URLs completas al archivo temporal solo si se encontraron
    if [[ -n "$extracted_urls" ]]; then
        echo "$extracted_urls" >> "$OUTPUT_FILE_TEMP"
    fi
done

# Verificar si se extrajeron URLs antes de procesar
if [ ! -s "$OUTPUT_FILE_TEMP" ]; then
    echo "Error: No se extrajeron URLs del sitio web. El archivo temporal está vacío."
    exit 1
fi

# Procesar el archivo temporal para formato Pi-hole usando sed con Extended Regex (-E):
# 1. Eliminar http:// o https:// del principio
# 2. Eliminar www. del principio si existe
# 3. Ordenar y eliminar duplicados
# Guardar el resultado en el archivo de salida Pi-hole
sed -E -e 's|^https?://||' -e 's|^www\.||' "$OUTPUT_FILE_TEMP" | sort -u > "$OUTPUT_FILE_PIHOLE"

# Verificar si el archivo Pi-hole se creó correctamente y no está vacío después del sed
if [ ! -s "$OUTPUT_FILE_PIHOLE" ]; then
    echo "Error: El archivo procesado $OUTPUT_FILE_PIHOLE está vacío después de intentar formatear."
    echo "Contenido del archivo temporal ANTES del formateo ($OUTPUT_FILE_TEMP):"
    cat "$OUTPUT_FILE_TEMP"
    # Limpiar temporales aunque falle
    rm "$OUTPUT_FILE_TEMP"
    exit 1
fi

# Contar el número de dominios únicos
domain_count=$(wc -l < "$OUTPUT_FILE_PIHOLE")

# Generar el encabezado con el número de dominios únicos y la fecha actual
header="#  Spanish Gambling Sites
#
# This host file tries to disable all gambling-related websites
# that operates in Spain. Urls provided by the Ministry of Consumer of Spain.
#
# Based on: \"https://www.ordenacionjuego.es/es/url-operadores\" 
#
#
# Number of unique domains: $domain_count
#
# Last update: $(date +"%d-%m-%Y")
#
# ============================================================================
"

# Escribir el encabezado y los dominios en formato Pi-hole en el nuevo archivo final
{
    echo "$header"
    cat "$OUTPUT_FILE_PIHOLE"
} > "$OUTPUT_FILE_CON_ENCABEZADO"

# Limpiar archivos temporales
rm "$OUTPUT_FILE_TEMP"
rm "$OUTPUT_FILE_PIHOLE"

echo "Extracción y formateo para Pi-hole completados."
echo "Se encontraron $domain_count dominios únicos."
echo "El resultado se ha guardado en $OUTPUT_FILE_CON_ENCABEZADO"

# Mostrar las primeras 10 líneas del contenido del nuevo archivo para verificar
echo "Primeras 10 líneas de $OUTPUT_FILE_CON_ENCABEZADO:"
head -n 15 "$OUTPUT_FILE_CON_ENCABEZADO"
