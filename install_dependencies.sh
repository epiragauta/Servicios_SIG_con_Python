#!/bin/bash

echo "=== Instalación de Dependencias para pygeoapi ==="
echo ""

# Detectar sistema operativo
if [ -f /etc/debian_version ]; then
    echo "Sistema detectado: Debian/Ubuntu"
    echo "Instalando paquetes del sistema..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
    sudo apt-get install -y libgdal-dev gdal-bin
    sudo apt-get install -y libsqlite3-mod-spatialite
elif [ -f /etc/redhat-release ]; then
    echo "Sistema detectado: CentOS/RHEL"
    echo "Instalando paquetes del sistema..."
    sudo yum install -y python3 python3-pip
    sudo yum install -y gdal gdal-devel
elif [ "$(uname)" == "Darwin" ]; then
    echo "Sistema detectado: macOS"
    echo "Instalando paquetes del sistema..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew no está instalado. Por favor, instala Homebrew primero:"
        echo "https://brew.sh"
        exit 1
    fi
    brew install python3
    brew install gdal
else
    echo "Sistema operativo no soportado automáticamente"
    echo "Por favor, instala las dependencias manualmente:"
    echo "- Python 3.8+"
    echo "- pip"
    echo "- GDAL"
    exit 1
fi

echo ""
echo "Verificando instalación de Python..."
python3 --version

echo ""
echo "Verificando instalación de GDAL..."
gdal-config --version

echo ""
echo "Creando entorno virtual..."
python3 -m venv venv

echo ""
echo "Activando entorno virtual..."
source venv/bin/activate

echo ""
echo "Actualizando pip..."
pip install --upgrade pip setuptools wheel

echo ""
echo "=== Instalación completada exitosamente ==="
echo ""
echo "Para activar el entorno virtual en el futuro, ejecuta:"
echo "  source venv/bin/activate"
echo ""
echo "Siguiente paso: Instalar pygeoapi (ver paso2_instalacion.md)"
