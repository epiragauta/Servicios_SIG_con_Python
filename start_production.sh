#!/bin/bash

echo "=== Iniciando pygeoapi (Producción) ==="
echo ""

# Verificar directorio
if [ ! -f "config/pygeoapi-config.yml" ]; then
    echo "ERROR: No se encuentra config/pygeoapi-config.yml"
    exit 1
fi

# Activar entorno virtual
if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d "venv" ]; then
        source venv/bin/activate
    else
        echo "ERROR: No se encuentra el entorno virtual"
        exit 1
    fi
fi

# Configurar variables de entorno
export PYGEOAPI_CONFIG=config/pygeoapi-config.yml
export PYGEOAPI_OPENAPI=config/openapi.yml

# Validar configuración
echo "Validando configuración..."
if ! pygeoapi config validate $PYGEOAPI_CONFIG; then
    echo "ERROR: Configuración no válida"
    exit 1
fi
echo "✓ Configuración válida"
echo ""

# Generar OpenAPI
echo "Generando OpenAPI..."
pygeoapi openapi generate $PYGEOAPI_CONFIG > $PYGEOAPI_OPENAPI
echo "✓ OpenAPI generado"
echo ""

# Verificar que gunicorn está instalado
if ! command -v gunicorn &> /dev/null; then
    echo "ERROR: gunicorn no está instalado"
    echo "Instálalo con: pip install gunicorn"
    exit 1
fi

# Detener instancia anterior si existe
if [ -f "gunicorn.pid" ]; then
    OLD_PID=$(cat gunicorn.pid)
    if kill -0 $OLD_PID 2>/dev/null; then
        echo "Deteniendo instancia anterior (PID: $OLD_PID)..."
        kill $OLD_PID
        sleep 2
    fi
    rm gunicorn.pid
fi

# Número de workers (CPU cores * 2 + 1)
WORKERS=$(( $(nproc 2>/dev/null || echo 2) * 2 + 1 ))

echo "Iniciando Gunicorn con $WORKERS workers..."
echo "URL: http://localhost:5000"
echo ""

gunicorn pygeoapi.flask_app:APP \
    --bind 0.0.0.0:5000 \
    --workers $WORKERS \
    --worker-class sync \
    --timeout 30 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --access-logfile logs/access.log \
    --error-logfile logs/error.log \
    --log-level info \
    --pid gunicorn.pid \
    --daemon

if [ $? -eq 0 ]; then
    echo "✓ Servidor iniciado en segundo plano"
    echo "  PID: $(cat gunicorn.pid)"
    echo ""
    echo "Para verificar el estado:"
    echo "  curl http://localhost:5000"
    echo ""
    echo "Para ver los logs:"
    echo "  tail -f logs/access.log"
    echo "  tail -f logs/error.log"
    echo ""
    echo "Para detener el servidor:"
    echo "  ./stop.sh"
else
    echo "✗ Error al iniciar el servidor"
    exit 1
fi
