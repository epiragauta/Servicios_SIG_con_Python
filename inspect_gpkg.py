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
