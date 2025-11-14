# Paso 6: Pruebas y Verificación

Este paso final cubre la verificación completa de la instalación y configuración de pygeoapi, así como pruebas exhaustivas de todos los endpoints.

## Prerequisitos

- Haber completado todos los pasos anteriores (1-5)
- Servidor pygeoapi ejecutándose (ver Paso 5)

## 1. Verificación Básica

### Verificar que el servidor está ejecutándose

```bash
# Verificar con curl
curl -I http://localhost:5000/

# Debería devolver HTTP/1.1 200 OK
```

### Verificar procesos

```bash
# Ver procesos de pygeoapi
ps aux | grep pygeoapi

# O si usas gunicorn
ps aux | grep gunicorn
```

## 2. Pruebas de Endpoints

### 2.1 Landing Page

```bash
# Obtener la página principal
curl http://localhost:5000/ | python -m json.tool

# Debería devolver información del servicio
```

Respuesta esperada:
```json
{
  "title": "Servicios SIG con Python - Amazonas",
  "description": "API de servicios geoespaciales para datos del Amazonas",
  "links": [...]
}
```

### 2.2 Conformance

```bash
# Verificar conformidad con estándares OGC
curl http://localhost:5000/conformance | python -m json.tool
```

### 2.3 OpenAPI Specification

```bash
# Obtener especificación OpenAPI en JSON
curl http://localhost:5000/openapi | python -m json.tool

# Obtener en formato HTML (navegador)
# http://localhost:5000/openapi?f=html
```

### 2.4 Collections

```bash
# Listar todas las colecciones
curl http://localhost:5000/collections | python -m json.tool

# Obtener información de la colección amazonas
curl http://localhost:5000/collections/amazonas | python -m json.tool
```

### 2.5 Features (Items)

```bash
# Obtener todos los features (con límite por defecto)
curl http://localhost:5000/collections/amazonas/items | python -m json.tool

# Obtener con límite específico
curl "http://localhost:5000/collections/amazonas/items?limit=5" | python -m json.tool

# Obtener con paginación (offset)
curl "http://localhost:5000/collections/amazonas/items?limit=5&offset=10" | python -m json.tool

# Filtrar por bbox (bounding box)
curl "http://localhost:5000/collections/amazonas/items?bbox=-75,-2,-70,2" | python -m json.tool
```

### 2.6 Feature Individual

```bash
# Primero obtener un ID de feature
FEATURE_ID=$(curl -s "http://localhost:5000/collections/amazonas/items?limit=1" | python -c "import sys, json; print(json.load(sys.stdin)['features'][0]['id'])")

# Obtener el feature específico
curl "http://localhost:5000/collections/amazonas/items/$FEATURE_ID" | python -m json.tool
```

## 3. Scripts de Pruebas Automatizadas

### 3.1 Script Bash: test_api.sh

```bash
#!/bin/bash

BASE_URL="http://localhost:5000"
PASSED=0
FAILED=0

echo "========================================"
echo "Pruebas de pygeoapi - Amazonas"
echo "========================================"
echo ""

# Función para probar endpoint
test_endpoint() {
    local name=$1
    local endpoint=$2
    local expected_status=${3:-200}

    echo -n "Probando $name... "

    status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$endpoint")

    if [ "$status" -eq "$expected_status" ]; then
        echo "✓ PASS (HTTP $status)"
        ((PASSED++))
    else
        echo "✗ FAIL (HTTP $status, esperado $expected_status)"
        ((FAILED++))
    fi
}

# Ejecutar pruebas
test_endpoint "Landing Page" "/"
test_endpoint "Conformance" "/conformance"
test_endpoint "OpenAPI" "/openapi"
test_endpoint "Collections" "/collections"
test_endpoint "Collection Amazonas" "/collections/amazonas"
test_endpoint "Amazonas Items" "/collections/amazonas/items"
test_endpoint "Amazonas Items (limit)" "/collections/amazonas/items?limit=5"

# Probar endpoint inexistente
test_endpoint "404 Not Found" "/colecciones/noexiste" 404

echo ""
echo "========================================"
echo "Resultados:"
echo "  Exitosas: $PASSED"
echo "  Fallidas: $FAILED"
echo "========================================"

if [ $FAILED -eq 0 ]; then
    echo "✓ Todas las pruebas pasaron"
    exit 0
else
    echo "✗ Algunas pruebas fallaron"
    exit 1
fi
```

### 3.2 Script Python: test_api.py

```python
#!/usr/bin/env python3
"""
Script de pruebas para pygeoapi
"""

import requests
import json
import sys

BASE_URL = "http://localhost:5000"

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    RESET = '\033[0m'

def test_endpoint(name, endpoint, expected_status=200, check_json=True):
    """Prueba un endpoint y verifica el resultado"""
    print(f"\nProbando: {name}")
    print(f"Endpoint: {endpoint}")
    print("-" * 60)

    try:
        response = requests.get(f"{BASE_URL}{endpoint}", timeout=10)

        # Verificar status code
        if response.status_code == expected_status:
            print(f"{Colors.GREEN}✓ Status Code: {response.status_code}{Colors.RESET}")
            status_ok = True
        else:
            print(f"{Colors.RED}✗ Status Code: {response.status_code} (esperado {expected_status}){Colors.RESET}")
            status_ok = False

        # Verificar JSON
        if check_json and status_ok:
            try:
                data = response.json()
                print(f"{Colors.GREEN}✓ Respuesta JSON válida{Colors.RESET}")
                print(f"  Campos principales: {', '.join(list(data.keys())[:5])}")

                if 'features' in data:
                    print(f"  Número de features: {len(data['features'])}")
                if 'numberMatched' in data:
                    print(f"  Total matched: {data['numberMatched']}")
                if 'numberReturned' in data:
                    print(f"  Total returned: {data['numberReturned']}")

                json_ok = True
            except json.JSONDecodeError:
                print(f"{Colors.RED}✗ Respuesta no es JSON válido{Colors.RESET}")
                json_ok = False
        else:
            json_ok = True

        return status_ok and json_ok

    except requests.exceptions.RequestException as e:
        print(f"{Colors.RED}✗ Error de conexión: {str(e)}{Colors.RESET}")
        return False

def test_feature_retrieval():
    """Prueba la recuperación de features individuales"""
    print(f"\nProbando: Recuperación de Feature Individual")
    print("-" * 60)

    try:
        # Obtener lista de features
        response = requests.get(f"{BASE_URL}/collections/amazonas/items?limit=1")
        data = response.json()

        if 'features' in data and len(data['features']) > 0:
            feature_id = data['features'][0]['id']
            print(f"Feature ID obtenido: {feature_id}")

            # Obtener el feature individual
            response = requests.get(f"{BASE_URL}/collections/amazonas/items/{feature_id}")

            if response.status_code == 200:
                feature = response.json()
                print(f"{Colors.GREEN}✓ Feature recuperado exitosamente{Colors.RESET}")
                print(f"  ID: {feature.get('id')}")
                print(f"  Tipo: {feature.get('type')}")
                print(f"  Geometría: {feature.get('geometry', {}).get('type')}")
                return True
            else:
                print(f"{Colors.RED}✗ Error al recuperar feature{Colors.RESET}")
                return False
        else:
            print(f"{Colors.YELLOW}⚠ No hay features disponibles{Colors.RESET}")
            return True

    except Exception as e:
        print(f"{Colors.RED}✗ Error: {str(e)}{Colors.RESET}")
        return False

def test_filters():
    """Prueba los filtros de la API"""
    print(f"\nProbando: Filtros y Parámetros")
    print("-" * 60)

    results = []

    # Probar limit
    print("\n1. Parámetro limit:")
    for limit in [1, 5, 10]:
        response = requests.get(f"{BASE_URL}/collections/amazonas/items?limit={limit}")
        data = response.json()
        returned = data.get('numberReturned', 0)
        print(f"   limit={limit}: {returned} features devueltos")
        results.append(returned <= limit)

    # Probar bbox
    print("\n2. Parámetro bbox:")
    response = requests.get(f"{BASE_URL}/collections/amazonas/items?bbox=-75,-2,-70,2")
    if response.status_code == 200:
        data = response.json()
        print(f"{Colors.GREEN}✓ Filtro bbox funciona{Colors.RESET}")
        print(f"   Features devueltos: {data.get('numberReturned', 0)}")
        results.append(True)
    else:
        print(f"{Colors.RED}✗ Error con filtro bbox{Colors.RESET}")
        results.append(False)

    return all(results)

def main():
    """Ejecutar todas las pruebas"""
    print("=" * 60)
    print("Pruebas de pygeoapi - Colección Amazonas")
    print("=" * 60)

    # Verificar que el servidor está ejecutándose
    try:
        requests.get(BASE_URL, timeout=5)
    except requests.exceptions.RequestException:
        print(f"{Colors.RED}✗ Error: No se puede conectar a {BASE_URL}{Colors.RESET}")
        print("Asegúrate de que el servidor está ejecutándose (./start.sh)")
        sys.exit(1)

    results = []

    # Pruebas de endpoints básicos
    results.append(test_endpoint("Landing Page", "/"))
    results.append(test_endpoint("Conformance", "/conformance"))
    results.append(test_endpoint("OpenAPI Specification", "/openapi"))
    results.append(test_endpoint("Collections", "/collections"))
    results.append(test_endpoint("Collection Amazonas", "/collections/amazonas"))
    results.append(test_endpoint("Amazonas Items", "/collections/amazonas/items"))

    # Pruebas avanzadas
    results.append(test_feature_retrieval())
    results.append(test_filters())

    # Prueba de endpoint inexistente
    results.append(test_endpoint("404 Not Found", "/noexiste", expected_status=404, check_json=False))

    # Resumen
    print("\n" + "=" * 60)
    print("RESUMEN DE PRUEBAS")
    print("=" * 60)

    passed = sum(results)
    total = len(results)
    failed = total - passed

    print(f"Total de pruebas: {total}")
    print(f"{Colors.GREEN}Exitosas: {passed}{Colors.RESET}")
    if failed > 0:
        print(f"{Colors.RED}Fallidas: {failed}{Colors.RESET}")
    else:
        print(f"Fallidas: {failed}")

    if failed == 0:
        print(f"\n{Colors.GREEN}✓ Todas las pruebas pasaron exitosamente{Colors.RESET}")
        sys.exit(0)
    else:
        print(f"\n{Colors.RED}✗ Algunas pruebas fallaron{Colors.RESET}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## 4. Pruebas de Rendimiento

### 4.1 Script de carga básica: load_test.sh

```bash
#!/bin/bash

echo "=== Prueba de Carga Básica ==="
echo ""

URL="http://localhost:5000/collections/amazonas/items?limit=10"
REQUESTS=100

echo "URL: $URL"
echo "Número de peticiones: $REQUESTS"
echo ""

START_TIME=$(date +%s)

for i in $(seq 1 $REQUESTS); do
    curl -s -o /dev/null -w "Request $i: %{http_code} - %{time_total}s\n" "$URL"
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "Tiempo total: ${DURATION}s"
echo "Promedio: $(echo "scale=2; $DURATION / $REQUESTS" | bc)s por petición"
```

### 4.2 Usando Apache Bench (si está disponible)

```bash
# Instalar Apache Bench
sudo apt-get install apache2-utils

# Ejecutar prueba
ab -n 1000 -c 10 http://localhost:5000/collections/amazonas/items
```

## 5. Pruebas desde el Navegador

### Endpoints para probar en el navegador:

1. **Landing Page**
   - http://localhost:5000

2. **Documentación interactiva (OpenAPI)**
   - http://localhost:5000/openapi?f=html

3. **Colecciones**
   - http://localhost:5000/collections
   - http://localhost:5000/collections?f=html

4. **Colección Amazonas**
   - http://localhost:5000/collections/amazonas
   - http://localhost:5000/collections/amazonas?f=html

5. **Items (Features)**
   - http://localhost:5000/collections/amazonas/items
   - http://localhost:5000/collections/amazonas/items?f=html
   - http://localhost:5000/collections/amazonas/items?limit=5&f=html

6. **Mapa interactivo (si está configurado)**
   - http://localhost:5000/collections/amazonas/items?f=html

## 6. Verificación de Logs

```bash
# Ver logs en tiempo real
tail -f logs/pygeoapi.log

# Si usas gunicorn
tail -f logs/access.log
tail -f logs/error.log

# Buscar errores
grep -i error logs/pygeoapi.log
grep -i error logs/error.log
```

## 7. Checklist Final de Verificación

### Configuración
- [ ] Archivo de configuración válido
- [ ] OpenAPI generado correctamente
- [ ] Provider GeoPackage configurado
- [ ] Variables de entorno establecidas

### Servidor
- [ ] Servidor ejecutándose sin errores
- [ ] Puerto 5000 accesible
- [ ] Sin errores en logs

### Endpoints Básicos
- [ ] Landing page (/) funciona
- [ ] Conformance (/conformance) funciona
- [ ] OpenAPI (/openapi) funciona
- [ ] Collections (/collections) funciona

### Colección Amazonas
- [ ] Metadata de colección accesible
- [ ] Items (features) accesibles
- [ ] Paginación funciona (limit, offset)
- [ ] Filtro bbox funciona
- [ ] Features individuales accesibles

### Formatos
- [ ] Respuesta JSON válida
- [ ] Formato HTML disponible (f=html)
- [ ] GeoJSON válido

### Rendimiento
- [ ] Respuestas rápidas (< 1s para queries simples)
- [ ] Sin memory leaks
- [ ] Maneja múltiples peticiones concurrentes

## 8. Solución de Problemas Comunes

### No se pueden obtener features

```bash
# Verificar que el GeoPackage es accesible
./test_gpkg.py

# Verificar configuración del provider
cat config/pygeoapi-config.yml | grep -A 20 "amazonas:"

# Verificar logs
tail -n 50 logs/pygeoapi.log
```

### Respuestas lentas

```bash
# Verificar configuración de workers (si usas gunicorn)
ps aux | grep gunicorn | wc -l

# Verificar recursos del sistema
htop

# Verificar tamaño del GeoPackage
du -h datos/amazonas.gpkg
```

### Errores 500

```bash
# Ver logs de error
tail -n 100 logs/error.log

# Verificar configuración
pygeoapi config validate config/pygeoapi-config.yml
```

## 9. Próximos Pasos

Una vez que todas las pruebas pasen exitosamente:

1. **Optimización:** Ajustar workers, caché, etc.
2. **Seguridad:** Implementar HTTPS, autenticación
3. **Monitoreo:** Configurar alertas y dashboards
4. **Backup:** Implementar respaldo de datos
5. **Documentación:** Completar documentación de API
6. **Integración:** Conectar con clientes (QGIS, Leaflet, etc.)

## Checklist de Verificación Final

- [ ] Todas las pruebas del script test_api.sh pasan
- [ ] Todas las pruebas del script test_api.py pasan
- [ ] Endpoints accesibles desde navegador
- [ ] Formatos JSON y HTML funcionan
- [ ] Filtros (limit, bbox) funcionan
- [ ] Sin errores en logs
- [ ] Rendimiento aceptable
- [ ] Documentación actualizada

---

**¡Felicitaciones!** Si llegaste hasta aquí y todas las pruebas pasan, has configurado exitosamente pygeoapi con tus datos del Amazonas.

**Referencia:** Ver [SETUP_GUIDE.md](SETUP_GUIDE.md) para la guía completa.
