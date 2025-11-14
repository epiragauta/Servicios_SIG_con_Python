#!/bin/bash

echo "=== Iniciando pygeoapi ==="
echo ""

# Verificar directorio
if [ ! -f "config/pygeoapi-config.yml" ]; then
    echo "ERROR: No se encuentra config/pygeoapi-config.yml"
    echo "Asegúrate de estar en el directorio raíz del proyecto"
    exit 1
fi

# Activar entorno virtual
if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d "venv" ]; then
        echo "Activando entorno virtual..."
        source venv/bin/activate
    else
        echo "ERROR: No se encuentra el entorno virtual"
        echo "Por favor, ejecuta primero: ./install_dependencies.sh"
        exit 1
    fi
fi

# Configurar variables de entorno
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml

echo "Configuración: $PYGEOAPI_CONFIG"
echo ""

# Validar configuración
echo "Validando configuración..."
if ! pygeoapi config validate $PYGEOAPI_CONFIG; then
    echo "ERROR: Configuración no válida"
    exit 1
fi
echo "✓ Configuración válida"
echo ""

# Generar OpenAPI
echo "Generando especificación OpenAPI..."
pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI
echo "✓ OpenAPI generado"
echo ""

# Mostrar información del servicio
echo "========================================"
echo "Iniciando servidor pygeoapi"
echo "========================================"
echo ""
echo "URL base: http://localhost:5000"
echo ""
echo "Endpoints principales:"
echo "  - Landing:     http://localhost:5000"
echo "  - OpenAPI:     http://localhost:5000/openapi?f=html"
echo "  - Collections: http://localhost:5000/collections"
echo "  - Amazonas:    http://localhost:5000/collections/amazonas"
echo ""
echo "Presiona Ctrl+C para detener el servidor"
echo "========================================"
echo ""

# Iniciar servidor
pygeoapi serve
