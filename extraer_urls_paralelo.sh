#!/bin/bash
# Archivo: extraer_y_generar_hosts.sh
# Descripción: Descarga en paralelo las páginas 0 a 8 de la web, extrae las URLs de los enlaces
#              dentro de los <td> con headers="view-field-links-table-column", descartando
#              aquellos enlaces cuyos dominios sean "gob.es" u "ordenacionjuego.es". Luego,
#              genera un archivo es_gambling_hosts.txt con un encabezado detallado y las URLs únicas.
# Uso: chmod +x extraer_y_generar_hosts.sh && ./extraer_y_generar_hosts.sh

# Nombre del archivo de salida
output_file="es_gambling_hosts.txt"
temp_dir=$(mktemp -d)

# Obtener la fecha actual en la zona horaria de Madrid
fecha_actual=$(TZ='Europe/Madrid' date '+%d-%m-%Y')

# Descarga y procesamiento en paralelo de las páginas 0 a 8
for page in {0..8}; do
    url="https://www.ordenacionjuego.es/operadores-juego/operadores-licencia/operadores?page=$page"
    echo "Procesando: $url" >&2
    (
        html=$(curl -s "$url")
        echo "$html" | sed -n '/<td headers="view-field-links-table-column"/,/<\/td>/p' \
            | grep -Eo 'href="https://[^"]+"' \
            | cut -d'"' -f2 \
            | grep -ivE 'gob\.es|ordenacionjuego\.es' > "$temp_dir/page_$page.txt"
    ) &
done

# Esperar a que todos los procesos en background terminen
wait

# Combinar los resultados, eliminar duplicados y ordenar
cat "$temp_dir"/*.txt | sort -u > "$temp_dir/urls_extraidas.txt"

# Contar el número de dominios únicos
num_dominios=$(wc -l < "$temp_dir/urls_extraidas.txt")

# Escribir el encabezado en el archivo de salida
cat <<EOL > "$output_file"
#   Spanish Gambling Sites
#
# Este archivo de hosts intenta deshabilitar todos los sitios web relacionados con el juego
# que operan en España. URLs proporcionadas por el Ministerio de Consumo de España.
#
# Basado en: "https://www.ordenacionjuego.es/operadores-juego/operadores-licencia/operadores"
#
#
# Número de dominios únicos: $num_dominios
#
# Última actualización: $fecha_actual
#
# ============================================================================
#
EOL

# Añadir las URLs únicas al archivo de salida
cat "$temp_dir/urls_extraidas.txt" >> "$output_file"

# Eliminar el directorio temporal
rm -r "$temp_dir"

echo "Archivo de hosts generado en $output_file"
