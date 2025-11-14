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

# Verificar que el servidor está ejecutándose
echo "Verificando servidor..."
if ! curl -s -o /dev/null -w "%{http_code}" "$BASE_URL" > /dev/null 2>&1; then
    echo "✗ ERROR: No se puede conectar a $BASE_URL"
    echo "Asegúrate de que el servidor está ejecutándose:"
    echo "  ./start.sh"
    exit 1
fi
echo "✓ Servidor accesible"
echo ""

# Ejecutar pruebas
test_endpoint "Landing Page" "/"
test_endpoint "Conformance" "/conformance"
test_endpoint "OpenAPI" "/openapi"
test_endpoint "Collections" "/collections"
test_endpoint "Collection Amazonas" "/collections/amazonas"
test_endpoint "Amazonas Items" "/collections/amazonas/items"
test_endpoint "Amazonas Items (limit=5)" "/collections/amazonas/items?limit=5"
test_endpoint "Amazonas Items (limit=10)" "/collections/amazonas/items?limit=10"

# Probar diferentes formatos
test_endpoint "Collections (HTML)" "/collections?f=html"
test_endpoint "Amazonas (HTML)" "/collections/amazonas?f=html"

# Probar endpoint inexistente
test_endpoint "404 Not Found" "/colecciones/noexiste" 404

echo ""
echo "========================================"
echo "Resultados:"
echo "  Exitosas: $PASSED"
echo "  Fallidas: $FAILED"
echo "  Total:    $((PASSED + FAILED))"
echo "========================================"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✓ Todas las pruebas pasaron exitosamente"
    echo ""
    echo "El servidor pygeoapi está funcionando correctamente."
    echo "Puedes acceder a:"
    echo "  - Landing page: $BASE_URL"
    echo "  - Documentación: $BASE_URL/openapi?f=html"
    echo "  - Colecciones:   $BASE_URL/collections"
    exit 0
else
    echo "✗ Algunas pruebas fallaron"
    echo ""
    echo "Revisa los logs para más información:"
    echo "  tail -f logs/pygeoapi.log"
    exit 1
fi
