#!/bin/bash

echo "=== Deteniendo pygeoapi ==="
echo ""

STOPPED=0

# Método 1: Usando el archivo PID
if [ -f "gunicorn.pid" ]; then
    PID=$(cat gunicorn.pid)
    echo "Encontrado archivo PID: $PID"

    if kill -0 $PID 2>/dev/null; then
        echo "Deteniendo proceso $PID..."
        kill $PID
        sleep 2

        # Verificar si se detuvo
        if kill -0 $PID 2>/dev/null; then
            echo "Proceso no respondió, forzando detención..."
            kill -9 $PID
        fi

        echo "✓ Servidor detenido"
        STOPPED=1
    else
        echo "⚠ El proceso $PID ya no está ejecutándose"
    fi

    rm gunicorn.pid
else
    echo "No se encuentra gunicorn.pid"
fi

# Método 2: Buscar procesos por nombre
echo "Buscando procesos de pygeoapi..."
PIDS=$(pgrep -f "gunicorn.*pygeoapi" 2>/dev/null)

if [ -n "$PIDS" ]; then
    echo "Encontrados procesos: $PIDS"
    for PID in $PIDS; do
        echo "Deteniendo proceso $PID..."
        kill $PID 2>/dev/null
        STOPPED=1
    done

    sleep 2

    # Verificar si quedaron procesos
    REMAINING=$(pgrep -f "gunicorn.*pygeoapi" 2>/dev/null)
    if [ -n "$REMAINING" ]; then
        echo "Forzando detención de procesos restantes..."
        kill -9 $REMAINING 2>/dev/null
    fi

    echo "✓ Procesos detenidos"
fi

# Método 3: Buscar procesos de pygeoapi en Flask
FLASK_PIDS=$(pgrep -f "flask.*pygeoapi" 2>/dev/null)
if [ -n "$FLASK_PIDS" ]; then
    echo "Encontrados procesos Flask: $FLASK_PIDS"
    kill $FLASK_PIDS 2>/dev/null
    STOPPED=1
    echo "✓ Procesos Flask detenidos"
fi

if [ $STOPPED -eq 0 ]; then
    echo "⚠ No se encontraron procesos de pygeoapi ejecutándose"
else
    echo ""
    echo "✓ pygeoapi detenido correctamente"
fi
