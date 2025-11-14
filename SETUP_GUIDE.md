# Guía de Configuración de pygeoapi

Esta guía proporciona un paso a paso completo para configurar pygeoapi y publicar los datos del archivo `amazonas.gpkg` como servicios OGC API.

## Estructura del Proyecto

Cada paso de esta guía está implementado en una rama específica:
- `feature_step_1`: Instalación de dependencias
- `feature_step_2`: Instalación de pygeoapi
- `feature_step_3`: Configuración básica
- `feature_step_4`: Configuración del provider GeoPackage
- `feature_step_5`: Ejecución del servicio
- `feature_step_6`: Pruebas y verificación

---

## Paso 1: Instalación de Dependencias

### Rama: `feature_step_1`

**Objetivo:** Instalar las dependencias necesarias del sistema operativo y Python.

### Requisitos del Sistema
- Python 3.8 o superior
- pip (gestor de paquetes de Python)
- virtualenv (opcional pero recomendado)

### Dependencias del Sistema Operativo

**Para Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv
sudo apt-get install -y libgdal-dev gdal-bin
sudo apt-get install -y libsqlite3-mod-spatialite
```

**Para CentOS/RHEL:**
```bash
sudo yum install -y python3 python3-pip
sudo yum install -y gdal gdal-devel
```

### Crear Entorno Virtual

```bash
# Crear entorno virtual
python3 -m venv venv

# Activar entorno virtual
source venv/bin/activate  # Linux/Mac
# o
venv\Scripts\activate  # Windows
```

### Verificación
```bash
python --version
pip --version
gdal-config --version
```

---

## Paso 2: Instalación de pygeoapi

### Rama: `feature_step_2`

**Objetivo:** Instalar pygeoapi y sus dependencias de Python.

### Instalar pygeoapi

```bash
# Asegúrate de que el entorno virtual esté activado
pip install --upgrade pip
pip install pygeoapi
```

### Dependencias Adicionales

```bash
# Para trabajar con GeoPackage
pip install geopackage

# Para mejorar el rendimiento
pip install gunicorn
```

### Verificación

```bash
pygeoapi --version
pygeoapi openapi generate --help
```

---

## Paso 3: Configuración Básica

### Rama: `feature_step_3`

**Objetivo:** Crear la estructura de directorios y el archivo de configuración base.

### Estructura de Directorios

```bash
mkdir -p config
mkdir -p logs
```

### Crear Configuración Base

Crear archivo `config/pygeoapi-config.yml`:

```yaml
server:
    bind:
        host: 0.0.0.0
        port: 5000
    url: http://localhost:5000
    mimetype: application/json; charset=UTF-8
    encoding: utf-8
    gzip: false
    languages:
        - es
        - en
    cors: true
    pretty_print: true
    limit: 10
    map:
        url: https://tile.openstreetmap.org/{z}/{x}/{y}.png
        attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap contributors</a>'

logging:
    level: INFO
    logfile: logs/pygeoapi.log

metadata:
    identification:
        title: Servicios SIG con Python - Amazonas
        description: API de servicios geoespaciales para datos del Amazonas
        keywords:
            - geoespacial
            - api
            - amazonas
            - SIG
        keywords_type: theme
        terms_of_service: https://creativecommons.org/licenses/by/4.0/
        url: http://localhost:5000
    license:
        name: CC-BY 4.0 license
        url: https://creativecommons.org/licenses/by/4.0/
    provider:
        name: Tu Organización
        url: http://localhost:5000
    contact:
        name: Equipo Técnico
        position: Administrador
        address: Dirección
        city: Ciudad
        stateorprovince: Departamento
        postalcode: 000000
        country: Colombia
        phone: +57-xxx-xxx-xxxx
        email: contacto@ejemplo.com
        url: http://localhost:5000

resources: {}
```

### Verificación

```bash
# Validar configuración
pygeoapi config validate config/pygeoapi-config.yml
```

---

## Paso 4: Configuración del Provider GeoPackage

### Rama: `feature_step_4`

**Objetivo:** Configurar el acceso al archivo amazonas.gpkg como fuente de datos.

### Inspeccionar el GeoPackage

```bash
# Ver las capas disponibles
ogrinfo datos/amazonas.gpkg

# Ver información detallada de una capa
ogrinfo -al datos/amazonas.gpkg nombre_de_capa
```

### Configurar el Recurso

Agregar al archivo `config/pygeoapi-config.yml` en la sección `resources`:

```yaml
resources:
    amazonas:
        type: collection
        title: Datos del Amazonas
        description: Colección de datos geoespaciales del Amazonas
        keywords:
            - amazonas
            - colombia
            - américa del sur
        links:
            - type: text/html
              rel: canonical
              title: Información
              href: http://localhost:5000
              hreflang: es
        extents:
            spatial:
                bbox: [-80, -5, -65, 5]
                crs: http://www.opengis.net/def/crs/OGC/1.3/CRS84
            temporal:
                begin: null
                end: null
        providers:
            - type: feature
              name: OGR
              data:
                  source_type: gpkg
                  source: datos/amazonas.gpkg
                  source_srs: EPSG:4326
                  target_srs: EPSG:4326
                  source_capabilities:
                      paging: True
                  open_options:
                      LIST_ALL_TABLES: NO
                  gdal_ogr_options:
                      EMPTY_AS_NULL: NO
                      GDAL_CACHEMAX: 64
              id_field: fid
              title_field: nombre
```

**Nota:** Deberás ajustar:
- El nombre de la capa en `source` si el geopackage tiene múltiples capas
- Los campos `id_field` y `title_field` según la estructura de tus datos
- El bbox según la extensión real de tus datos

### Verificación

```bash
# Validar configuración actualizada
pygeoapi config validate config/pygeoapi-config.yml

# Generar especificación OpenAPI
pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml
```

---

## Paso 5: Ejecución del Servicio

### Rama: `feature_step_5`

**Objetivo:** Iniciar el servidor pygeoapi y verificar que funciona correctamente.

### Iniciar el Servidor

```bash
# Método 1: Servidor de desarrollo
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml
pygeoapi serve

# Método 2: Con gunicorn (producción)
gunicorn pygeoapi.flask_app:APP \
    --bind 0.0.0.0:5000 \
    --workers 4 \
    --timeout 30 \
    --access-logfile logs/access.log \
    --error-logfile logs/error.log
```

### Crear Script de Inicio

Crear archivo `start.sh`:

```bash
#!/bin/bash

# Activar entorno virtual
source venv/bin/activate

# Configurar variables de entorno
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml

# Generar OpenAPI
pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI

# Iniciar servidor
echo "Iniciando pygeoapi en http://localhost:5000"
pygeoapi serve
```

```bash
chmod +x start.sh
```

### Verificación

```bash
# Ejecutar el script
./start.sh
```

El servidor debería estar disponible en http://localhost:5000

---

## Paso 6: Pruebas y Verificación

### Rama: `feature_step_6`

**Objetivo:** Verificar que todos los endpoints funcionan correctamente.

### Endpoints Principales

1. **Landing Page**
   ```bash
   curl http://localhost:5000/
   ```

2. **Conformance**
   ```bash
   curl http://localhost:5000/conformance
   ```

3. **Especificación OpenAPI**
   ```bash
   curl http://localhost:5000/openapi
   ```

4. **Colecciones**
   ```bash
   curl http://localhost:5000/collections
   ```

5. **Colección Amazonas**
   ```bash
   curl http://localhost:5000/collections/amazonas
   ```

6. **Features (datos)**
   ```bash
   curl http://localhost:5000/collections/amazonas/items
   curl http://localhost:5000/collections/amazonas/items?limit=5
   ```

7. **Feature Individual**
   ```bash
   curl http://localhost:5000/collections/amazonas/items/{feature_id}
   ```

### Script de Pruebas

Crear archivo `test_api.sh`:

```bash
#!/bin/bash

BASE_URL="http://localhost:5000"

echo "=== Probando Landing Page ==="
curl -s "$BASE_URL/" | python -m json.tool

echo -e "\n=== Probando Conformance ==="
curl -s "$BASE_URL/conformance" | python -m json.tool

echo -e "\n=== Probando Colecciones ==="
curl -s "$BASE_URL/collections" | python -m json.tool

echo -e "\n=== Probando Colección Amazonas ==="
curl -s "$BASE_URL/collections/amazonas" | python -m json.tool

echo -e "\n=== Probando Features (primeros 5) ==="
curl -s "$BASE_URL/collections/amazonas/items?limit=5" | python -m json.tool

echo -e "\n=== Pruebas completadas ==="
```

```bash
chmod +x test_api.sh
```

### Pruebas con Python

Crear archivo `test_api.py`:

```python
import requests
import json

BASE_URL = "http://localhost:5000"

def test_endpoint(endpoint, description):
    print(f"\n{'='*60}")
    print(f"Probando: {description}")
    print(f"Endpoint: {endpoint}")
    print('='*60)

    try:
        response = requests.get(f"{BASE_URL}{endpoint}")
        print(f"Status Code: {response.status_code}")

        if response.status_code == 200:
            print("✓ SUCCESS")
            data = response.json()
            print(json.dumps(data, indent=2, ensure_ascii=False)[:500])
        else:
            print("✗ FAILED")
            print(response.text)
    except Exception as e:
        print(f"✗ ERROR: {str(e)}")

if __name__ == "__main__":
    print("Iniciando pruebas de pygeoapi")

    test_endpoint("/", "Landing Page")
    test_endpoint("/conformance", "Conformance Classes")
    test_endpoint("/collections", "Lista de Colecciones")
    test_endpoint("/collections/amazonas", "Colección Amazonas")
    test_endpoint("/collections/amazonas/items?limit=5", "Features de Amazonas")

    print("\n" + "="*60)
    print("Pruebas completadas")
    print("="*60)
```

### Verificación en el Navegador

Abre tu navegador y visita:
- http://localhost:5000 - Página principal
- http://localhost:5000/openapi?f=html - Documentación interactiva

---

## Troubleshooting

### Error: No module named 'pygeoapi'
```bash
# Asegúrate de que el entorno virtual esté activado
source venv/bin/activate
pip install pygeoapi
```

### Error: Cannot open data source
```bash
# Verifica la ruta al archivo
ls -la datos/amazonas.gpkg

# Verifica permisos
chmod 644 datos/amazonas.gpkg
```

### Error: Port already in use
```bash
# Cambiar el puerto en config/pygeoapi-config.yml
# O detener el proceso que usa el puerto 5000
lsof -ti:5000 | xargs kill -9
```

### Error: GDAL not found
```bash
# Ubuntu/Debian
sudo apt-get install -y libgdal-dev gdal-bin

# Luego reinstalar pygeoapi
pip install --force-reinstall pygeoapi
```

---

## Recursos Adicionales

- [Documentación oficial de pygeoapi](https://docs.pygeoapi.io)
- [OGC API - Features](https://ogcapi.ogc.org/features/)
- [GeoPackage Specification](https://www.geopackage.org/)

---

## Próximos Pasos

Una vez completada esta configuración, puedes:
1. Agregar más colecciones desde otros archivos GeoPackage
2. Implementar autenticación y autorización
3. Configurar un proxy inverso (nginx/apache)
4. Agregar más providers (PostGIS, Elasticsearch, etc.)
5. Personalizar el tema y la interfaz web
6. Implementar caché para mejorar rendimiento
7. Configurar SSL/TLS para HTTPS

---

**Última actualización:** 2025-11-07
