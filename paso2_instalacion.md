# Paso 2: Instalación de pygeoapi

Este paso cubre la instalación de pygeoapi y todas sus dependencias de Python necesarias para trabajar con archivos GeoPackage.

## Prerequisitos

- Haber completado el Paso 1 (instalación de dependencias del sistema)
- Entorno virtual activado

## 1. Verificar Entorno Virtual

Asegúrate de que el entorno virtual está activado:

```bash
# Si no está activado, ejecuta:
source venv/bin/activate

# Deberías ver (venv) en tu prompt
```

## 2. Actualizar pip

```bash
pip install --upgrade pip setuptools wheel
```

## 3. Instalar pygeoapi

```bash
pip install pygeoapi
```

Esta instalación incluye:
- pygeoapi y sus dependencias core
- Flask (framework web)
- Soporte para diferentes formatos de datos
- Herramientas de línea de comandos

## 4. Instalar Dependencias Adicionales

### Para trabajar con GeoPackage:

```bash
pip install GDAL
```

**Nota:** Si tienes problemas instalando GDAL con pip, puedes usar:

```bash
# Obtener la versión de GDAL del sistema
gdal-config --version

# Instalar la versión correspondiente de Python GDAL
pip install GDAL==$(gdal-config --version)
```

### Para mejorar el rendimiento en producción:

```bash
pip install gunicorn
```

### Dependencias opcionales pero recomendadas:

```bash
# Para soporte de Elasticsearch
pip install elasticsearch

# Para soporte de PostgreSQL/PostGIS
pip install psycopg2-binary

# Para mejor manejo de requests
pip install requests

# Para validación de esquemas
pip install jsonschema
```

## 5. Crear archivo requirements.txt

Es buena práctica documentar las dependencias:

```bash
pip freeze > requirements.txt
```

Esto creará un archivo con todas las dependencias instaladas y sus versiones exactas.

## 6. Verificar Instalación

### Verificar que pygeoapi está instalado:

```bash
pygeoapi --version
```

### Verificar comandos disponibles:

```bash
pygeoapi --help
```

Deberías ver algo como:

```
Usage: pygeoapi [OPTIONS] COMMAND [ARGS]...

  pygeoapi command line interface

Commands:
  config    Configuration management
  openapi   OpenAPI management
  serve     Serve pygeoapi
```

### Verificar comandos específicos:

```bash
# Ayuda de configuración
pygeoapi config --help

# Ayuda de OpenAPI
pygeoapi openapi --help

# Ayuda del servidor
pygeoapi serve --help
```

## 7. Script de Instalación

Para facilitar el proceso, puedes usar este script:

**install_pygeoapi.sh:**

```bash
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
echo "Actualizando pip..."
pip install --upgrade pip setuptools wheel

echo ""
echo "Instalando pygeoapi..."
pip install pygeoapi

echo ""
echo "Instalando GDAL para Python..."
GDAL_VERSION=$(gdal-config --version)
pip install GDAL==$GDAL_VERSION

echo ""
echo "Instalando dependencias adicionales..."
pip install gunicorn requests jsonschema

echo ""
echo "Generando requirements.txt..."
pip freeze > requirements.txt

echo ""
echo "Verificando instalación..."
pygeoapi --version

echo ""
echo "=== Instalación completada exitosamente ==="
echo ""
echo "Comandos disponibles:"
echo "  pygeoapi --help       - Ver ayuda general"
echo "  pygeoapi config       - Gestión de configuración"
echo "  pygeoapi openapi      - Gestión de OpenAPI"
echo "  pygeoapi serve        - Iniciar servidor"
echo ""
echo "Siguiente paso: Configuración básica (ver paso3_configuracion.md)"
```

## 8. Verificar GDAL en Python

Verifica que GDAL está correctamente instalado en Python:

```bash
python -c "from osgeo import gdal, ogr; print(f'GDAL: {gdal.__version__}')"
```

## Solución de Problemas

### Error: Failed building wheel for GDAL

Si GDAL falla al instalarse:

**Solución 1 - Especificar versión:**
```bash
gdal-config --version  # Anota la versión, por ejemplo 3.0.4
pip install GDAL==3.0.4
```

**Solución 2 - Usar variables de entorno:**
```bash
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
pip install GDAL==$(gdal-config --version)
```

**Solución 3 - Instalar desde repositorio del sistema:**
```bash
# Ubuntu/Debian
sudo apt-get install python3-gdal

# Luego crear un enlace simbólico al entorno virtual
```

### Error: pygeoapi: command not found

Si el comando no se encuentra después de la instalación:

```bash
# Verificar que el entorno virtual está activado
which python  # Debería apuntar a venv/bin/python

# Reinstalar pygeoapi
pip uninstall pygeoapi
pip install pygeoapi
```

### Error: ModuleNotFoundError

Si faltan módulos:

```bash
# Reinstalar todas las dependencias
pip install -r requirements.txt

# O reinstalar pygeoapi con todas sus dependencias
pip install --upgrade --force-reinstall pygeoapi
```

## Verificación Final

Ejecuta estos comandos para verificar que todo está correcto:

```bash
# 1. Verificar Python
python --version

# 2. Verificar pip
pip --version

# 3. Verificar pygeoapi
pygeoapi --version

# 4. Verificar GDAL
python -c "from osgeo import gdal; print(f'GDAL {gdal.__version__}')"

# 5. Ver paquetes instalados
pip list | grep -E "pygeoapi|GDAL|Flask|gunicorn"
```

## Siguiente Paso

Una vez completada la instalación de pygeoapi, continúa con:
- **Paso 3:** Configuración básica (rama `feature_step_3`)

## Checklist de Verificación

- [ ] Entorno virtual activado
- [ ] pip actualizado
- [ ] pygeoapi instalado
- [ ] GDAL para Python instalado
- [ ] gunicorn instalado
- [ ] requirements.txt creado
- [ ] Comando `pygeoapi --version` funciona
- [ ] GDAL importable en Python

---

**Referencia:** Ver [SETUP_GUIDE.md](SETUP_GUIDE.md) para la guía completa.
