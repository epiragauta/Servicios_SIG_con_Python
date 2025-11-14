#!/bin/bash

echo "=== Configuración del Provider GeoPackage ==="
echo ""

# Verificar que existe el GeoPackage
if [ ! -f "datos/amazonas.gpkg" ]; then
    echo "ERROR: No se encuentra datos/amazonas.gpkg"
    exit 1
fi

echo "✓ GeoPackage encontrado: datos/amazonas.gpkg"
FILE_SIZE=$(du -h datos/amazonas.gpkg | cut -f1)
echo "  Tamaño: $FILE_SIZE"
echo ""

# Inspeccionar el GeoPackage
echo "Inspeccionando GeoPackage..."
echo "========================================"
if [ -f "inspect_gpkg.py" ]; then
    python3 inspect_gpkg.py
else
    echo "ADVERTENCIA: inspect_gpkg.py no encontrado"
    echo "Saltando inspección detallada..."
fi
echo ""

# Verificar configuración
echo "Validando configuración de pygeoapi..."

if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d "venv" ]; then
        echo "Activando entorno virtual..."
        source venv/bin/activate
    fi
fi

if [ -f "config/pygeoapi-config.yml" ]; then
    if pygeoapi config validate config/pygeoapi-config.yml 2>/dev/null; then
        echo "✓ Configuración válida"
    else
        echo "✗ Error en la configuración"
        echo "Revisa config/pygeoapi-config.yml"
        echo "Asegúrate de que:"
        echo "  - El recurso 'amazonas' está definido"
        echo "  - La ruta al GeoPackage es correcta"
        echo "  - Los campos id_field y title_field existen en los datos"
        exit 1
    fi
else
    echo "ERROR: No se encuentra config/pygeoapi-config.yml"
    exit 1
fi

# Regenerar OpenAPI
echo ""
echo "Regenerando especificación OpenAPI..."
pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml
if [ -f "config/openapi.yml" ]; then
    echo "✓ OpenAPI actualizado"
else
    echo "✗ Error al generar OpenAPI"
    exit 1
fi

echo ""
echo "=== Configuración del provider completada ==="
echo ""
echo "Resumen de la configuración:"
echo "  - Fuente de datos: datos/amazonas.gpkg"
echo "  - Archivo de configuración: config/pygeoapi-config.yml"
echo "  - Especificación OpenAPI: config/openapi.yml"
echo ""
echo "Para verificar, puedes:"
echo "  1. Ver la configuración: cat config/pygeoapi-config.yml"
echo "  2. Iniciar el servidor: ./start.sh (ver paso5_ejecucion.md)"
echo "  3. Acceder a: http://localhost:5000/collections/amazonas"
echo ""
echo "Siguiente paso: Ejecución del servicio (ver paso5_ejecucion.md)"
