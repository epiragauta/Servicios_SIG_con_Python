#!/usr/bin/env python3
"""
Script para probar el acceso al GeoPackage
"""

from osgeo import ogr
import sys

def test_geopackage(gpkg_path='datos/amazonas.gpkg'):
    """Prueba el acceso y lectura del GeoPackage"""

    print(f"Probando acceso a: {gpkg_path}")
    print("=" * 60)

    # Abrir el GeoPackage
    ds = ogr.Open(gpkg_path)

    if ds is None:
        print("✗ ERROR: No se pudo abrir el GeoPackage")
        print("Verifica que:")
        print("  - El archivo existe")
        print("  - Tienes permisos de lectura")
        print("  - GDAL está instalado correctamente")
        sys.exit(1)

    print("✓ GeoPackage abierto correctamente")

    # Información general
    num_layers = ds.GetLayerCount()
    print(f"✓ Número de capas: {num_layers}")

    if num_layers == 0:
        print("✗ ERROR: El GeoPackage no contiene capas")
        sys.exit(1)

    # Probar la primera capa
    layer = ds.GetLayerByIndex(0)
    layer_name = layer.GetName()
    feature_count = layer.GetFeatureCount()

    print(f"✓ Capa: {layer_name}")
    print(f"✓ Features: {feature_count}")

    if feature_count == 0:
        print("⚠ ADVERTENCIA: La capa no contiene features")
    else:
        # Leer un feature
        feature = layer.GetNextFeature()
        if feature:
            print(f"✓ Lectura de feature exitosa (ID: {feature.GetFID()})")

            # Mostrar algunos campos
            layer_defn = layer.GetLayerDefn()
            field_count = layer_defn.GetFieldCount()
            print(f"✓ Número de campos: {field_count}")

            if field_count > 0:
                print("  Campos disponibles:")
                for i in range(min(5, field_count)):  # Mostrar máximo 5 campos
                    field_defn = layer_defn.GetFieldDefn(i)
                    field_name = field_defn.GetName()
                    field_value = feature.GetField(i)
                    print(f"    - {field_name}: {field_value}")
                if field_count > 5:
                    print(f"    ... y {field_count - 5} campos más")
        else:
            print("✗ No se pudo leer feature")
            sys.exit(1)

    # Cerrar dataset
    ds = None

    print("=" * 60)
    print("✓ Prueba completada exitosamente")
    print("")
    print("El GeoPackage está listo para usarse con pygeoapi")
    return 0

if __name__ == "__main__":
    gpkg_path = "datos/amazonas.gpkg"

    if len(sys.argv) > 1:
        gpkg_path = sys.argv[1]

    try:
        test_geopackage(gpkg_path)
    except Exception as e:
        print(f"✗ ERROR: {str(e)}")
        sys.exit(1)
