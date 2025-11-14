#!/bin/bash

echo "=== Instalación de pygeoapi ==="
echo ""

# Verificar que el entorno virtual está activado
if [ -z "$VIRTUAL_ENV" ]; then
    echo "ERROR: El entorno virtual no está activado"
    echo "Por favor, ejecuta: source venv/bin/activate"
    exit 1
fi

echo "Entorno virtual detectado: $VIRTUAL_ENV"
echo ""

# Actualizar pip
echo "Actualizando pip, setuptools y wheel..."
pip install --upgrade pip setuptools wheel

echo ""
echo "Instalando pygeoapi..."
pip install pygeoapi

echo ""
echo "Instalando GDAL para Python..."
if command -v gdal-config &> /dev/null; then
    GDAL_VERSION=$(gdal-config --version)
    echo "Versión de GDAL detectada: $GDAL_VERSION"
    pip install GDAL==$GDAL_VERSION
else
    echo "Advertencia: gdal-config no encontrado"
    echo "Intentando instalar GDAL sin especificar versión..."
    pip install GDAL
fi

echo ""
echo "Instalando dependencias adicionales..."
pip install gunicorn requests jsonschema

echo ""
echo "Generando requirements.txt..."
pip freeze > requirements.txt
echo "requirements.txt creado con $(wc -l < requirements.txt) paquetes"

echo ""
echo "Verificando instalación..."
echo "----------------------------------------"

# Verificar pygeoapi
if command -v pygeoapi &> /dev/null; then
    echo "✓ pygeoapi instalado correctamente"
    pygeoapi --version
else
    echo "✗ Error: pygeoapi no se instaló correctamente"
    exit 1
fi

# Verificar GDAL en Python
if python -c "from osgeo import gdal" 2>/dev/null; then
    GDAL_PY_VERSION=$(python -c "from osgeo import gdal; print(gdal.__version__)")
    echo "✓ GDAL Python instalado: versión $GDAL_PY_VERSION"
else
    echo "✗ Advertencia: GDAL no se pudo importar en Python"
fi

echo "----------------------------------------"
echo ""
echo "=== Instalación completada exitosamente ==="
echo ""
echo "Comandos disponibles:"
echo "  pygeoapi --help       - Ver ayuda general"
echo "  pygeoapi config       - Gestión de configuración"
echo "  pygeoapi openapi      - Gestión de OpenAPI"
echo "  pygeoapi serve        - Iniciar servidor"
echo ""
echo "Archivos creados:"
echo "  requirements.txt      - Lista de dependencias"
echo ""
echo "Siguiente paso: Configuración básica (ver paso3_configuracion.md)"
