# Paso 4: Configuración del Provider GeoPackage

Este paso cubre la configuración del acceso al archivo `amazonas.gpkg` como fuente de datos en pygeoapi.

## Prerequisitos

- Haber completado el Paso 1 (instalación de dependencias)
- Haber completado el Paso 2 (instalación de pygeoapi)
- Haber completado el Paso 3 (configuración básica)
- Tener el archivo `datos/amazonas.gpkg` disponible

## 1. Inspeccionar el GeoPackage

Antes de configurar el provider, es importante conocer la estructura del GeoPackage.

### Usando ogrinfo (si está disponible):

```bash
# Ver todas las capas
ogrinfo datos/amazonas.gpkg

# Ver información detallada de una capa específica
ogrinfo -al datos/amazonas.gpkg <nombre_capa>

# Ver solo los nombres de campos
ogrinfo -so datos/amazonas.gpkg <nombre_capa>
```

### Usando Python:

```python
from osgeo import ogr

# Abrir el GeoPackage
ds = ogr.Open('datos/amazonas.gpkg')

# Listar capas
print(f"Número de capas: {ds.GetLayerCount()}")
for i in range(ds.GetLayerCount()):
    layer = ds.GetLayerByIndex(i)
    print(f"Capa {i}: {layer.GetName()} ({layer.GetFeatureCount()} features)")

# Obtener información de campos de una capa
layer = ds.GetLayerByIndex(0)
layer_defn = layer.GetLayerDefn()
print(f"\nCampos de {layer.GetName()}:")
for i in range(layer_defn.GetFieldCount()):
    field_defn = layer_defn.GetFieldDefn(i)
    print(f"  - {field_defn.GetName()} ({field_defn.GetTypeName()})")
```

### Script de inspección:

```bash
#!/bin/bash
python3 << 'EOF'
from osgeo import ogr
import json

gpkg_path = 'datos/amazonas.gpkg'
ds = ogr.Open(gpkg_path)

if ds is None:
    print(f"No se pudo abrir {gpkg_path}")
    exit(1)

print(f"GeoPackage: {gpkg_path}")
print(f"Número de capas: {ds.GetLayerCount()}\n")

for i in range(ds.GetLayerCount()):
    layer = ds.GetLayerByIndex(i)
    spatial_ref = layer.GetSpatialRef()
    extent = layer.GetExtent()

    print(f"Capa {i+1}: {layer.GetName()}")
    print(f"  Features: {layer.GetFeatureCount()}")
    print(f"  Geometría: {ogr.GeometryTypeToName(layer.GetGeomType())}")
    if spatial_ref:
        print(f"  SRS: {spatial_ref.GetAuthorityName(None)}:{spatial_ref.GetAuthorityCode(None)}")
    print(f"  Extensión: {extent}")

    layer_defn = layer.GetLayerDefn()
    print(f"  Campos:")
    for j in range(layer_defn.GetFieldCount()):
        field = layer_defn.GetFieldDefn(j)
        print(f"    - {field.GetName()} ({field.GetTypeName()})")
    print()
EOF
```

## 2. Configurar el Recurso en pygeoapi

Edita el archivo `config/pygeoapi-config.yml` y agrega la configuración del recurso en la sección `resources`.

### Configuración Básica:

```yaml
resources:
    amazonas:
        type: collection
        title:
            es: Datos del Amazonas
            en: Amazon Data
        description:
            es: Colección de datos geoespaciales del Amazonas
            en: Geospatial data collection from the Amazon
        keywords:
            - amazonas
            - colombia
            - américa del sur
            - biodiversidad
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

### Parámetros Importantes:

- **source**: Ruta al archivo GeoPackage (relativa o absoluta)
- **source_srs**: Sistema de referencia espacial de origen (ej: EPSG:4326)
- **target_srs**: Sistema de referencia espacial de salida
- **id_field**: Campo que se usará como identificador único
- **title_field**: Campo que se usará como título/nombre del feature
- **bbox**: Extensión espacial [minx, miny, maxx, maxy]

### Ajustar según tu GeoPackage:

1. **Si el GeoPackage tiene múltiples capas:**

```yaml
providers:
    - type: feature
      name: OGR
      data:
          source_type: gpkg
          source: datos/amazonas.gpkg
          source_layer: nombre_capa_especifica
          source_srs: EPSG:4326
```

2. **Si necesitas filtrar features:**

```yaml
providers:
    - type: feature
      name: OGR
      data:
          source_type: gpkg
          source: datos/amazonas.gpkg
          source_layer: mi_capa
          sql: SELECT * FROM mi_capa WHERE tipo = 'especial'
```

3. **Si los campos tienen nombres diferentes:**

```yaml
providers:
    - type: feature
      name: OGR
      data:
          source_type: gpkg
          source: datos/amazonas.gpkg
      id_field: gid           # Ajusta al nombre real
      title_field: nombre     # Ajusta al nombre real
      # O usa otro campo disponible en tus datos
```

## 3. Script de Configuración del Provider

Crea el script `config_provider.sh`:

```bash
#!/bin/bash

echo "=== Configuración del Provider GeoPackage ==="
echo ""

# Verificar que existe el GeoPackage
if [ ! -f "datos/amazonas.gpkg" ]; then
    echo "ERROR: No se encuentra datos/amazonas.gpkg"
    exit 1
fi

echo "✓ GeoPackage encontrado: datos/amazonas.gpkg"
echo ""

# Inspeccionar el GeoPackage
echo "Inspeccionando GeoPackage..."
python3 inspect_gpkg.py

# Verificar configuración
echo ""
echo "Validando configuración de pygeoapi..."

if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
fi

if pygeoapi config validate config/pygeoapi-config.yml; then
    echo "✓ Configuración válida"
else
    echo "✗ Error en la configuración"
    echo "Revisa config/pygeoapi-config.yml"
    exit 1
fi

# Regenerar OpenAPI
echo ""
echo "Regenerando especificación OpenAPI..."
pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml
echo "✓ OpenAPI actualizado"

echo ""
echo "=== Configuración del provider completada ==="
echo ""
echo "Para verificar, puedes:"
echo "  1. Ver la configuración: cat config/pygeoapi-config.yml"
echo "  2. Iniciar el servidor: ./start.sh"
echo "  3. Acceder a: http://localhost:5000/collections/amazonas"
echo ""
echo "Siguiente paso: Ejecución del servicio (ver paso5_ejecucion.md)"
```

## 4. Script de Inspección del GeoPackage

Crea el archivo `inspect_gpkg.py`:

```python
#!/usr/bin/env python3
"""
Script para inspeccionar el contenido de un GeoPackage
"""

from osgeo import ogr
import sys
import os

def inspect_geopackage(gpkg_path):
    """Inspecciona un archivo GeoPackage y muestra su información"""

    if not os.path.exists(gpkg_path):
        print(f"ERROR: No se encuentra el archivo {gpkg_path}")
        sys.exit(1)

    # Abrir el GeoPackage
    ds = ogr.Open(gpkg_path)
    if ds is None:
        print(f"ERROR: No se pudo abrir {gpkg_path}")
        sys.exit(1)

    print(f"GeoPackage: {gpkg_path}")
    print(f"Número de capas: {ds.GetLayerCount()}")
    print("=" * 70)

    # Iterar sobre las capas
    for i in range(ds.GetLayerCount()):
        layer = ds.GetLayerByIndex(i)
        layer_name = layer.GetName()
        feature_count = layer.GetFeatureCount()
        geom_type = ogr.GeometryTypeToName(layer.GetGeomType())

        print(f"\nCapa {i+1}: {layer_name}")
        print("-" * 70)
        print(f"  Número de features: {feature_count}")
        print(f"  Tipo de geometría: {geom_type}")

        # Sistema de referencia espacial
        spatial_ref = layer.GetSpatialRef()
        if spatial_ref:
            auth_name = spatial_ref.GetAuthorityName(None)
            auth_code = spatial_ref.GetAuthorityCode(None)
            if auth_name and auth_code:
                print(f"  Sistema de referencia: {auth_name}:{auth_code}")
        else:
            print("  Sistema de referencia: No definido")

        # Extensión espacial
        try:
            extent = layer.GetExtent()
            print(f"  Extensión (minx, maxx, miny, maxy):")
            print(f"    X: [{extent[0]:.6f}, {extent[1]:.6f}]")
            print(f"    Y: [{extent[2]:.6f}, {extent[3]:.6f}]")
            print(f"  Bbox para pygeoapi: [{extent[0]:.2f}, {extent[2]:.2f}, {extent[1]:.2f}, {extent[3]:.2f}]")
        except:
            print("  Extensión: No disponible")

        # Campos
        layer_defn = layer.GetLayerDefn()
        field_count = layer_defn.GetFieldCount()
        print(f"  Campos ({field_count}):")

        for j in range(field_count):
            field_defn = layer_defn.GetFieldDefn(j)
            field_name = field_defn.GetName()
            field_type = field_defn.GetTypeName()
            field_width = field_defn.GetWidth()
            print(f"    - {field_name} ({field_type}, ancho: {field_width})")

        # Mostrar un feature de ejemplo
        layer.ResetReading()
        feature = layer.GetNextFeature()
        if feature:
            print(f"  Feature de ejemplo (ID: {feature.GetFID()}):")
            for j in range(layer_defn.GetFieldCount()):
                field_name = layer_defn.GetFieldDefn(j).GetName()
                field_value = feature.GetField(j)
                print(f"    {field_name}: {field_value}")

    ds = None
    print("\n" + "=" * 70)
    print("Inspección completada")

if __name__ == "__main__":
    gpkg_path = "datos/amazonas.gpkg"

    if len(sys.argv) > 1:
        gpkg_path = sys.argv[1]

    inspect_geopackage(gpkg_path)
```

Hazlo ejecutable:
```bash
chmod +x inspect_gpkg.py
```

Ejecútalo:
```bash
./inspect_gpkg.py
# o
python3 inspect_gpkg.py datos/amazonas.gpkg
```

## 5. Validar la Configuración

```bash
# Activar entorno virtual
source venv/bin/activate

# Validar configuración
pygeoapi config validate config/pygeoapi-config.yml

# Si es válida, regenerar OpenAPI
pygeoapi openapi generate config/pygeoapi-config.yml > config/openapi.yml
```

## 6. Probar Acceso al GeoPackage

Crea un script de prueba `test_gpkg.py`:

```python
#!/usr/bin/env python3
"""
Script para probar el acceso al GeoPackage
"""

from osgeo import ogr

gpkg_path = 'datos/amazonas.gpkg'

# Abrir el GeoPackage
ds = ogr.Open(gpkg_path)

if ds is None:
    print("ERROR: No se pudo abrir el GeoPackage")
    exit(1)

print("✓ GeoPackage abierto correctamente")

# Obtener la primera capa
layer = ds.GetLayerByIndex(0)
print(f"✓ Capa: {layer.GetName()}")
print(f"✓ Features: {layer.GetFeatureCount()}")

# Leer un feature
feature = layer.GetNextFeature()
if feature:
    print(f"✓ Lectura de feature exitosa (ID: {feature.GetFID()})")
else:
    print("✗ No se pudo leer feature")

ds = None
print("✓ Prueba completada exitosamente")
```

## Solución de Problemas

### Error: Cannot open data source

```bash
# Verificar que el archivo existe
ls -la datos/amazonas.gpkg

# Verificar permisos
chmod 644 datos/amazonas.gpkg

# Verificar con ogrinfo
ogrinfo datos/amazonas.gpkg
```

### Error: Invalid field name

Si el `id_field` o `title_field` no existe:

1. Inspecciona el GeoPackage para ver los campos reales
2. Ajusta la configuración con los nombres correctos
3. O elimina esos campos si no son necesarios

### Error: Geometry type not supported

Verifica el tipo de geometría y asegúrate de que pygeoapi lo soporta.

### La extensión (bbox) no es correcta

Ejecuta el script de inspección para obtener la extensión real:
```bash
./inspect_gpkg.py
```

## Siguiente Paso

Una vez completada la configuración del provider, continúa con:
- **Paso 5:** Ejecución del servicio (rama `feature_step_5`)

## Checklist de Verificación

- [ ] GeoPackage inspeccionado y estructura conocida
- [ ] Recurso agregado a `config/pygeoapi-config.yml`
- [ ] Parámetros ajustados (source, id_field, title_field, bbox)
- [ ] Configuración validada
- [ ] OpenAPI regenerado
- [ ] Script de inspección ejecutado
- [ ] Acceso al GeoPackage probado

---

**Referencia:** Ver [SETUP_GUIDE.md](SETUP_GUIDE.md) para la guía completa.
