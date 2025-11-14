#!/bin/bash

echo "========================================"
echo "Prueba de Carga Básica - pygeoapi"
echo "========================================"
echo ""

BASE_URL="http://localhost:5000"
URL="$BASE_URL/collections/amazonas/items?limit=10"
REQUESTS=${1:-100}

echo "Configuración:"
echo "  URL: $URL"
echo "  Número de peticiones: $REQUESTS"
echo ""

# Verificar que el servidor está accesible
if ! curl -s -o /dev/null "$BASE_URL" 2>/dev/null; then
    echo "✗ ERROR: Servidor no accesible en $BASE_URL"
    echo "Inicia el servidor con: ./start.sh"
    exit 1
fi

echo "✓ Servidor accesible"
echo ""
echo "Iniciando prueba de carga..."
echo "----------------------------------------"

START_TIME=$(date +%s.%N)
SUCCESS=0
FAILED=0
TOTAL_TIME=0

for i in $(seq 1 $REQUESTS); do
    # Hacer la petición y capturar el tiempo y código de estado
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}:%{time_total}" "$URL" 2>/dev/null)

    STATUS_CODE=$(echo $RESPONSE | cut -d: -f1)
    TIME=$(echo $RESPONSE | cut -d: -f2)

    if [ "$STATUS_CODE" = "200" ]; then
        ((SUCCESS++))
        # Sumar tiempo (usando bc para decimales)
        TOTAL_TIME=$(echo "$TOTAL_TIME + $TIME" | bc)
        echo -n "."
    else
        ((FAILED++))
        echo -n "✗"
    fi

    # Nueva línea cada 50 peticiones
    if [ $((i % 50)) -eq 0 ]; then
        echo " [$i/$REQUESTS]"
    fi
done

echo ""
echo "----------------------------------------"

END_TIME=$(date +%s.%N)
DURATION=$(echo "$END_TIME - $START_TIME" | bc)

echo ""
echo "========================================"
echo "Resultados"
echo "========================================"
echo "Peticiones totales:   $REQUESTS"
echo "Exitosas:             $SUCCESS"
echo "Fallidas:             $FAILED"
echo ""
echo "Tiempo total:         ${DURATION}s"

if [ $SUCCESS -gt 0 ]; then
    AVG_TIME=$(echo "scale=4; $TOTAL_TIME / $SUCCESS" | bc)
    RPS=$(echo "scale=2; $SUCCESS / $DURATION" | bc)
    echo "Tiempo promedio:      ${AVG_TIME}s"
    echo "Peticiones/segundo:   $RPS"
fi

echo "========================================"

if [ $FAILED -eq 0 ]; then
    echo "✓ Prueba completada sin errores"
    exit 0
else
    echo "⚠ Prueba completada con $FAILED errores"
    exit 1
fi
