# Paso 1: Instalación de Dependencias

Este es el primer paso para configurar pygeoapi. Aquí instalaremos todas las dependencias necesarias del sistema operativo y Python.

## Requisitos del Sistema

- Python 3.8 o superior
- pip (gestor de paquetes de Python)
- virtualenv (opcional pero recomendado)
- GDAL (Geospatial Data Abstraction Library)

## 1. Instalar Dependencias del Sistema Operativo

### Para Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv
sudo apt-get install -y libgdal-dev gdal-bin
sudo apt-get install -y libsqlite3-mod-spatialite
```

### Para CentOS/RHEL:

```bash
sudo yum install -y python3 python3-pip
sudo yum install -y gdal gdal-devel
```

### Para macOS (con Homebrew):

```bash
brew install python3
brew install gdal
```

## 2. Crear y Activar Entorno Virtual

Es altamente recomendable usar un entorno virtual para aislar las dependencias del proyecto:

```bash
# Crear entorno virtual en el directorio del proyecto
python3 -m venv venv

# Activar entorno virtual
# Linux/Mac:
source venv/bin/activate

# Windows:
venv\Scripts\activate
```

Una vez activado, tu prompt debería mostrar `(venv)` al inicio.

## 3. Actualizar pip

```bash
pip install --upgrade pip setuptools wheel
```

## 4. Verificar Instalación

Verifica que todas las herramientas estén instaladas correctamente:

```bash
# Verificar Python
python --version
# Debería mostrar Python 3.8 o superior

# Verificar pip
pip --version

# Verificar GDAL
gdal-config --version

# Verificar que GDAL está disponible en Python
python -c "from osgeo import gdal; print(f'GDAL {gdal.__version__}')"
```

## 5. Script de Instalación Automática

Para facilitar el proceso, puedes usar este script:

**install_dependencies.sh:**

```bash
#!/bin/bash

echo "=== Instalación de Dependencias para pygeoapi ==="

# Detectar sistema operativo
if [ -f /etc/debian_version ]; then
    echo "Detectado: Debian/Ubuntu"
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
    sudo apt-get install -y libgdal-dev gdal-bin
    sudo apt-get install -y libsqlite3-mod-spatialite
elif [ -f /etc/redhat-release ]; then
    echo "Detectado: CentOS/RHEL"
    sudo yum install -y python3 python3-pip
    sudo yum install -y gdal gdal-devel
else
    echo "Sistema operativo no soportado automáticamente"
    echo "Por favor, instala las dependencias manualmente"
    exit 1
fi

# Crear entorno virtual
echo "Creando entorno virtual..."
python3 -m venv venv

# Activar entorno virtual
echo "Activando entorno virtual..."
source venv/bin/activate

# Actualizar pip
echo "Actualizando pip..."
pip install --upgrade pip setuptools wheel

echo "=== Instalación completada ==="
echo "Para activar el entorno virtual en el futuro, ejecuta:"
echo "source venv/bin/activate"
```

Guarda el script y ejecútalo:

```bash
chmod +x install_dependencies.sh
./install_dependencies.sh
```

## Solución de Problemas

### Error: Python no encontrado

Si `python3` no está disponible:
```bash
# Ubuntu/Debian
sudo apt-get install python3

# CentOS/RHEL
sudo yum install python3
```

### Error: GDAL no encontrado

Si GDAL no se instala correctamente:
```bash
# Ubuntu/Debian
sudo add-apt-repository ppa:ubuntugis/ppa
sudo apt-get update
sudo apt-get install gdal-bin libgdal-dev

# Verificar versión
gdal-config --version
```

### Error: Permission denied

Si encuentras errores de permisos:
```bash
# Usa sudo para comandos del sistema
sudo apt-get install ...

# NO uses sudo para pip dentro del entorno virtual
pip install ...
```

## Siguiente Paso

Una vez completada la instalación de dependencias, continúa con:
- **Paso 2:** Instalación de pygeoapi (rama `feature_step_2`)

## Checklist de Verificación

- [ ] Python 3.8+ instalado
- [ ] pip actualizado
- [ ] GDAL instalado y funcionando
- [ ] Entorno virtual creado
- [ ] Entorno virtual activado
- [ ] Todas las verificaciones pasadas

---

**Referencia:** Ver [SETUP_GUIDE.md](SETUP_GUIDE.md) para la guía completa.
