#!/bin/bash

echo "=== Configuración Básica de pygeoapi ==="
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -d "datos" ]; then
    echo "ERROR: No se encuentra el directorio 'datos'"
    echo "Asegúrate de estar en el directorio raíz del proyecto"
    exit 1
fi

# Crear directorios
echo "Creando estructura de directorios..."
mkdir -p config
mkdir -p logs
echo "✓ Directorios creados"

# Verificar que existe el archivo de configuración
if [ ! -f "config/pygeoapi-config.yml" ]; then
    echo "ERROR: No se encuentra config/pygeoapi-config.yml"
    echo "Por favor, crea el archivo de configuración primero"
    exit 1
fi

# Activar entorno virtual
if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d "venv" ]; then
        echo "Activando entorno virtual..."
        source venv/bin/activate
    else
        echo "ADVERTENCIA: No se encontró el entorno virtual"
        echo "Asegúrate de tener pygeoapi instalado"
    fi
fi

# Validar configuración
echo ""
echo "Validando configuración..."
if pygeoapi config validate config/pygeoapi-config.yml 2>/dev/null; then
    echo "✓ Configuración válida"
else
    echo "✗ Error en la configuración"
    echo "Revisa la sintaxis YAML del archivo config/pygeoapi-config.yml"
    exit 1
fi

# Generar OpenAPI
echo ""
echo "Generando especificación OpenAPI..."
pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml
if [ -f "config/openapi.yml" ]; then
    echo "✓ OpenAPI generado en config/openapi.yml"
else
    echo "✗ Error al generar OpenAPI"
    exit 1
fi

echo ""
echo "=== Configuración completada exitosamente ==="
echo ""
echo "Estructura de directorios:"
tree -L 2 -I 'venv|__pycache__|*.pyc' . 2>/dev/null || ls -R
echo ""
echo "Archivos de configuración:"
echo "  config/pygeoapi-config.yml    - Configuración principal"
echo "  config/openapi.yml            - Especificación OpenAPI"
echo ""
echo "Siguiente paso: Configurar el provider GeoPackage (ver paso4_provider.md)"
