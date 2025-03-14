#!/bin/bash

# Nombre del archivo de salida
OUTPUT_FILE="es_gambling_hosts.txt"

# Limpiar el archivo antes de empezar
> "$OUTPUT_FILE"

echo "Extrayendo URLs de apuestas de ordenacionjuego.es..."

# Bucle para recorrer las páginas del 0 al 8
for page in {0..8}; do
    echo "Procesando página $page..."

    # Obtener el contenido de la página ignorando el certificado SSL
    webpage_content=$(curl -ks "https://www.ordenacionjuego.es/operadores-juego/operadores-licencia/operadores?page=$page")

    # Extraer el contenido dentro del div class="item-list"
    item_list=$(echo "$webpage_content" | awk '/<div class="item-list">/,/<\/div>/')

    # Extraer URLs dentro de la sección filtrada
    extracted_urls=$(echo "$item_list" | grep -oP 'https://[a-zA-Z0-9./?=_-]+' | sort -u)

    # Guardar las URLs en el archivo de salida si se encontraron
    if [ -n "$extracted_urls" ]; then
        echo "$extracted_urls" >> "$OUTPUT_FILE"
    else
        echo "No se encontraron URLs en la página $page." >> "$OUTPUT_FILE"
    fi

    # Pequeña pausa para evitar sobrecarga al servidor
    sleep 1
done

echo "Extracción completada. Resultados guardados en $OUTPUT_FILE."
